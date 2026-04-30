import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:networkhub/core/config/app_config.dart';
import 'package:networkhub/features/auth/providers/auth_provider.dart';
import 'package:networkhub/features/cloud_sync/data/templates_repository.dart';
import 'package:networkhub/features/settings/providers/settings_provider.dart';
import 'package:networkhub/shared/widgets/confirmation_dialog.dart';
import 'package:networkhub/shared/widgets/error_snackbar.dart';
import 'package:networkhub/shared/widgets/loading_overlay.dart';
import 'package:networkhub/shared/widgets/pending_sync_badge.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _signatureCtrl;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _nameCtrl = TextEditingController(text: settings.name);
    _signatureCtrl = TextEditingController(text: settings.signature);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _signatureCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final user = ref.watch(authProvider).valueOrNull;
    final theme = Theme.of(context);

    ref.listen<SettingsState>(settingsProvider, (prev, next) {
      if (next.isSaved) {
        showSuccessSnackbar(context, 'Settings saved');
        ref.read(settingsProvider.notifier).clearSavedState();
      }
      if (next.errorMessage != null) {
        showErrorSnackbar(context, next.errorMessage!);
      }
    });

    return LoadingOverlay(
      isLoading: settings.isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text('Settings'),
              const Gap(8),
              const PendingSyncBadge(),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User profile section
            _SectionCard(
              title: 'Your Profile',
              icon: Icons.person_outline,
              children: [
                if (user?.email != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.email_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Email'),
                      subtitle: Text(user!.email),
                      dense: true,
                    ),
                  ),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).updateName(v),
                ),
                const Gap(12),
                TextFormField(
                  controller: _signatureCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Email signature',
                    hintText: 'Best regards,\nYour Name',
                    alignLabelWithHint: true,
                  ),
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).updateSignature(v),
                ),
                const Gap(12),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(settingsProvider.notifier).saveSettings(),
                  child: const Text('Save Profile'),
                ),
              ],
            ),

            const Gap(16),

            // Default template
            _SectionCard(
              title: 'Email Templates',
              icon: Icons.email_outlined,
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final templatesAsync = ref.watch(templatesListProvider);
                    return templatesAsync.when(
                      data: (templates) {
                        if (templates.isEmpty) {
                          return Text(
                            'No templates yet. Templates are created on the web dashboard.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        }

                        return DropdownButtonFormField<String>(
                          value: settings.defaultTemplateId,
                          hint: const Text('Select default template'),
                          decoration: const InputDecoration(
                            labelText: 'Default template',
                            prefixIcon:
                                Icon(Icons.auto_awesome_outlined),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('None'),
                            ),
                            ...templates.map(
                              (t) => DropdownMenuItem<String>(
                                value: t.id,
                                child: Text(t.name),
                              ),
                            ),
                          ],
                          onChanged: (id) => ref
                              .read(settingsProvider.notifier)
                              .updateDefaultTemplate(id),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text('Failed to load templates'),
                    );
                  },
                ),
              ],
            ),

            const Gap(16),

            // App info section
            _SectionCard(
              title: 'App',
              icon: Icons.info_outline,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.api, color: theme.colorScheme.primary),
                  title: const Text('API Server'),
                  subtitle: Text(AppConfig.baseUrl),
                  dense: true,
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.info,
                      color: theme.colorScheme.primary),
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0+1'),
                  dense: true,
                ),
              ],
            ),

            const Gap(16),

            // Logout button
            OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
              onPressed: () async {
                final confirmed = await ConfirmationDialog.show(
                  context,
                  title: 'Sign out?',
                  message:
                      'You will need to sign in again. Any unsynced contacts will be lost.',
                  confirmLabel: 'Sign out',
                  isDangerous: true,
                );

                if (confirmed == true && context.mounted) {
                  await ref.read(settingsProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                }
              },
            ),

            const Gap(32),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const Gap(8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Gap(16),
            ...children,
          ],
        ),
      ),
    );
  }
}
