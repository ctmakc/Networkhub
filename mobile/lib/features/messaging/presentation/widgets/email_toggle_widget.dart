import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EmailConsentToggle extends StatelessWidget {
  const EmailConsentToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.contactName,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? contactName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = contactName ?? 'this contact';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: value
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? theme.colorScheme.primary.withOpacity(0.5)
              : theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: value
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const Gap(8),
              Expanded(
                child: Text(
                  'Consent Confirmation',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
              ),
            ],
          ),
          const Gap(8),
          Text(
            'I confirm that $name has given permission to receive email communications, '
            'and that sending this email complies with applicable email regulations '
            '(GDPR, CAN-SPAM, etc.).',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          if (!value) ...[
            const Gap(8),
            Text(
              'You must confirm consent before sending.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
