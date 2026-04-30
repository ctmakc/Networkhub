import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact_models.freezed.dart';
part 'contact_models.g.dart';

@freezed
class Contact with _$Contact {
  const factory Contact({
    required String id,
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
    String? templateId,
    @Default(false) bool addToDeviceContacts,
    @Default(false) bool sendFollowUpEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default([]) List<Interaction> interactions,
    ProfileDiscovery? profileDiscovery,
  }) = _Contact;

  const Contact._();

  String get fullName {
    final parts = [firstName, lastName].whereType<String>().join(' ');
    return parts.isNotEmpty ? parts : 'Unknown Contact';
  }

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);
}

@freezed
class Interaction with _$Interaction {
  const factory Interaction({
    required String id,
    required String contactId,
    required String type,
    required String description,
    DateTime? occurredAt,
    DateTime? createdAt,
  }) = _Interaction;

  factory Interaction.fromJson(Map<String, dynamic> json) =>
      _$InteractionFromJson(json);
}

@freezed
class Event with _$Event {
  const factory Event({
    required String id,
    required String name,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    DateTime? createdAt,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

@freezed
class Template with _$Template {
  const factory Template({
    required String id,
    required String name,
    required String subject,
    required String body,
    @Default(false) bool isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Template;

  factory Template.fromJson(Map<String, dynamic> json) =>
      _$TemplateFromJson(json);
}

@freezed
class EmailJob with _$EmailJob {
  const factory EmailJob({
    required String id,
    required String contactId,
    required String templateId,
    required EmailJobStatus status,
    String? errorMessage,
    DateTime? scheduledAt,
    DateTime? sentAt,
    DateTime? createdAt,
  }) = _EmailJob;

  factory EmailJob.fromJson(Map<String, dynamic> json) =>
      _$EmailJobFromJson(json);
}

enum EmailJobStatus { pending, processing, sent, failed, cancelled }

@freezed
class ProfileDiscovery with _$ProfileDiscovery {
  const factory ProfileDiscovery({
    String? linkedinUrl,
    String? twitterHandle,
    String? githubUsername,
    String? bio,
    String? photoUrl,
    DateTime? lastUpdated,
  }) = _ProfileDiscovery;

  factory ProfileDiscovery.fromJson(Map<String, dynamic> json) =>
      _$ProfileDiscoveryFromJson(json);
}
