// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContactImpl _$$ContactImplFromJson(Map<String, dynamic> json) =>
    _$ContactImpl(
      id: json['id'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      title: json['title'] as String?,
      website: json['website'] as String?,
      notes: json['notes'] as String?,
      address: json['address'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      eventId: json['event_id'] as String?,
      templateId: json['template_id'] as String?,
      addToDeviceContacts: json['add_to_device_contacts'] as bool? ?? false,
      sendFollowUpEmail: json['send_follow_up_email'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      interactions: (json['interactions'] as List<dynamic>?)
              ?.map((e) => Interaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      profileDiscovery: json['profile_discovery'] == null
          ? null
          : ProfileDiscovery.fromJson(
              json['profile_discovery'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ContactImplToJson(_$ContactImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
      'company': instance.company,
      'title': instance.title,
      'website': instance.website,
      'notes': instance.notes,
      'address': instance.address,
      'linkedin_url': instance.linkedinUrl,
      'tags': instance.tags,
      'event_id': instance.eventId,
      'template_id': instance.templateId,
      'add_to_device_contacts': instance.addToDeviceContacts,
      'send_follow_up_email': instance.sendFollowUpEmail,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'interactions': instance.interactions.map((e) => e.toJson()).toList(),
      'profile_discovery': instance.profileDiscovery?.toJson(),
    };

_$InteractionImpl _$$InteractionImplFromJson(Map<String, dynamic> json) =>
    _$InteractionImpl(
      id: json['id'] as String,
      contactId: json['contact_id'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      occurredAt: json['occurred_at'] == null
          ? null
          : DateTime.parse(json['occurred_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$InteractionImplToJson(_$InteractionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contact_id': instance.contactId,
      'type': instance.type,
      'description': instance.description,
      'occurred_at': instance.occurredAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
    };

_$EventImpl _$$EventImplFromJson(Map<String, dynamic> json) => _$EventImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String?,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      description: json['description'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$EventImplToJson(_$EventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location': instance.location,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'description': instance.description,
      'created_at': instance.createdAt?.toIso8601String(),
    };

_$TemplateImpl _$$TemplateImplFromJson(Map<String, dynamic> json) =>
    _$TemplateImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      subject: json['subject'] as String,
      body: json['body'] as String,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$TemplateImplToJson(_$TemplateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'subject': instance.subject,
      'body': instance.body,
      'is_default': instance.isDefault,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$EmailJobImpl _$$EmailJobImplFromJson(Map<String, dynamic> json) =>
    _$EmailJobImpl(
      id: json['id'] as String,
      contactId: json['contact_id'] as String,
      templateId: json['template_id'] as String,
      status: $enumDecode(_$EmailJobStatusEnumMap, json['status']),
      errorMessage: json['error_message'] as String?,
      scheduledAt: json['scheduled_at'] == null
          ? null
          : DateTime.parse(json['scheduled_at'] as String),
      sentAt: json['sent_at'] == null
          ? null
          : DateTime.parse(json['sent_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$EmailJobImplToJson(_$EmailJobImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contact_id': instance.contactId,
      'template_id': instance.templateId,
      'status': _$EmailJobStatusEnumMap[instance.status]!,
      'error_message': instance.errorMessage,
      'scheduled_at': instance.scheduledAt?.toIso8601String(),
      'sent_at': instance.sentAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$EmailJobStatusEnumMap = {
  EmailJobStatus.pending: 'pending',
  EmailJobStatus.processing: 'processing',
  EmailJobStatus.sent: 'sent',
  EmailJobStatus.failed: 'failed',
  EmailJobStatus.cancelled: 'cancelled',
};

_$ProfileDiscoveryImpl _$$ProfileDiscoveryImplFromJson(
        Map<String, dynamic> json) =>
    _$ProfileDiscoveryImpl(
      linkedinUrl: json['linkedin_url'] as String?,
      twitterHandle: json['twitter_handle'] as String?,
      githubUsername: json['github_username'] as String?,
      bio: json['bio'] as String?,
      photoUrl: json['photo_url'] as String?,
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
    );

Map<String, dynamic> _$$ProfileDiscoveryImplToJson(
        _$ProfileDiscoveryImpl instance) =>
    <String, dynamic>{
      'linkedin_url': instance.linkedinUrl,
      'twitter_handle': instance.twitterHandle,
      'github_username': instance.githubUsername,
      'bio': instance.bio,
      'photo_url': instance.photoUrl,
      'last_updated': instance.lastUpdated?.toIso8601String(),
    };
