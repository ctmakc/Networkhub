import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:networkhub/features/cloud_sync/data/contact_models.dart';
import 'package:networkhub/features/cloud_sync/data/templates_repository.dart';
import 'package:networkhub/features/messaging/presentation/widgets/email_toggle_widget.dart';
import 'package:networkhub/features/messaging/providers/messaging_provider.dart';
import 'package:networkhub/shared/widgets/error_snackbar.dart';
import 'package:networkhub/shared/widgets/loading_overlay.dart';

class EmailPreviewScreen extends ConsumerStatefulWidget {
  const EmailPreviewScreen({super.key, required this.contact});

  final Contact contact;

  @override
  ConsumerState<EmailPreviewScreen> createState() => _EmailPreviewScreenState();
}

class _EmailPreviewScreenState extends ConsumerState<EmailPreviewScreen> {
  Template? _selectedTemplate;

  @override
  Widget build(BuildContext context) {
    final messagingState = ref.watch(messagingProvider);
    final templatesAsync = ref.watch(templatesListProvider);
    final theme = Theme.of(context);

    ref.listen<MessagingState>(messagingProvider, (prev, next) {
      if (next.status == MessagingStatus.sent) {
        showSuccessSnackbar(context, 'Email sent successfully!');
        Navigator.of(context).pop();
      } else if (next.status == MessagingStatus.error &&
          next.errorMessage != null) {
        showErrorSnackbar(context, next.errorMessage!);
        ref.read(messagingProvider.notifier).reset();
      }
    });

    return LoadingOverlay(
      isLoading: messagingState.isSending,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Send Email'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Contact info header
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    _getInitials(),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.contact.fullName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.contact.email != null)
                        Text(
                          widget.contact.email!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const Gap(24),

            // Template selection
            Text(
              'Select Template',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(8),
            templatesAsync.when(
              data: (templates) {
                if (templates.isEmpty) {
                  return Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No templates available. Create one in Settings.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }

                return DropdownButtonFormField<Template>(
                  value: _selectedTemplate,
                  hint: const Text('Choose a template'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: templates
                      .map(
                        (t) => DropdownMenuItem<Template>(
                          value: t,
                          child: Text(t.name),
                        ),
                      )
                      .toList(),
                  onChanged: (template) {
                    setState(() => _selectedTemplate = template);
                    if (template != null) {
                      ref.read(messagingProvider.notifier).setTemplate(template);
                    }
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Failed to load templates'),
            ),

            // Template preview
            if (_selectedTemplate != null) ...[
              const Gap(24),
              Text(
                'Preview',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(8),
              _TemplatePreview(
                template: _selectedTemplate!,
                contact: widget.contact,
              ),
            ],

            const Gap(24),

            // Consent toggle
            EmailConsentToggle(
              value: messagingState.consentGiven,
              onChanged: (v) =>
                  ref.read(messagingProvider.notifier).setConsent(v),
              contactName: widget.contact.firstName,
            ),

            const Gap(32),

            // Send button
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Send Email'),
              onPressed: (_selectedTemplate == null ||
                      !messagingState.consentGiven ||
                      messagingState.isSending)
                  ? null
                  : () {
                      ref.read(messagingProvider.notifier).sendEmail(
                            contactId: widget.contact.id,
                            templateId: _selectedTemplate!.id,
                          );
                    },
            ),
            const Gap(12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials() {
    final first = widget.contact.firstName?.isNotEmpty == true
        ? widget.contact.firstName![0].toUpperCase()
        : '';
    final last = widget.contact.lastName?.isNotEmpty == true
        ? widget.contact.lastName![0].toUpperCase()
        : '';
    return '$first$last'.isNotEmpty ? '$first$last' : '?';
  }
}

class _TemplatePreview extends StatelessWidget {
  const _TemplatePreview({required this.template, required this.contact});

  final Template template;
  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final renderedSubject = _renderTemplate(template.subject);
    final renderedBody = _renderTemplate(template.body);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject line
            Row(
              children: [
                Text(
                  'Subject: ',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: Text(
                    renderedSubject,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            // Body
            Text(
              renderedBody,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  String _renderTemplate(String template) {
    return template
        .replaceAll('{{first_name}}', contact.firstName ?? 'there')
        .replaceAll('{{last_name}}', contact.lastName ?? '')
        .replaceAll('{{full_name}}', contact.fullName)
        .replaceAll('{{company}}', contact.company ?? '')
        .replaceAll('{{title}}', contact.title ?? '');
  }
}
