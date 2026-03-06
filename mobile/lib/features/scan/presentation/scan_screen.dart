import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:networkhub/features/scan/data/scan_models.dart';
import 'package:networkhub/features/scan/data/vcard_parser.dart';
import 'package:networkhub/features/scan/providers/scan_provider.dart';
import 'package:networkhub/shared/widgets/error_snackbar.dart';
import 'package:networkhub/shared/widgets/loading_overlay.dart';
import 'package:networkhub/shared/widgets/pending_sync_badge.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _cameraInitialized = false;
  bool _isCapturing = false;
  MobileScannerController? _qrController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      _cameraController = CameraController(
        _cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) setState(() => _cameraInitialized = true);
    } catch (e) {
      if (mounted) showErrorSnackbar(context, 'Camera not available: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _qrController?.dispose();
    super.dispose();
  }

  Future<void> _captureAndProcess() async {
    if (_isCapturing || !_cameraInitialized || _cameraController == null) {
      return;
    }

    setState(() => _isCapturing = true);
    try {
      final file = await _cameraController!.takePicture();
      await ref.read(scanProvider.notifier).processImageFile(file.path);

      final scanState = ref.read(scanProvider);
      if (scanState.status == ScanStatus.success && mounted) {
        _navigateToReview(scanState);
      } else if (scanState.status == ScanStatus.error && mounted) {
        showErrorSnackbar(context, scanState.errorMessage ?? 'Scan failed');
      }
    } catch (e) {
      if (mounted) showErrorSnackbar(context, 'Capture failed: $e');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final imagePath =
        await ref.read(scanProvider.notifier).pickFromGallery();
    if (imagePath == null) return;

    await ref.read(scanProvider.notifier).processImageFile(imagePath);

    final scanState = ref.read(scanProvider);
    if (scanState.status == ScanStatus.success && mounted) {
      _navigateToReview(scanState);
    } else if (scanState.status == ScanStatus.error && mounted) {
      showErrorSnackbar(context, scanState.errorMessage ?? 'Scan failed');
    }
  }

  void _navigateToReview(ScanState scanState) {
    context.push('/scan/review', extra: {
      'draft': scanState.draftContact?.toJson(),
      'rawText': scanState.rawText,
    });
    ref.read(scanProvider.notifier).reset();
  }

  void _onQrDetected(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;

      if (VCardParser.isVCard(raw)) {
        _qrController?.stop();
        ref.read(scanProvider.notifier).processVCard(raw).then((_) {
          final scanState = ref.read(scanProvider);
          if (scanState.status == ScanStatus.success && mounted) {
            _navigateToReview(scanState);
          }
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);
    final mode = scanState.mode;
    final theme = Theme.of(context);

    return LoadingOverlay(
      isLoading: scanState.isProcessing || _isCapturing,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Row(
            children: [
              Text(
                'NetworkHub',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(8),
              const PendingSyncBadge(),
            ],
          ),
          actions: [
            // Mode toggle
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ModeButton(
                    icon: Icons.camera_alt,
                    label: 'Card',
                    selected: mode == ScanMode.camera,
                    onTap: () => ref
                        .read(scanProvider.notifier)
                        .setMode(ScanMode.camera),
                  ),
                  _ModeButton(
                    icon: Icons.qr_code_scanner,
                    label: 'QR',
                    selected: mode == ScanMode.qrCode,
                    onTap: () => ref
                        .read(scanProvider.notifier)
                        .setMode(ScanMode.qrCode),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Camera preview or QR scanner
            if (mode == ScanMode.camera) _buildCameraPreview()
            else _buildQrScanner(),

            // Scan guide overlay
            if (mode == ScanMode.camera) _buildScanOverlay(),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildControls(mode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_cameraInitialized || _cameraController == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            Gap(16),
            Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraController!.value.previewSize!.height,
          height: _cameraController!.value.previewSize!.width,
          child: CameraPreview(_cameraController!),
        ),
      ),
    );
  }

  Widget _buildQrScanner() {
    _qrController ??= MobileScannerController();
    return MobileScanner(
      controller: _qrController!,
      onDetect: _onQrDetected,
    );
  }

  Widget _buildScanOverlay() {
    return Center(
      child: Container(
        width: 280,
        height: 180,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white54, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Corner indicators
            Positioned(
              top: -1,
              left: -1,
              child: _CornerIndicator(topLeft: true),
            ),
            Positioned(
              top: -1,
              right: -1,
              child: _CornerIndicator(topRight: true),
            ),
            Positioned(
              bottom: -1,
              left: -1,
              child: _CornerIndicator(bottomLeft: true),
            ),
            Positioned(
              bottom: -1,
              right: -1,
              child: _CornerIndicator(bottomRight: true),
            ),
            const Center(
              child: Text(
                'Align business card here',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(ScanMode mode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button
          _CircleButton(
            icon: Icons.photo_library_outlined,
            label: 'Gallery',
            onTap: _pickFromGallery,
          ),

          // Capture button (only in camera mode)
          if (mode == ScanMode.camera)
            GestureDetector(
              onTap: _captureAndProcess,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 72),

          // Flash button
          _CircleButton(
            icon: Icons.flash_auto,
            label: 'Flash',
            onTap: () async {
              if (_cameraController != null) {
                final current = _cameraController!.value.flashMode;
                await _cameraController!.setFlashMode(
                  current == FlashMode.off ? FlashMode.torch : FlashMode.off,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.black : Colors.white,
            ),
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const Gap(4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _CornerIndicator extends StatelessWidget {
  const _CornerIndicator({
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _CornerPainter(
        topLeft: topLeft,
        topRight: topRight,
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const length = 20.0;
    if (topLeft) {
      canvas.drawLine(Offset.zero, Offset(length, 0), paint);
      canvas.drawLine(Offset.zero, Offset(0, length), paint);
    }
    if (topRight) {
      canvas.drawLine(Offset(size.width, 0), Offset(size.width - length, 0), paint);
      canvas.drawLine(Offset(size.width, 0), Offset(size.width, length), paint);
    }
    if (bottomLeft) {
      canvas.drawLine(Offset(0, size.height), Offset(length, size.height), paint);
      canvas.drawLine(Offset(0, size.height), Offset(0, size.height - length), paint);
    }
    if (bottomRight) {
      canvas.drawLine(Offset(size.width, size.height), Offset(size.width - length, size.height), paint);
      canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - length), paint);
    }
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) => false;
}
