import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:networkhub/features/cloud_sync/data/events_repository.dart';
import 'package:networkhub/features/contact_review/data/contact_validator.dart';
import 'package:networkhub/features/contact_review/presentation/widgets/event_picker_widget.dart';
import 'package:networkhub/features/contact_review/presentation/widgets/tag_input_widget.dart';
import 'package:networkhub/features/contact_review/providers/review_provider.dart';
import 'package:networkhub/features/scan/data/scan_models.dart';
import 'package:networkhub/shared/widgets/confirmation_dialog.dart';
import 'package:networkhub/shared/widgets/error_snackbar.dart';
import 'package:networkhub/shared/widgets/loading_overlay.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, this.draftJson});

  final Map<String, dynamic>? draftJson;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _linkedinCtrl;

  bool _showRawText = false;

  @override
  void initState() {
    super.initState();
    final draft = _parseDraft();

    _firstNameCtrl = TextEditingController(text: draft.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: draft.lastName ?? '');
    _emailCtrl = TextEditingController(text: draft.email ?? '');
    _phoneCtrl = TextEditingController(text: draft.phone ?? '');
    _companyCtrl = TextEditingController(text: draft.company ?? '');
    _titleCtrl = TextEditingController(text: draft.title ?? '');
    _websiteCtrl = TextEditingController(text: draft.website ?? '');
    _notesCtrl = TextEditingController(text: draft.notes ?? '');
    _addressCtrl = TextEditingController(text: draft.address ?? '');
    _linkedinCtrl = TextEditingController(text: draft.linkedinUrl ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewProvider.notifier).loadDraft(draft);
    });
  }

  DraftContact _parseDraft() {
    final json = widget.draftJson;
    if (json == null) return const DraftContact();

    final draftData = json['draft'] as Map<String, dynamic>?;
    final rawText = json['rawText'] as String? ?? '';

    if (draftData == null) return DraftContact(rawOcrText: rawText);

    return DraftContact(
      firstName: draftData['first_name'] as String?,
      lastName: draftData['last_name'] as String?,
      email: draftData['email'] as String?,
      phone: draftData['phone'] as String?,
      company: draftData['company'] as String?,
      title: draftData['title'] as String?,
      website: draftData['website'] as String?,
      notes: draftData['notes'] as String?,
      address: draftData['address'] as String?,
      linkedinUrl: draftData['linkedin_url'] as String?,
      rawOcrText: rawText,
      tags: (draftData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _companyCtrl.dispose();
    _titleCtrl.dispose();
    _websiteCtrl.dispose();
    _notesCtrl.dispose();
    _addressCtrl.dispose();
    _linkedinCtrl.dispose();
    super.dispose();
  }

  void _syncFieldsToProvider() {
    ref.read(reviewProvider.notifier).updateField(
          firstName: _firstNameCtrl.text.trim().isNotEmpty
              ? _firstNameCtrl.text.trim()
              : null,
          lastName: _lastNameCtrl.text.trim().isNotEmpty
              ? _lastNameCtrl.text.trim()
              : null,
          email: _emailCtrl.text.trim().isNotEmpty
              ? _emailCtrl.text.trim()
              : null,
          phone: _phoneCtrl.text.trim().isNotEmpty
              ? ContactValidator.normalizePhone(_phoneCtrl.text)
              : null,
          company: _companyCtrl.text.trim().isNotEmpty
              ? _companyCtrl.text.trim()
              : null,
          title: _titleCtrl.text.trim().isNotEmpty
              ? _titleCtrl.text.trim()
              : null,
          website: _websiteCtrl.text.trim().isNotEmpty
              ? ContactValidator.normalizeUrl(_websiteCtrl.text)
              : null,
          notes: _notesCtrl.text.trim().isNotEmpty
              ? _notesCtrl.text.trim()
              : null,
          address: _addressCtrl.text.trim().isNotEmpty
              ? _addressCtrl.text.trim()
              : null,
          linkedinUrl: _linkedinCtrl.text.trim().isNotEmpty
              ? _linkedinCtrl.text.trim()
              : null,
        );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _syncFieldsToProvider();

    final success = await ref.read(reviewProvider.notifier).saveContact();

    if (success && mounted) {
      showSuccessSnackbar(context, 'Contact saved successfully!');
      final savedId = ref.read(reviewProvider).savedContactId;
      if (savedId != null) {
        context.go('/contacts/$savedId');
      } else {
        context.go('/history');
      }
    } else if (mounted) {
      final error = ref.read(reviewProvider).errorMessage;
      showErrorSnackbar(context, error ?? 'Failed to save contact');
    }
  }

  Future<bool> _onWillPop() async {
    final draft = ref.read(reviewProvider).draft;
    final hasData = (draft.firstName?.isNotEmpty ?? false) ||
        (draft.email?.isNotEmpty ?? false) ||
        (draft.phone?.isNotEmpty ?? false);

    if (!hasData) return true;

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Discard changes?',
      message: 'The scanned contact data will be lost.',
      confirmLabel: 'Discard',
      isDangerous: true,
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewProvider);
    final theme = Theme.of(context);

    ref.listen<ReviewState>(reviewProvider, (prev, next) {
      if (next.status == ReviewStatus.error && next.errorMessage != null) {
        showErrorSnackbar(context, next.errorMessage!);
        ref.read(reviewProvider.notifier).resetStatus();
      }
    });

    return WillPopScope(
      onWillPop: _onWillPop,
      child: LoadingOverlay(
        isLoading: reviewState.isSaving,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Review Contact'),
            actions: [
              if (reviewState.draft.rawOcrText.isNotEmpty)
                IconButton(
                  icon: Icon(
                    _showRawText ? Icons.text_fields : Icons.raw_on_outlined,
                  ),
                  tooltip: 'Toggle raw text',
                  onPressed: () =>
                      setState(() => _showRawText = !_showRawText),
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Raw OCR text (collapsible)
                if (reviewState.draft.rawOcrText.isNotEmpty && _showRawText)
                  _RawTextCard(rawText: reviewState.draft.rawOcrText),

                // Personal info section
                _SectionHeader(
                  icon: Icons.person_outline,
                  title: 'Contact Info',
                ),
                const Gap(12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'First name',
                        ),
                        onChanged: (_) {},
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Last name',
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: ContactValidator.validateEmail,
                ),
                const Gap(12),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: ContactValidator.validatePhone,
                ),

                const Gap(20),
                _SectionHeader(
                  icon: Icons.business_outlined,
                  title: 'Professional',
                ),
                const Gap(12),
                TextFormField(
                  controller: _companyCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Company',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                ),
                const Gap(12),
                TextFormField(
                  controller: _titleCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Job title',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                ),
                const Gap(12),
                TextFormField(
                  controller: _websiteCtrl,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Website',
                    prefixIcon: Icon(Icons.language_outlined),
                  ),
                  validator: ContactValidator.validateUrl,
                ),
                const Gap(12),
                TextFormField(
                  controller: _linkedinCtrl,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'LinkedIn URL',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const Gap(12),
                TextFormField(
                  controller: _addressCtrl,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    alignLabelWithHint: true,
                  ),
                ),

                const Gap(20),
                _SectionHeader(
                  icon: Icons.label_outline,
                  title: 'Tags',
                ),
                const Gap(12),
                TagInputWidget(
                  tags: reviewState.draft.tags,
                  onTagsChanged: (tags) =>
                      ref.read(reviewProvider.notifier).setTags(tags),
                  suggestions: const [
                    'prospect',
                    'customer',
                    'partner',
                    'investor',
                    'vendor',
                    'press',
                  ],
                ),

                const Gap(20),
                _SectionHeader(
                  icon: Icons.event_outlined,
                  title: 'Event',
                ),
                const Gap(12),
                _EventSelector(
                  selectedEventId: reviewState.draft.eventId,
                  onEventSelected: (id) =>
                      ref.read(reviewProvider.notifier).updateField(eventId: id),
                ),

                const Gap(20),
                _SectionHeader(
                  icon: Icons.notes_outlined,
                  title: 'Notes',
                ),
                const Gap(12),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Add notes about this contact...',
                    alignLabelWithHint: true,
                  ),
                ),

                const Gap(20),
                _SectionHeader(
                  icon: Icons.settings_outlined,
                  title: 'Options',
                ),
                const Gap(8),
                // Consent toggles
                _ConsentToggle(
                  title: 'Save to device contacts',
                  subtitle: 'Add this person to your phone\'s contacts',
                  icon: Icons.contact_phone_outlined,
                  value: reviewState.draft.addToDeviceContacts,
                  onChanged: (v) =>
                      ref.read(reviewProvider.notifier).toggleAddToContacts(v),
                ),
                const Gap(4),
                _ConsentToggle(
                  title: 'Send follow-up email',
                  subtitle:
                      'Send an automated email after saving (requires consent)',
                  icon: Icons.email_outlined,
                  value: reviewState.draft.sendFollowUpEmail,
                  onChanged: (v) =>
                      ref.read(reviewProvider.notifier).toggleSendEmail(v),
                ),

                const Gap(32),
                ElevatedButton(
                  onPressed: reviewState.isSaving ? null : _save,
                  child: const Text('Save Contact'),
                ),
                const Gap(12),
                OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
                const Gap(32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const Gap(8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _ConsentToggle extends StatelessWidget {
  const _ConsentToggle({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        )),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        secondary: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
        dense: true,
      ),
    );
  }
}

class _EventSelector extends ConsumerWidget {
  const _EventSelector({
    required this.selectedEventId,
    required this.onEventSelected,
  });

  final String? selectedEventId;
  final ValueChanged<String?> onEventSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsListProvider);
    final theme = Theme.of(context);

    final selectedEvent = eventsAsync.maybeWhen(
      data: (events) =>
          events.where((e) => e.id == selectedEventId).firstOrNull,
      orElse: () => null,
    );

    return InkWell(
      onTap: () => EventPickerBottomSheet.show(
        context,
        selectedEventId: selectedEventId,
        onEventSelected: onEventSelected,
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        ),
        child: Row(
          children: [
            Icon(
              Icons.event,
              color: selectedEvent != null
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const Gap(12),
            Expanded(
              child: Text(
                selectedEvent?.name ?? 'Select an event (optional)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selectedEvent != null
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _RawTextCard extends StatelessWidget {
  const _RawTextCard({required this.rawText});

  final String rawText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.text_snippet_outlined,
                    size: 16, color: theme.colorScheme.primary),
                const Gap(6),
                Text(
                  'Raw OCR Text',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Gap(8),
            SelectableText(
              rawText,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                height: 1.4,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
