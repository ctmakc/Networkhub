import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:networkhub/core/storage/offline_queue.dart';

part 'scan_models.freezed.dart';

@freezed
class DraftContact with _$DraftContact {
  const factory DraftContact({
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
    @Default([]) List<String> tags,
    String? eventId,
    @Default('') String rawOcrText,
    String? rawVcard,
    @Default(true) bool addToDeviceContacts,
    @Default(false) bool sendFollowUpEmail,
    String? templateId,
  }) = _DraftContact;

  const DraftContact._();

  String get fullName {
    final parts = [firstName, lastName].whereType<String>().join(' ');
    return parts.isNotEmpty ? parts : '';
  }

  bool get hasEmail => email != null && email!.isNotEmpty;
  bool get hasPhone => phone != null && phone!.isNotEmpty;

  ContactDraft toContactDraft(String id) {
    return ContactDraft(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      company: company,
      title: title,
      website: website,
      notes: notes,
      tags: tags,
      eventId: eventId,
      rawOcrText: rawOcrText,
      rawVcard: rawVcard,
      addToDeviceContacts: addToDeviceContacts,
      sendFollowUpEmail: sendFollowUpEmail,
      templateId: templateId,
      address: address,
      linkedinUrl: linkedinUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'company': company,
        'title': title,
        'website': website,
        'notes': notes,
        'address': address,
        'linkedin_url': linkedinUrl,
        'tags': tags,
        'event_id': eventId,
        'add_to_device_contacts': addToDeviceContacts,
        'send_follow_up_email': sendFollowUpEmail,
        'template_id': templateId,
      };
}

enum ScanMode { camera, qrCode }
