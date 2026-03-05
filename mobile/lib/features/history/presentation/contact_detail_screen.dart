import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:networkhub/features/cloud_sync/data/contact_models.dart';
import 'package:networkhub/features/history/providers/history_provider.dart';
import 'package:networkhub/features/messaging/presentation/email_preview_screen.dart';
import 'package:networkhub/shared/widgets/error_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDetailScreen extends ConsumerWidget {
  const ContactDetailScreen({super.key, required this.contactId});

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactAsync = ref.watch(contactDetailProvider(contactId));
    final interactionsAsync =
        ref.watch(contactInteractionsProvider(contactId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: contactAsync.maybeWhen(
          data: (c) => Text(c.fullName),
          orElse: () => const Text('Contact'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
            tooltip: 'Edit contact',
          ),
        ],
      ),
      body: contactAsync.when(
        data: (contact) => _ContactDetailBody(
          contact: contact,
          interactionsAsync: interactionsAsync,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: theme.colorScheme.error),
              const Gap(16),
              const Text('Failed to load contact'),
              const Gap(16),
              OutlinedButton(
                onPressed: () =>
                    ref.invalidate(contactDetailProvider(contactId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactDetailBody extends ConsumerWidget {
  const _ContactDetailBody({
    required this.contact,
    required this.interactionsAsync,
  });

  final Contact contact;
  final AsyncValue<List<Interaction>> interactionsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Avatar and name header
        _ContactHeader(contact: contact),
        const Gap(24),

        // Contact info
        _InfoSection(
          title: 'Contact Information',
          items: [
            if (contact.email != null)
              _InfoItem(
                icon: Icons.email_outlined,
                label: 'Email',
                value: contact.email!,
                onTap: () => _launchUrl('mailto:${contact.email}'),
              ),
            if (contact.phone != null)
              _InfoItem(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: contact.phone!,
                onTap: () => _launchUrl('tel:${contact.phone}'),
              ),
            if (contact.website != null)
              _InfoItem(
                icon: Icons.language_outlined,
                label: 'Website',
                value: contact.website!,
                onTap: () => _launchUrl(contact.website!),
              ),
            if (contact.linkedinUrl != null)
              _InfoItem(
                icon: Icons.link,
                label: 'LinkedIn',
                value: contact.linkedinUrl!,
                onTap: () => _launchUrl(contact.linkedinUrl!),
              ),
            if (contact.address != null)
              _InfoItem(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: contact.address!,
              ),
          ],
        ),

        if (contact.company != null || contact.title != null) ...[
          const Gap(16),
          _InfoSection(
            title: 'Professional',
            items: [
              if (contact.title != null)
                _InfoItem(
                  icon: Icons.work_outline,
                  label: 'Title',
                  value: contact.title!,
                ),
              if (contact.company != null)
                _InfoItem(
                  icon: Icons.business_outlined,
                  label: 'Company',
                  value: contact.company!,
                ),
            ],
          ),
        ],

        if (contact.tags.isNotEmpty) ...[
          const Gap(16),
          Text(
            'Tags',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: contact.tags
                .map((tag) => Chip(
                      label: Text(tag),
                      visualDensity: VisualDensity.compact,
                      labelStyle: theme.textTheme.labelSmall,
                    ))
                .toList(),
          ),
        ],

        if (contact.notes != null) ...[
          const Gap(16),
          _InfoSection(
            title: 'Notes',
            items: [
              _InfoItem(
                icon: Icons.notes_outlined,
                label: '',
                value: contact.notes!,
              ),
            ],
          ),
        ],

        // Action buttons
        const Gap(24),
        _ActionButtons(contact: contact),

        // Profile discovery section
        if (contact.profileDiscovery != null) ...[
          const Gap(24),
          _ProfileDiscoverySection(discovery: contact.profileDiscovery!),
        ],

        // Interactions timeline
        const Gap(24),
        _InteractionsSection(interactionsAsync: interactionsAsync),

        const Gap(32),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri)) return;
  }
}

class _ContactHeader extends StatelessWidget {
  const _ContactHeader({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _getInitials();

    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            initials,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contact.fullName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (contact.title != null)
                Text(
                  contact.title!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (contact.company != null)
                Text(
                  contact.company!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _getInitials() {
    final first = contact.firstName?.isNotEmpty == true
        ? contact.firstName![0].toUpperCase()
        : '';
    final last = contact.lastName?.isNotEmpty == true
        ? contact.lastName![0].toUpperCase()
        : '';
    return '$first$last'.isNotEmpty ? '$first$last' : '?';
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.items});

  final String title;
  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(8),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: items.indexed
                .map((e) => Column(
                      children: [
                        e.$2,
                        if (e.$1 < items.length - 1) const Divider(height: 1),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, size: 20, color: theme.colorScheme.primary),
      title: label.isNotEmpty
          ? Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      subtitle: Text(
        value,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: onTap != null ? theme.colorScheme.primary : null,
          decoration:
              onTap != null ? TextDecoration.underline : null,
        ),
      ),
      trailing:
          onTap != null ? const Icon(Icons.open_in_new, size: 16) : null,
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (contact.email != null) ...[
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.email_outlined),
              label: const Text('Send Email'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EmailPreviewScreen(contact: contact),
                  ),
                );
              },
            ),
          ),
          const Gap(12),
        ],
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.phone_outlined),
            label: const Text('Call'),
            onPressed: contact.phone != null
                ? () => launchUrl(Uri.parse('tel:${contact.phone}'))
                : null,
          ),
        ),
      ],
    );
  }
}

class _ProfileDiscoverySection extends StatelessWidget {
  const _ProfileDiscoverySection({required this.discovery});

  final ProfileDiscovery discovery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Discovery',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(8),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (discovery.bio != null) ...[
                  Text(
                    discovery.bio!,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Gap(8),
                ],
                Row(
                  children: [
                    if (discovery.linkedinUrl != null)
                      _SocialButton(
                        label: 'LinkedIn',
                        icon: Icons.link,
                        url: discovery.linkedinUrl!,
                      ),
                    if (discovery.twitterHandle != null)
                      _SocialButton(
                        label: '@${discovery.twitterHandle}',
                        icon: Icons.alternate_email,
                        url: 'https://twitter.com/${discovery.twitterHandle}',
                      ),
                    if (discovery.githubUsername != null)
                      _SocialButton(
                        label: discovery.githubUsername!,
                        icon: Icons.code,
                        url: 'https://github.com/${discovery.githubUsername}',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.url,
  });

  final String label;
  final IconData icon;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 16),
        label: Text(label),
        onPressed: () => launchUrl(Uri.parse(url)),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _InteractionsSection extends StatelessWidget {
  const _InteractionsSection({required this.interactionsAsync});

  final AsyncValue<List<Interaction>> interactionsAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interaction History',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(8),
        interactionsAsync.when(
          data: (interactions) {
            if (interactions.isEmpty) {
              return Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No interactions yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: interactions
                  .map((interaction) => _InteractionTile(
                        interaction: interaction,
                      ))
                  .toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _InteractionTile extends StatelessWidget {
  const _InteractionTile({required this.interaction});

  final Interaction interaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary,
              ),
            ),
            Container(
              width: 2,
              height: 40,
              color: theme.colorScheme.outlineVariant,
            ),
          ],
        ),
        const Gap(12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  interaction.description,
                  style: theme.textTheme.bodyMedium,
                ),
                if (interaction.occurredAt != null)
                  Text(
                    _formatDate(interaction.occurredAt!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
