import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networkhub/features/cloud_sync/data/contact_models.dart';
import 'package:networkhub/features/cloud_sync/data/contacts_repository.dart';
import 'package:networkhub/features/cloud_sync/sync_service.dart';
import 'package:networkhub/features/device_contacts/device_contacts_service.dart';
import 'package:networkhub/features/scan/data/scan_models.dart';

enum ReviewStatus { editing, saving, saved, error }

class ReviewState {
  final DraftContact draft;
  final ReviewStatus status;
  final String? errorMessage;
  final String? savedContactId;

  const ReviewState({
    required this.draft,
    this.status = ReviewStatus.editing,
    this.errorMessage,
    this.savedContactId,
  });

  ReviewState copyWith({
    DraftContact? draft,
    ReviewStatus? status,
    String? errorMessage,
    String? savedContactId,
  }) {
    return ReviewState(
      draft: draft ?? this.draft,
      status: status ?? this.status,
      errorMessage: errorMessage,
      savedContactId: savedContactId ?? this.savedContactId,
    );
  }

  bool get isSaving => status == ReviewStatus.saving;
  bool get isSaved => status == ReviewStatus.saved;
}

final reviewProvider =
    StateNotifierProvider.autoDispose<ReviewNotifier, ReviewState>(
  (ref) => ReviewNotifier(
    ref.read(contactsRepositoryProvider),
    ref.read(syncServiceProvider),
    ref.read(deviceContactsServiceProvider),
  ),
);

class ReviewNotifier extends StateNotifier<ReviewState> {
  final ContactsRepository _contactsRepo;
  final SyncService _syncService;
  final DeviceContactsService _deviceContactsService;

  ReviewNotifier(
    this._contactsRepo,
    this._syncService,
    this._deviceContactsService,
  ) : super(ReviewState(draft: const DraftContact()));

  void loadDraft(DraftContact draft) {
    state = ReviewState(draft: draft);
  }

  void updateField({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? company,
    String? title,
    String? website,
    String? notes,
    String? address,
    String? linkedinUrl,
    List<String>? tags,
    String? eventId,
    bool? addToDeviceContacts,
    bool? sendFollowUpEmail,
    String? templateId,
  }) {
    state = state.copyWith(
      draft: state.draft.copyWith(
        firstName: firstName ?? state.draft.firstName,
        lastName: lastName ?? state.draft.lastName,
        email: email ?? state.draft.email,
        phone: phone ?? state.draft.phone,
        company: company ?? state.draft.company,
        title: title ?? state.draft.title,
        website: website ?? state.draft.website,
        notes: notes ?? state.draft.notes,
        address: address ?? state.draft.address,
        linkedinUrl: linkedinUrl ?? state.draft.linkedinUrl,
        tags: tags ?? state.draft.tags,
        eventId: eventId ?? state.draft.eventId,
        addToDeviceContacts:
            addToDeviceContacts ?? state.draft.addToDeviceContacts,
        sendFollowUpEmail:
            sendFollowUpEmail ?? state.draft.sendFollowUpEmail,
        templateId: templateId ?? state.draft.templateId,
      ),
    );
  }

  void setTags(List<String> tags) {
    state = state.copyWith(draft: state.draft.copyWith(tags: tags));
  }

  void toggleAddToContacts(bool value) {
    state = state.copyWith(
      draft: state.draft.copyWith(addToDeviceContacts: value),
    );
  }

  void toggleSendEmail(bool value) {
    state = state.copyWith(
      draft: state.draft.copyWith(sendFollowUpEmail: value),
    );
  }

  Future<bool> saveContact() async {
    state = state.copyWith(status: ReviewStatus.saving, errorMessage: null);
    try {
      // Try to save to cloud
      final savedContact = await _syncService.saveDraft(state.draft);

      // If addToDeviceContacts is true, create device contact
      if (state.draft.addToDeviceContacts) {
        try {
          await _deviceContactsService.createOrUpdateContact(state.draft);
        } catch (e) {
          // Device contact creation failure is non-fatal
        }
      }

      state = state.copyWith(
        status: ReviewStatus.saved,
        savedContactId: savedContact.id,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: ReviewStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void resetStatus() {
    state = state.copyWith(status: ReviewStatus.editing, errorMessage: null);
  }
}
