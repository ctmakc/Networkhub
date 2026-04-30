import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:networkhub/features/scan/data/business_card_extractor.dart';
import 'package:networkhub/features/scan/data/ocr_service.dart';
import 'package:networkhub/features/scan/data/scan_models.dart';
import 'package:networkhub/features/scan/data/vcard_parser.dart';

enum ScanStatus { idle, processing, success, error }

class ScanState {
  final ScanStatus status;
  final DraftContact? draftContact;
  final String? rawText;
  final String? errorMessage;
  final ScanMode mode;

  const ScanState({
    this.status = ScanStatus.idle,
    this.draftContact,
    this.rawText,
    this.errorMessage,
    this.mode = ScanMode.camera,
  });

  ScanState copyWith({
    ScanStatus? status,
    DraftContact? draftContact,
    String? rawText,
    String? errorMessage,
    ScanMode? mode,
  }) {
    return ScanState(
      status: status ?? this.status,
      draftContact: draftContact ?? this.draftContact,
      rawText: rawText ?? this.rawText,
      errorMessage: errorMessage,
      mode: mode ?? this.mode,
    );
  }

  bool get isProcessing => status == ScanStatus.processing;
  bool get hasResult => status == ScanStatus.success && draftContact != null;
}

final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>(
  (ref) => ScanNotifier(),
);

class ScanNotifier extends StateNotifier<ScanState> {
  final OcrService _ocrService = OcrService();
  final ImagePicker _imagePicker = ImagePicker();

  ScanNotifier() : super(const ScanState());

  void setMode(ScanMode mode) {
    state = state.copyWith(mode: mode);
  }

  /// Process an image file path through OCR
  Future<void> processImageFile(String imagePath) async {
    state = state.copyWith(status: ScanStatus.processing, errorMessage: null);
    try {
      final rawText = await _ocrService.recognizeText(imagePath);
      final draft = BusinessCardExtractor.extract(rawText);
      state = state.copyWith(
        status: ScanStatus.success,
        rawText: rawText,
        draftContact: draft,
      );
    } catch (e) {
      state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'Failed to process image: $e',
      );
    }
  }

  /// Process QR code / NFC vCard data
  Future<void> processVCard(String vcardData) async {
    state = state.copyWith(status: ScanStatus.processing, errorMessage: null);
    try {
      final draft = VCardParser.parse(vcardData);
      state = state.copyWith(
        status: ScanStatus.success,
        rawText: vcardData,
        draftContact: draft,
      );
    } catch (e) {
      state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'Failed to parse contact data: $e',
      );
    }
  }

  /// Pick image from gallery
  Future<String?> pickFromGallery() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    return file?.path;
  }

  /// Reset scan state
  void reset() {
    state = ScanState(mode: state.mode);
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}
