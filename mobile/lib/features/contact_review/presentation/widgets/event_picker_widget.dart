import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:networkhub/features/cloud_sync/data/contact_models.dart';
import 'package:networkhub/features/cloud_sync/data/events_repository.dart';

class EventPickerWidget extends ConsumerStatefulWidget {
  const EventPickerWidget({
    super.key,
    required this.selectedEventId,
    required this.onEventSelected,
  });

  final String? selectedEventId;
  final ValueChanged<String?> onEventSelected;

  @override
  ConsumerState<EventPickerWidget> createState() => _EventPickerWidgetState();
}

class _EventPickerWidgetState extends ConsumerState<EventPickerWidget> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsListProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search events...',
            prefixIcon: Icon(Icons.search, size: 18),
            isDense: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
        ),
        const Gap(8),

        // Events list
        eventsAsync.when(
          data: (events) {
            final filtered = _searchQuery.isEmpty
                ? events
                : events
                    .where((e) =>
                        e.name.toLowerCase().contains(_searchQuery) ||
                        (e.location ?? '').toLowerCase().contains(_searchQuery))
                    .toList();

            if (filtered.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No events found',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }

            return Column(
              children: [
                // Clear selection option
                if (widget.selectedEventId != null)
                  ListTile(
                    leading:
                        const Icon(Icons.clear, color: Colors.grey),
                    title: const Text('No event'),
                    contentPadding: EdgeInsets.zero,
                    selected: widget.selectedEventId == null,
                    onTap: () => widget.onEventSelected(null),
                    dense: true,
                  ),
                ...filtered.map(
                  (event) => _EventTile(
                    event: event,
                    isSelected: event.id == widget.selectedEventId,
                    onTap: () => widget.onEventSelected(event.id),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Failed to load events',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({
    required this.event,
    required this.isSelected,
    required this.onTap,
  });

  final Event event;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        Icons.event,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        event.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
      ),
      subtitle: event.location != null
          ? Text(event.location!, style: theme.textTheme.bodySmall)
          : null,
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      contentPadding: EdgeInsets.zero,
      dense: true,
      onTap: onTap,
    );
  }
}

/// Bottom sheet for selecting an event
class EventPickerBottomSheet extends ConsumerWidget {
  const EventPickerBottomSheet({
    super.key,
    required this.selectedEventId,
    required this.onEventSelected,
  });

  final String? selectedEventId;
  final ValueChanged<String?> onEventSelected;

  static Future<void> show(
    BuildContext context, {
    required String? selectedEventId,
    required ValueChanged<String?> onEventSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EventPickerBottomSheet(
        selectedEventId: selectedEventId,
        onEventSelected: onEventSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
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
                Icon(Icons.event, color: theme.colorScheme.primary),
                const Gap(8),
                Text(
                  'Select Event',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: EventPickerWidget(
                selectedEventId: selectedEventId,
                onEventSelected: (id) {
                  onEventSelected(id);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
