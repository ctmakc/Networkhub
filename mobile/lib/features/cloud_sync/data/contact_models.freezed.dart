// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This is only meant to be used by code generators.');

/// @nodoc
mixin _$Contact {
  String get id => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get company => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get linkedinUrl => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String? get eventId => throw _privateConstructorUsedError;
  String? get templateId => throw _privateConstructorUsedError;
  bool get addToDeviceContacts => throw _privateConstructorUsedError;
  bool get sendFollowUpEmail => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  List<Interaction> get interactions => throw _privateConstructorUsedError;
  ProfileDiscovery? get profileDiscovery => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ContactCopyWith<Contact> get copyWith => throw _privateConstructorUsedError;
}

abstract class $ContactCopyWith<$Res> {
  factory $ContactCopyWith(Contact value, $Res Function(Contact) then) =
      _$ContactCopyWithImpl<$Res, Contact>;
  @useResult
  $Res call({
    String id,
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
    List<String> tags,
    String? eventId,
    String? templateId,
    bool addToDeviceContacts,
    bool sendFollowUpEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Interaction> interactions,
    ProfileDiscovery? profileDiscovery,
  });

  $ProfileDiscoveryCopyWith<$Res>? get profileDiscovery;
}

class _$ContactCopyWithImpl<$Res, $Val extends Contact>
    implements $ContactCopyWith<$Res> {
  _$ContactCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? company = freezed,
    Object? title = freezed,
    Object? website = freezed,
    Object? notes = freezed,
    Object? address = freezed,
    Object? linkedinUrl = freezed,
    Object? tags = null,
    Object? eventId = freezed,
    Object? templateId = freezed,
    Object? addToDeviceContacts = null,
    Object? sendFollowUpEmail = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? interactions = null,
    Object? profileDiscovery = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      firstName: freezed == firstName ? _value.firstName : firstName as String?,
      lastName: freezed == lastName ? _value.lastName : lastName as String?,
      email: freezed == email ? _value.email : email as String?,
      phone: freezed == phone ? _value.phone : phone as String?,
      company: freezed == company ? _value.company : company as String?,
      title: freezed == title ? _value.title : title as String?,
      website: freezed == website ? _value.website : website as String?,
      notes: freezed == notes ? _value.notes : notes as String?,
      address: freezed == address ? _value.address : address as String?,
      linkedinUrl:
          freezed == linkedinUrl ? _value.linkedinUrl : linkedinUrl as String?,
      tags: null == tags ? _value.tags : tags as List<String>,
      eventId: freezed == eventId ? _value.eventId : eventId as String?,
      templateId:
          freezed == templateId ? _value.templateId : templateId as String?,
      addToDeviceContacts: null == addToDeviceContacts
          ? _value.addToDeviceContacts
          : addToDeviceContacts as bool,
      sendFollowUpEmail: null == sendFollowUpEmail
          ? _value.sendFollowUpEmail
          : sendFollowUpEmail as bool,
      createdAt:
          freezed == createdAt ? _value.createdAt : createdAt as DateTime?,
      updatedAt:
          freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?,
      interactions:
          null == interactions ? _value.interactions : interactions as List<Interaction>,
      profileDiscovery: freezed == profileDiscovery
          ? _value.profileDiscovery
          : profileDiscovery as ProfileDiscovery?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ProfileDiscoveryCopyWith<$Res>? get profileDiscovery {
    if (_value.profileDiscovery == null) return null;
    return $ProfileDiscoveryCopyWith<$Res>(_value.profileDiscovery!, (value) {
      return _then(_value.copyWith(profileDiscovery: value) as $Val);
    });
  }
}

abstract class _$$ContactImplCopyWith<$Res> implements $ContactCopyWith<$Res> {
  factory _$$ContactImplCopyWith(
          _$ContactImpl value, $Res Function(_$ContactImpl) then) =
      __$$ContactImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
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
    List<String> tags,
    String? eventId,
    String? templateId,
    bool addToDeviceContacts,
    bool sendFollowUpEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Interaction> interactions,
    ProfileDiscovery? profileDiscovery,
  });

  @override
  $ProfileDiscoveryCopyWith<$Res>? get profileDiscovery;
}

class __$$ContactImplCopyWithImpl<$Res>
    extends _$ContactCopyWithImpl<$Res, _$ContactImpl>
    implements _$$ContactImplCopyWith<$Res> {
  __$$ContactImplCopyWithImpl(super.value, super.then);

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? company = freezed,
    Object? title = freezed,
    Object? website = freezed,
    Object? notes = freezed,
    Object? address = freezed,
    Object? linkedinUrl = freezed,
    Object? tags = null,
    Object? eventId = freezed,
    Object? templateId = freezed,
    Object? addToDeviceContacts = null,
    Object? sendFollowUpEmail = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? interactions = null,
    Object? profileDiscovery = freezed,
  }) {
    return _then(_$ContactImpl(
      id: null == id ? _value.id : id as String,
      firstName: freezed == firstName ? _value.firstName : firstName as String?,
      lastName: freezed == lastName ? _value.lastName : lastName as String?,
      email: freezed == email ? _value.email : email as String?,
      phone: freezed == phone ? _value.phone : phone as String?,
      company: freezed == company ? _value.company : company as String?,
      title: freezed == title ? _value.title : title as String?,
      website: freezed == website ? _value.website : website as String?,
      notes: freezed == notes ? _value.notes : notes as String?,
      address: freezed == address ? _value.address : address as String?,
      linkedinUrl:
          freezed == linkedinUrl ? _value.linkedinUrl : linkedinUrl as String?,
      tags: null == tags ? _value._tags : tags as List<String>,
      eventId: freezed == eventId ? _value.eventId : eventId as String?,
      templateId:
          freezed == templateId ? _value.templateId : templateId as String?,
      addToDeviceContacts: null == addToDeviceContacts
          ? _value.addToDeviceContacts
          : addToDeviceContacts as bool,
      sendFollowUpEmail: null == sendFollowUpEmail
          ? _value.sendFollowUpEmail
          : sendFollowUpEmail as bool,
      createdAt:
          freezed == createdAt ? _value.createdAt : createdAt as DateTime?,
      updatedAt:
          freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?,
      interactions: null == interactions ? _value._interactions : interactions as List<Interaction>,
      profileDiscovery: freezed == profileDiscovery
          ? _value.profileDiscovery
          : profileDiscovery as ProfileDiscovery?,
    ));
  }
}

@JsonSerializable()
class _$ContactImpl extends _Contact {
  const _$ContactImpl({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.company,
    this.title,
    this.website,
    this.notes,
    this.address,
    this.linkedinUrl,
    final List<String> tags = const [],
    this.eventId,
    this.templateId,
    this.addToDeviceContacts = false,
    this.sendFollowUpEmail = false,
    this.createdAt,
    this.updatedAt,
    final List<Interaction> interactions = const [],
    this.profileDiscovery,
  })  : _tags = tags,
        _interactions = interactions,
        super._();

  factory _$ContactImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContactImplFromJson(json);

  @override
  final String id;
  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final String? company;
  @override
  final String? title;
  @override
  final String? website;
  @override
  final String? notes;
  @override
  final String? address;
  @override
  final String? linkedinUrl;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String? eventId;
  @override
  final String? templateId;
  @override
  @JsonKey()
  final bool addToDeviceContacts;
  @override
  @JsonKey()
  final bool sendFollowUpEmail;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  final List<Interaction> _interactions;
  @override
  @JsonKey()
  List<Interaction> get interactions {
    if (_interactions is EqualUnmodifiableListView) return _interactions;
    return EqualUnmodifiableListView(_interactions);
  }

  @override
  final ProfileDiscovery? profileDiscovery;

  @override
  String toString() {
    return 'Contact(id: $id, firstName: $firstName, lastName: $lastName, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContactImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ContactImplCopyWith<_$ContactImpl> get copyWith =>
      __$$ContactImplCopyWithImpl<_$ContactImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ContactImplToJson(this);
  }
}

abstract class _Contact extends Contact {
  const factory _Contact({
    required final String id,
    final String? firstName,
    final String? lastName,
    final String? email,
    final String? phone,
    final String? company,
    final String? title,
    final String? website,
    final String? notes,
    final String? address,
    final String? linkedinUrl,
    final List<String> tags,
    final String? eventId,
    final String? templateId,
    final bool addToDeviceContacts,
    final bool sendFollowUpEmail,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final List<Interaction> interactions,
    final ProfileDiscovery? profileDiscovery,
  }) = _$ContactImpl;

  const _Contact._() : super._();

  factory _Contact.fromJson(Map<String, dynamic> json) = _$ContactImpl.fromJson;

  @override
  String get id;
  @override
  String? get firstName;
  @override
  String? get lastName;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  String? get company;
  @override
  String? get title;
  @override
  String? get website;
  @override
  String? get notes;
  @override
  String? get address;
  @override
  String? get linkedinUrl;
  @override
  List<String> get tags;
  @override
  String? get eventId;
  @override
  String? get templateId;
  @override
  bool get addToDeviceContacts;
  @override
  bool get sendFollowUpEmail;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  List<Interaction> get interactions;
  @override
  ProfileDiscovery? get profileDiscovery;
  @override
  @JsonKey(ignore: true)
  _$$ContactImplCopyWith<_$ContactImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// Interaction freezed
mixin _$Interaction {
  String get id => throw _privateConstructorUsedError;
  String get contactId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime? get occurredAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InteractionCopyWith<Interaction> get copyWith =>
      throw _privateConstructorUsedError;
}

abstract class $InteractionCopyWith<$Res> {
  factory $InteractionCopyWith(
          Interaction value, $Res Function(Interaction) then) =
      _$InteractionCopyWithImpl<$Res, Interaction>;
  @useResult
  $Res call({
    String id,
    String contactId,
    String type,
    String description,
    DateTime? occurredAt,
    DateTime? createdAt,
  });
}

class _$InteractionCopyWithImpl<$Res, $Val extends Interaction>
    implements $InteractionCopyWith<$Res> {
  _$InteractionCopyWithImpl(this._value, this._then);
  final $Val _value;
  final $Res Function($Val) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? contactId = null,
    Object? type = null,
    Object? description = null,
    Object? occurredAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      contactId: null == contactId ? _value.contactId : contactId as String,
      type: null == type ? _value.type : type as String,
      description: null == description ? _value.description : description as String,
      occurredAt: freezed == occurredAt ? _value.occurredAt : occurredAt as DateTime?,
      createdAt: freezed == createdAt ? _value.createdAt : createdAt as DateTime?,
    ) as $Val);
  }
}

abstract class _$$InteractionImplCopyWith<$Res>
    implements $InteractionCopyWith<$Res> {
  factory _$$InteractionImplCopyWith(
          _$InteractionImpl value, $Res Function(_$InteractionImpl) then) =
      __$$InteractionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String contactId,
    String type,
    String description,
    DateTime? occurredAt,
    DateTime? createdAt,
  });
}

class __$$InteractionImplCopyWithImpl<$Res>
    extends _$InteractionCopyWithImpl<$Res, _$InteractionImpl>
    implements _$$InteractionImplCopyWith<$Res> {
  __$$InteractionImplCopyWithImpl(super.value, super.then);

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? contactId = null,
    Object? type = null,
    Object? description = null,
    Object? occurredAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$InteractionImpl(
      id: null == id ? _value.id : id as String,
      contactId: null == contactId ? _value.contactId : contactId as String,
      type: null == type ? _value.type : type as String,
      description: null == description ? _value.description : description as String,
      occurredAt: freezed == occurredAt ? _value.occurredAt : occurredAt as DateTime?,
      createdAt: freezed == createdAt ? _value.createdAt : createdAt as DateTime?,
    ));
  }
}

@JsonSerializable()
class _$InteractionImpl implements _Interaction {
  const _$InteractionImpl({
    required this.id,
    required this.contactId,
    required this.type,
    required this.description,
    this.occurredAt,
    this.createdAt,
  });

  factory _$InteractionImpl.fromJson(Map<String, dynamic> json) =>
      _$$InteractionImplFromJson(json);

  @override
  final String id;
  @override
  final String contactId;
  @override
  final String type;
  @override
  final String description;
  @override
  final DateTime? occurredAt;
  @override
  final DateTime? createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && other is _$InteractionImpl && other.id == id);

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InteractionImplCopyWith<_$InteractionImpl> get copyWith =>
      __$$InteractionImplCopyWithImpl<_$InteractionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() => _$$InteractionImplToJson(this);

  @override
  String toString() => 'Interaction(id: $id, type: $type)';
}

abstract class _Interaction implements Interaction {
  const factory _Interaction({
    required final String id,
    required final String contactId,
    required final String type,
    required final String description,
    final DateTime? occurredAt,
    final DateTime? createdAt,
  }) = _$InteractionImpl;

  factory _Interaction.fromJson(Map<String, dynamic> json) = _$InteractionImpl.fromJson;

  @override String get id;
  @override String get contactId;
  @override String get type;
  @override String get description;
  @override DateTime? get occurredAt;
  @override DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$InteractionImplCopyWith<_$InteractionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// Event freezed (minimal implementation)
mixin _$Event {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EventCopyWith<Event> get copyWith => throw _privateConstructorUsedError;
}

abstract class $EventCopyWith<$Res> {
  factory $EventCopyWith(Event value, $Res Function(Event) then) =
      _$EventCopyWithImpl<$Res, Event>;
  @useResult
  $Res call({String id, String name, String? location, DateTime? startDate, DateTime? endDate, String? description, DateTime? createdAt});
}

class _$EventCopyWithImpl<$Res, $Val extends Event> implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._value, this._then);
  final $Val _value;
  final $Res Function($Val) _then;
  @override @pragma('vm:prefer-inline')
  $Res call({Object? id = null, Object? name = null, Object? location = freezed, Object? startDate = freezed, Object? endDate = freezed, Object? description = freezed, Object? createdAt = freezed}) {
    return _then(_value.copyWith(id: null == id ? _value.id : id as String, name: null == name ? _value.name : name as String, location: freezed == location ? _value.location : location as String?, startDate: freezed == startDate ? _value.startDate : startDate as DateTime?, endDate: freezed == endDate ? _value.endDate : endDate as DateTime?, description: freezed == description ? _value.description : description as String?, createdAt: freezed == createdAt ? _value.createdAt : createdAt as DateTime?) as $Val);
  }
}

abstract class _$$EventImplCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$$EventImplCopyWith(_$EventImpl value, $Res Function(_$EventImpl) then) = __$$EventImplCopyWithImpl<$Res>;
  @override @useResult
  $Res call({String id, String name, String? location, DateTime? startDate, DateTime? endDate, String? description, DateTime? createdAt});
}

class __$$EventImplCopyWithImpl<$Res> extends _$EventCopyWithImpl<$Res, _$EventImpl> implements _$$EventImplCopyWith<$Res> {
  __$$EventImplCopyWithImpl(super.value, super.then);
  @override @pragma('vm:prefer-inline')
  $Res call({Object? id = null, Object? name = null, Object? location = freezed, Object? startDate = freezed, Object? endDate = freezed, Object? description = freezed, Object? createdAt = freezed}) {
    return _then(_$EventImpl(id: null == id ? _value.id : id as String, name: null == name ? _value.name : name as String, location: freezed == location ? _value.location : location as String?, startDate: freezed == startDate ? _value.startDate : startDate as DateTime?, endDate: freezed == endDate ? _value.endDate : endDate as DateTime?, description: freezed == description ? _value.description : description as String?, createdAt: freezed == createdAt ? _value.createdAt : createdAt as DateTime?));
  }
}

@JsonSerializable()
class _$EventImpl implements _Event {
  const _$EventImpl({required this.id, required this.name, this.location, this.startDate, this.endDate, this.description, this.createdAt});
  factory _$EventImpl.fromJson(Map<String, dynamic> json) => _$$EventImplFromJson(json);
  @override final String id;
  @override final String name;
  @override final String? location;
  @override final DateTime? startDate;
  @override final DateTime? endDate;
  @override final String? description;
  @override final DateTime? createdAt;
  @override bool operator ==(Object other) => identical(this, other) || (other.runtimeType == runtimeType && other is _$EventImpl && other.id == id);
  @override int get hashCode => Object.hash(runtimeType, id);
  @JsonKey(ignore: true) @override @pragma('vm:prefer-inline')
  _$$EventImplCopyWith<_$EventImpl> get copyWith => __$$EventImplCopyWithImpl<_$EventImpl>(this, _$identity);
  @override Map<String, dynamic> toJson() => _$$EventImplToJson(this);
  @override String toString() => 'Event(id: $id, name: $name)';
}

abstract class _Event implements Event {
  const factory _Event({required final String id, required final String name, final String? location, final DateTime? startDate, final DateTime? endDate, final String? description, final DateTime? createdAt}) = _$EventImpl;
  factory _Event.fromJson(Map<String, dynamic> json) = _$EventImpl.fromJson;
  @override String get id; @override String get name; @override String? get location; @override DateTime? get startDate; @override DateTime? get endDate; @override String? get description; @override DateTime? get createdAt;
  @override @JsonKey(ignore: true) _$$EventImplCopyWith<_$EventImpl> get copyWith => throw _privateConstructorUsedError;
}

// Template & EmailJob minimal stubs
mixin _$Template {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true) $TemplateCopyWith<Template> get copyWith => throw _privateConstructorUsedError;
}

abstract class $TemplateCopyWith<$Res> {
  factory $TemplateCopyWith(Template value, $Res Function(Template) then) = _$TemplateCopyWithImpl<$Res, Template>;
  @useResult $Res call({String id, String name, String subject, String body, bool isDefault, DateTime? createdAt, DateTime? updatedAt});
}

class _$TemplateCopyWithImpl<$Res, $Val extends Template> implements $TemplateCopyWith<$Res> {
  _$TemplateCopyWithImpl(this._value, this._then);
  final $Val _value;
  final $Res Function($Val) _then;
  @override @pragma('vm:prefer-inline')
  $Res call({Object? id = null, Object? name = null, Object? subject = null, Object? body = null, Object? isDefault = null, Object? createdAt = freezed, Object? updatedAt = freezed}) {
    return _then(_value.copyWith(id: null == id ? _value.id : id as String, name: null == name ? _value.name : name as String, subject: null == subject ? _value.subject : subject as String, body: null == body ? _value.body : body as String, isDefault: null == isDefault ? _value.isDefault : isDefault as bool, createdAt: freezed == createdAt ? _value.createdAt : createdAt as DateTime?, updatedAt: freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?) as $Val);
  }
}

abstract class _$$TemplateImplCopyWith<$Res> implements $TemplateCopyWith<$Res> {
  factory _$$TemplateImplCopyWith(_$TemplateImpl value, $Res Function(_$TemplateImpl) then) = __$$TemplateImplCopyWithImpl<$Res>;
  @override @useResult $Res call({String id, String name, String subject, String body, bool isDefault, DateTime? createdAt, DateTime? updatedAt});
}

class __$$TemplateImplCopyWithImpl<$Res> extends _$TemplateCopyWithImpl<$Res, _$TemplateImpl> implements _$$TemplateImplCopyWith<$Res> {
  __$$TemplateImplCopyWithImpl(super.value, super.then);
  @override @pragma('vm:prefer-inline')
  $Res call({Object? id = null, Object? name = null, Object? subject = null, Object? body = null, Object? isDefault = null, Object? createdAt = freezed, Object? updatedAt = freezed}) {
    return _then(_$TemplateImpl(id: null == id ? _value.id : id as String, name: null == name ? _value.name : name as String, subject: null == subject ? _value.subject : subject as String, body: null == body ? _value.body : body as String, isDefault: null == isDefault ? _value.isDefault : isDefault as bool, createdAt: freezed == createdAt ? _value.createdAt : createdAt as DateTime?, updatedAt: freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?));
  }
}

@JsonSerializable()
class _$TemplateImpl implements _Template {
  const _$TemplateImpl({required this.id, required this.name, required this.subject, required this.body, this.isDefault = false, this.createdAt, this.updatedAt});
  factory _$TemplateImpl.fromJson(Map<String, dynamic> json) => _$$TemplateImplFromJson(json);
  @override final String id; @override final String name; @override final String subject; @override final String body; @override @JsonKey() final bool isDefault; @override final DateTime? createdAt; @override final DateTime? updatedAt;
  @override bool operator ==(Object other) => identical(this, other) || (other.runtimeType == runtimeType && other is _$TemplateImpl && other.id == id);
  @override int get hashCode => Object.hash(runtimeType, id);
  @JsonKey(ignore: true) @override @pragma('vm:prefer-inline')
  _$$TemplateImplCopyWith<_$TemplateImpl> get copyWith => __$$TemplateImplCopyWithImpl<_$TemplateImpl>(this, _$identity);
  @override Map<String, dynamic> toJson() => _$$TemplateImplToJson(this);
  @override String toString() => 'Template(id: $id, name: $name)';
}

abstract class _Template implements Template {
  const factory _Template({required final String id, required final String name, required final String subject, required final String body, final bool isDefault, final DateTime? createdAt, final DateTime? updatedAt}) = _$TemplateImpl;
  factory _Template.fromJson(Map<String, dynamic> json) = _$TemplateImpl.fromJson;
  @override String get id; @override String get name; @override String get subject; @override String get body; @override bool get isDefault; @override DateTime? get createdAt; @override DateTime? get updatedAt;
  @override @JsonKey(ignore: true) _$$TemplateImplCopyWith<_$TemplateImpl> get copyWith => throw _privateConstructorUsedError;
}

// EmailJob
mixin _$EmailJob {
  String get id => throw _privateConstructorUsedError;
  String get contactId => throw _privateConstructorUsedError;
  String get templateId => throw _privateConstructorUsedError;
  EmailJobStatus get status => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  DateTime? get scheduledAt => throw _privateConstructorUsedError;
  DateTime? get sentAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true) $EmailJobCopyWith<EmailJob> get copyWith => throw _privateConstructorUsedError;
}

abstract class $EmailJobCopyWith<$Res> {
  factory $EmailJobCopyWith(EmailJob value, $Res Function(EmailJob) then) = _$EmailJobCopyWithImpl<$Res, EmailJob>;
  @useResult $Res call({String id, String contactId, String templateId, EmailJobStatus status, String? errorMessage, DateTime? scheduledAt, DateTime? sentAt, DateTime? createdAt});
}

class _$EmailJobCopyWithImpl<$Res, $Val extends EmailJob> implements $EmailJobCopyWith<$Res> {
  _$EmailJobCopyWithImpl(this._value, this._then);
  final $Val _value;
  final $Res Function($Val) _then;
  @override @pragma('vm:prefer-inline')
  $Res call({Object? id = null, Object? contactId = null, Object? templateId = null, Object? status = null, Object? errorMessage = freezed, Object? scheduledAt = freezed, Object? sentAt = freezed, Object? createdAt = freezed}) {
    return _then(_value.copyWith(id: null == id ? _value.id : id as String, contactId: null == contactId ? _value.contactId : contactId as String, templateId: null == templateId ? _value.templateId : templateId as String, status: null == status ? _value.status : status as EmailJobStatus, errorMessage: freezed == errorMessage ? _value.errorMessage : errorMessage as String?, scheduledAt: freezed == scheduledAt ? _value.scheduledAt : scheduledAt as DateTime?, sentAt: freezed == sentAt ? _value.sentAt : sentAt as DateTime?, createdAt: freezed == createdAt ? _value.createdAt : createdAt as DateTime?) as $Val);
  }
}

abstract class _$$EmailJobImplCopyWith<$Res> implements $EmailJobCopyWith<$Res> {
  factory _$$EmailJobImplCopyWith(_$EmailJobImpl value, $Res Function(_$EmailJobImpl) then) = __$$EmailJobImplCopyWithImpl<$Res>;
  @override @useResult $Res call({String id, String contactId, String templateId, EmailJobStatus status, String? errorMessage, DateTime? scheduledAt, DateTime? sentAt, DateTime? createdAt});
}

class __$$EmailJobImplCopyWithImpl<$Res> extends _$EmailJobCopyWithImpl<$Res, _$EmailJobImpl> implements _$$EmailJobImplCopyWith<$Res> {
  __$$EmailJobImplCopyWithImpl(super.value, super.then);
  @override @pragma('vm:prefer-inline')
  $Res call({Object? id = null, Object? contactId = null, Object? templateId = null, Object? status = null, Object? errorMessage = freezed, Object? scheduledAt = freezed, Object? sentAt = freezed, Object? createdAt = freezed}) {
    return _then(_$EmailJobImpl(id: null == id ? _value.id : id as String, contactId: null == contactId ? _value.contactId : contactId as String, templateId: null == templateId ? _value.templateId : templateId as String, status: null == status ? _value.status : status as EmailJobStatus, errorMessage: freezed == errorMessage ? _value.errorMessage : errorMessage as String?, scheduledAt: freezed == scheduledAt ? _value.scheduledAt : scheduledAt as DateTime?, sentAt: freezed == sentAt ? _value.sentAt : sentAt as DateTime?, createdAt: freezed == createdAt ? _value.createdAt : createdAt as DateTime?));
  }
}

@JsonSerializable()
class _$EmailJobImpl implements _EmailJob {
  const _$EmailJobImpl({required this.id, required this.contactId, required this.templateId, required this.status, this.errorMessage, this.scheduledAt, this.sentAt, this.createdAt});
  factory _$EmailJobImpl.fromJson(Map<String, dynamic> json) => _$$EmailJobImplFromJson(json);
  @override final String id; @override final String contactId; @override final String templateId; @override final EmailJobStatus status; @override final String? errorMessage; @override final DateTime? scheduledAt; @override final DateTime? sentAt; @override final DateTime? createdAt;
  @override bool operator ==(Object other) => identical(this, other) || (other.runtimeType == runtimeType && other is _$EmailJobImpl && other.id == id);
  @override int get hashCode => Object.hash(runtimeType, id);
  @JsonKey(ignore: true) @override @pragma('vm:prefer-inline')
  _$$EmailJobImplCopyWith<_$EmailJobImpl> get copyWith => __$$EmailJobImplCopyWithImpl<_$EmailJobImpl>(this, _$identity);
  @override Map<String, dynamic> toJson() => _$$EmailJobImplToJson(this);
  @override String toString() => 'EmailJob(id: $id, status: $status)';
}

abstract class _EmailJob implements EmailJob {
  const factory _EmailJob({required final String id, required final String contactId, required final String templateId, required final EmailJobStatus status, final String? errorMessage, final DateTime? scheduledAt, final DateTime? sentAt, final DateTime? createdAt}) = _$EmailJobImpl;
  factory _EmailJob.fromJson(Map<String, dynamic> json) = _$EmailJobImpl.fromJson;
  @override String get id; @override String get contactId; @override String get templateId; @override EmailJobStatus get status; @override String? get errorMessage; @override DateTime? get scheduledAt; @override DateTime? get sentAt; @override DateTime? get createdAt;
  @override @JsonKey(ignore: true) _$$EmailJobImplCopyWith<_$EmailJobImpl> get copyWith => throw _privateConstructorUsedError;
}

// ProfileDiscovery
mixin _$ProfileDiscovery {
  String? get linkedinUrl => throw _privateConstructorUsedError;
  String? get twitterHandle => throw _privateConstructorUsedError;
  String? get githubUsername => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true) $ProfileDiscoveryCopyWith<ProfileDiscovery> get copyWith => throw _privateConstructorUsedError;
}

abstract class $ProfileDiscoveryCopyWith<$Res> {
  factory $ProfileDiscoveryCopyWith(ProfileDiscovery value, $Res Function(ProfileDiscovery) then) = _$ProfileDiscoveryCopyWithImpl<$Res, ProfileDiscovery>;
  @useResult $Res call({String? linkedinUrl, String? twitterHandle, String? githubUsername, String? bio, String? photoUrl, DateTime? lastUpdated});
}

class _$ProfileDiscoveryCopyWithImpl<$Res, $Val extends ProfileDiscovery> implements $ProfileDiscoveryCopyWith<$Res> {
  _$ProfileDiscoveryCopyWithImpl(this._value, this._then);
  final $Val _value;
  final $Res Function($Val) _then;
  @override @pragma('vm:prefer-inline')
  $Res call({Object? linkedinUrl = freezed, Object? twitterHandle = freezed, Object? githubUsername = freezed, Object? bio = freezed, Object? photoUrl = freezed, Object? lastUpdated = freezed}) {
    return _then(_value.copyWith(linkedinUrl: freezed == linkedinUrl ? _value.linkedinUrl : linkedinUrl as String?, twitterHandle: freezed == twitterHandle ? _value.twitterHandle : twitterHandle as String?, githubUsername: freezed == githubUsername ? _value.githubUsername : githubUsername as String?, bio: freezed == bio ? _value.bio : bio as String?, photoUrl: freezed == photoUrl ? _value.photoUrl : photoUrl as String?, lastUpdated: freezed == lastUpdated ? _value.lastUpdated : lastUpdated as DateTime?) as $Val);
  }
}

abstract class _$$ProfileDiscoveryImplCopyWith<$Res> implements $ProfileDiscoveryCopyWith<$Res> {
  factory _$$ProfileDiscoveryImplCopyWith(_$ProfileDiscoveryImpl value, $Res Function(_$ProfileDiscoveryImpl) then) = __$$ProfileDiscoveryImplCopyWithImpl<$Res>;
  @override @useResult $Res call({String? linkedinUrl, String? twitterHandle, String? githubUsername, String? bio, String? photoUrl, DateTime? lastUpdated});
}

class __$$ProfileDiscoveryImplCopyWithImpl<$Res> extends _$ProfileDiscoveryCopyWithImpl<$Res, _$ProfileDiscoveryImpl> implements _$$ProfileDiscoveryImplCopyWith<$Res> {
  __$$ProfileDiscoveryImplCopyWithImpl(super.value, super.then);
  @override @pragma('vm:prefer-inline')
  $Res call({Object? linkedinUrl = freezed, Object? twitterHandle = freezed, Object? githubUsername = freezed, Object? bio = freezed, Object? photoUrl = freezed, Object? lastUpdated = freezed}) {
    return _then(_$ProfileDiscoveryImpl(linkedinUrl: freezed == linkedinUrl ? _value.linkedinUrl : linkedinUrl as String?, twitterHandle: freezed == twitterHandle ? _value.twitterHandle : twitterHandle as String?, githubUsername: freezed == githubUsername ? _value.githubUsername : githubUsername as String?, bio: freezed == bio ? _value.bio : bio as String?, photoUrl: freezed == photoUrl ? _value.photoUrl : photoUrl as String?, lastUpdated: freezed == lastUpdated ? _value.lastUpdated : lastUpdated as DateTime?));
  }
}

@JsonSerializable()
class _$ProfileDiscoveryImpl implements _ProfileDiscovery {
  const _$ProfileDiscoveryImpl({this.linkedinUrl, this.twitterHandle, this.githubUsername, this.bio, this.photoUrl, this.lastUpdated});
  factory _$ProfileDiscoveryImpl.fromJson(Map<String, dynamic> json) => _$$ProfileDiscoveryImplFromJson(json);
  @override final String? linkedinUrl; @override final String? twitterHandle; @override final String? githubUsername; @override final String? bio; @override final String? photoUrl; @override final DateTime? lastUpdated;
  @override bool operator ==(Object other) => identical(this, other) || (other.runtimeType == runtimeType && other is _$ProfileDiscoveryImpl && other.linkedinUrl == linkedinUrl);
  @override int get hashCode => Object.hash(runtimeType, linkedinUrl, twitterHandle, githubUsername);
  @JsonKey(ignore: true) @override @pragma('vm:prefer-inline')
  _$$ProfileDiscoveryImplCopyWith<_$ProfileDiscoveryImpl> get copyWith => __$$ProfileDiscoveryImplCopyWithImpl<_$ProfileDiscoveryImpl>(this, _$identity);
  @override Map<String, dynamic> toJson() => _$$ProfileDiscoveryImplToJson(this);
  @override String toString() => 'ProfileDiscovery(linkedinUrl: $linkedinUrl)';
}

abstract class _ProfileDiscovery implements ProfileDiscovery {
  const factory _ProfileDiscovery({final String? linkedinUrl, final String? twitterHandle, final String? githubUsername, final String? bio, final String? photoUrl, final DateTime? lastUpdated}) = _$ProfileDiscoveryImpl;
  factory _ProfileDiscovery.fromJson(Map<String, dynamic> json) = _$ProfileDiscoveryImpl.fromJson;
  @override String? get linkedinUrl; @override String? get twitterHandle; @override String? get githubUsername; @override String? get bio; @override String? get photoUrl; @override DateTime? get lastUpdated;
  @override @JsonKey(ignore: true) _$$ProfileDiscoveryImplCopyWith<_$ProfileDiscoveryImpl> get copyWith => throw _privateConstructorUsedError;
}
