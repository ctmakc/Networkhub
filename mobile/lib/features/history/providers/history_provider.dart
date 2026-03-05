import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networkhub/features/cloud_sync/data/contact_models.dart';
import 'package:networkhub/features/cloud_sync/data/contacts_repository.dart';

class HistoryFilter {
  final String searchQuery;
  final String? selectedTag;
  final String? selectedEventId;

  const HistoryFilter({
    this.searchQuery = '',
    this.selectedTag,
    this.selectedEventId,
  });

  HistoryFilter copyWith({
    String? searchQuery,
    String? selectedTag,
    String? selectedEventId,
    bool clearTag = false,
    bool clearEvent = false,
  }) {
    return HistoryFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTag: clearTag ? null : selectedTag ?? this.selectedTag,
      selectedEventId:
          clearEvent ? null : selectedEventId ?? this.selectedEventId,
    );
  }

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      selectedTag != null ||
      selectedEventId != null;
}

final historyFilterProvider =
    StateProvider<HistoryFilter>((ref) => const HistoryFilter());

final contactsListProvider =
    FutureProvider.autoDispose<List<Contact>>((ref) async {
  final filter = ref.watch(historyFilterProvider);
  final repo = ref.read(contactsRepositoryProvider);

  return repo.listContacts(
    search: filter.searchQuery.isNotEmpty ? filter.searchQuery : null,
    tag: filter.selectedTag,
    eventId: filter.selectedEventId,
  );
});

final contactDetailProvider =
    FutureProvider.autoDispose.family<Contact, String>((ref, contactId) async {
  final repo = ref.read(contactsRepositoryProvider);
  return repo.getContact(contactId);
});

final contactInteractionsProvider =
    FutureProvider.autoDispose.family<List<Interaction>, String>(
  (ref, contactId) async {
    final repo = ref.read(contactsRepositoryProvider);
    return repo.getInteractions(contactId);
  },
);
