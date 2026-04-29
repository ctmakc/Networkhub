import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:networkhub/features/history/providers/history_provider.dart';
import 'package:networkhub/shared/widgets/contact_list_tile.dart';
import 'package:networkhub/shared/widgets/pending_sync_badge.dart';
import 'package:networkhub/shared/widgets/shimmer_loading.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(historyFilterProvider);
    final contactsAsync = ref.watch(contactsListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Contacts'),
            const Gap(8),
            const PendingSyncBadge(),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: filter.hasActiveFilters,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
            tooltip: 'Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search contacts...',
              leading: const Icon(Icons.search),
              trailing: [
                if (filter.searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(historyFilterProvider.notifier).update(
                            (s) => s.copyWith(searchQuery: ''),
                          );
                    },
                  ),
              ],
              onChanged: (query) {
                ref.read(historyFilterProvider.notifier).update(
                      (s) => s.copyWith(searchQuery: query),
                    );
              },
              elevation: const MaterialStatePropertyAll(1),
            ),
          ),

          // Filter chips
          if (_showFilters) ...[
            const Gap(8),
            _FilterChipsRow(filter: filter),
          ],

          const Gap(8),

          // Contacts list
          Expanded(
            child: contactsAsync.when(
              data: (contacts) {
                if (contacts.isEmpty) {
                  return _EmptyState(
                    hasFilter: filter.hasActiveFilters,
                    onClearFilters: () {
                      _searchController.clear();
                      ref.read(historyFilterProvider.notifier).state =
                          const HistoryFilter();
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(contactsListProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ContactListTile(
                          contact: contact,
                          onTap: () => context.push('/contacts/${contact.id}'),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const ContactListShimmer(),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const Gap(16),
                    Text(
                      'Failed to load contacts',
                      style: theme.textTheme.titleMedium,
                    ),
                    const Gap(8),
                    Text(
                      e.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(16),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(contactsListProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipsRow extends ConsumerWidget {
  const _FilterChipsRow({required this.filter});

  final HistoryFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(historyFilterProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (filter.selectedTag != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('Tag: ${filter.selectedTag}'),
                selected: true,
                onSelected: (_) =>
                    notifier.update((s) => s.copyWith(clearTag: true)),
              ),
            ),
          if (filter.selectedEventId != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('Event filter active'),
                selected: true,
                onSelected: (_) =>
                    notifier.update((s) => s.copyWith(clearEvent: true)),
              ),
            ),
          // Tag quick filters
          for (final tag in ['prospect', 'customer', 'partner', 'investor'])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(tag),
                selected: filter.selectedTag == tag,
                onSelected: (selected) {
                  notifier.update(
                    (s) => selected
                        ? s.copyWith(selectedTag: tag)
                        : s.copyWith(clearTag: true),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasFilter,
    required this.onClearFilters,
  });

  final bool hasFilter;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilter ? Icons.search_off : Icons.people_outline,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const Gap(16),
          Text(
            hasFilter ? 'No contacts match your search' : 'No contacts yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(8),
          Text(
            hasFilter
                ? 'Try different search terms or clear filters'
                : 'Scan a business card to add your first contact',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (hasFilter) ...[
            const Gap(16),
            OutlinedButton(
              onPressed: onClearFilters,
              child: const Text('Clear filters'),
            ),
          ],
        ],
      ),
    );
  }
}
