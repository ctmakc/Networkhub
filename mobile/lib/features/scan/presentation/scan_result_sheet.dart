import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:networkhub/shared/widgets/error_snackbar.dart';

class ScanResultSheet extends StatelessWidget {
  const ScanResultSheet({
    super.key,
    required this.rawText,
    required this.onContinue,
  });

  final String rawText;
  final VoidCallback onContinue;

  static Future<void> show(
    BuildContext context, {
    required String rawText,
    required VoidCallback onContinue,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScanResultSheet(
        rawText: rawText,
        onContinue: onContinue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.65,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              children: [
                Icon(
                  Icons.text_snippet_outlined,
                  color: theme.colorScheme.primary,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    'Extracted Text',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: rawText));
                    if (context.mounted) {
                      showSuccessSnackbar(context, 'Text copied to clipboard');
                    }
                  },
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy text',
                ),
              ],
            ),
          ),
          const Divider(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  rawText.isEmpty ? '(No text detected)' : rawText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Rescan'),
                  ),
                ),
                const Gap(12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onContinue();
                    },
                    child: const Text('Review contact'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
