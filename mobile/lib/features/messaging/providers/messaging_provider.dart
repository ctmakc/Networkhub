import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networkhub/features/cloud_sync/data/contact_models.dart';
import 'package:networkhub/features/cloud_sync/data/contacts_repository.dart';
import 'package:networkhub/features/cloud_sync/data/templates_repository.dart';

enum MessagingStatus { idle, sending, sent, error }

class MessagingState {
  final MessagingStatus status;
  final String? errorMessage;
  final EmailJob? sentJob;
  final Template? selectedTemplate;
  final bool consentGiven;

  const MessagingState({
    this.status = MessagingStatus.idle,
    this.errorMessage,
    this.sentJob,
    this.selectedTemplate,
    this.consentGiven = false,
  });

  MessagingState copyWith({
    MessagingStatus? status,
    String? errorMessage,
    EmailJob? sentJob,
    Template? selectedTemplate,
    bool? consentGiven,
  }) {
    return MessagingState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      sentJob: sentJob ?? this.sentJob,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      consentGiven: consentGiven ?? this.consentGiven,
    );
  }

  bool get isSending => status == MessagingStatus.sending;
  bool get isSent => status == MessagingStatus.sent;
}

final messagingProvider =
    StateNotifierProvider.autoDispose<MessagingNotifier, MessagingState>(
  (ref) => MessagingNotifier(
    ref.read(contactsRepositoryProvider),
    ref.read(templatesRepositoryProvider),
  ),
);

class MessagingNotifier extends StateNotifier<MessagingState> {
  final ContactsRepository _contactsRepo;
  final TemplatesRepository _templatesRepo;

  MessagingNotifier(this._contactsRepo, this._templatesRepo)
      : super(const MessagingState());

  void setTemplate(Template template) {
    state = state.copyWith(selectedTemplate: template);
  }

  void setConsent(bool consent) {
    state = state.copyWith(consentGiven: consent);
  }

  Future<void> sendEmail({
    required String contactId,
    required String templateId,
  }) async {
    if (!state.consentGiven) {
      state = state.copyWith(
        status: MessagingStatus.error,
        errorMessage: 'Please confirm consent before sending',
      );
      return;
    }

    state = state.copyWith(status: MessagingStatus.sending, errorMessage: null);
    try {
      final job = await _contactsRepo.sendEmail(
        contactId: contactId,
        templateId: templateId,
        consentGiven: state.consentGiven,
      );
      state = state.copyWith(
        status: MessagingStatus.sent,
        sentJob: job,
      );
    } catch (e) {
      state = state.copyWith(
        status: MessagingStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<EmailJob?> checkJobStatus(String jobId) async {
    try {
      return await _contactsRepo.getEmailJob(jobId);
    } catch (_) {
      return null;
    }
  }

  void reset() {
    state = const MessagingState();
  }
}
