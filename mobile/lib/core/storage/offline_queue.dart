import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:networkhub/core/error/app_exception.dart';

part 'offline_queue.g.dart';

@HiveType(typeId: 0)
class ContactDraft extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? firstName;

  @HiveField(2)
  final String? lastName;

  @HiveField(3)
  final String? email;

  @HiveField(4)
  final String? phone;

  @HiveField(5)
  final String? company;

  @HiveField(6)
  final String? title;

  @HiveField(7)
  final String? website;

  @HiveField(8)
  final String? notes;

  @HiveField(9)
  final List<String> tags;

  @HiveField(10)
  final String? eventId;

  @HiveField(11)
  final String rawOcrText;

  @HiveField(12)
  final String? rawVcard;

  @HiveField(13)
  final bool addToDeviceContacts;

  @HiveField(14)
  final bool sendFollowUpEmail;

  @HiveField(15)
  final String? templateId;

  @HiveField(16)
  final DateTime createdAt;

  @HiveField(17)
  int retryCount;

  @HiveField(18)
  String? lastError;

  @HiveField(19)
  final String? address;

  @HiveField(20)
  final String? linkedinUrl;

  ContactDraft({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.company,
    this.title,
    this.website,
    this.notes,
    List<String>? tags,
    this.eventId,
    this.rawOcrText = '',
    this.rawVcard,
    this.addToDeviceContacts = true,
    this.sendFollowUpEmail = false,
    this.templateId,
    DateTime? createdAt,
    this.retryCount = 0,
    this.lastError,
    this.address,
    this.linkedinUrl,
  })  : tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now();

  String get fullName {
    final parts = [firstName, lastName].whereType<String>().join(' ');
    return parts.isNotEmpty ? parts : 'Unknown Contact';
  }

  ContactDraft copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? company,
    String? title,
    String? website,
    String? notes,
    List<String>? tags,
    String? eventId,
    String? rawOcrText,
    String? rawVcard,
    bool? addToDeviceContacts,
    bool? sendFollowUpEmail,
    String? templateId,
    DateTime? createdAt,
    int? retryCount,
    String? lastError,
    String? address,
    String? linkedinUrl,
  }) {
    return ContactDraft(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      title: title ?? this.title,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      eventId: eventId ?? this.eventId,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      rawVcard: rawVcard ?? this.rawVcard,
      addToDeviceContacts: addToDeviceContacts ?? this.addToDeviceContacts,
      sendFollowUpEmail: sendFollowUpEmail ?? this.sendFollowUpEmail,
      templateId: templateId ?? this.templateId,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      address: address ?? this.address,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'company': company,
        'title': title,
        'website': website,
        'notes': notes,
        'tags': tags,
        'event_id': eventId,
        'add_to_device_contacts': addToDeviceContacts,
        'send_follow_up_email': sendFollowUpEmail,
        'template_id': templateId,
        'address': address,
        'linkedin_url': linkedinUrl,
      };
}

// Manual adapter since we can't run build_runner
class ContactDraftAdapter extends TypeAdapter<ContactDraft> {
  @override
  final int typeId = 0;

  @override
  ContactDraft read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContactDraft(
      id: fields[0] as String,
      firstName: fields[1] as String?,
      lastName: fields[2] as String?,
      email: fields[3] as String?,
      phone: fields[4] as String?,
      company: fields[5] as String?,
      title: fields[6] as String?,
      website: fields[7] as String?,
      notes: fields[8] as String?,
      tags: (fields[9] as List?)?.cast<String>(),
      eventId: fields[10] as String?,
      rawOcrText: fields[11] as String? ?? '',
      rawVcard: fields[12] as String?,
      addToDeviceContacts: fields[13] as bool? ?? true,
      sendFollowUpEmail: fields[14] as bool? ?? false,
      templateId: fields[15] as String?,
      createdAt: fields[16] as DateTime?,
      retryCount: fields[17] as int? ?? 0,
      lastError: fields[18] as String?,
      address: fields[19] as String?,
      linkedinUrl: fields[20] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ContactDraft obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.company)
      ..writeByte(6)
      ..write(obj.title)
      ..writeByte(7)
      ..write(obj.website)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.eventId)
      ..writeByte(11)
      ..write(obj.rawOcrText)
      ..writeByte(12)
      ..write(obj.rawVcard)
      ..writeByte(13)
      ..write(obj.addToDeviceContacts)
      ..writeByte(14)
      ..write(obj.sendFollowUpEmail)
      ..writeByte(15)
      ..write(obj.templateId)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.retryCount)
      ..writeByte(18)
      ..write(obj.lastError)
      ..writeByte(19)
      ..write(obj.address)
      ..writeByte(20)
      ..write(obj.linkedinUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactDraftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OfflineQueue {
  static const String boxName = 'offline_queue';
  static const int maxRetries = 3;

  final _logger = Logger();

  Box<ContactDraft> get _box => Hive.box<ContactDraft>(boxName);

  Future<void> enqueue(ContactDraft draft) async {
    try {
      await _box.put(draft.id, draft);
      _logger.d('Enqueued draft: ${draft.id}');
    } catch (e) {
      throw StorageException(message: 'Failed to enqueue draft: $e');
    }
  }

  Future<ContactDraft?> dequeue() async {
    try {
      if (_box.isEmpty) return null;
      final key = _box.keys.first;
      final draft = _box.get(key);
      return draft;
    } catch (e) {
      _logger.e('Failed to dequeue: $e');
      return null;
    }
  }

  Future<void> remove(String id) async {
    await _box.delete(id);
  }

  Future<void> markFailed(String id, String error) async {
    final draft = _box.get(id);
    if (draft != null) {
      final updated = draft.copyWith(
        retryCount: draft.retryCount + 1,
        lastError: error,
      );
      await _box.put(id, updated);
    }
  }

  List<ContactDraft> getAll() {
    return _box.values.toList();
  }

  List<ContactDraft> getPending() {
    return _box.values
        .where((d) => d.retryCount < maxRetries)
        .toList();
  }

  List<ContactDraft> getFailed() {
    return _box.values
        .where((d) => d.retryCount >= maxRetries)
        .toList();
  }

  int get pendingCount => _box.length;

  bool get hasPending => _box.isNotEmpty;

  Future<void> clear() async {
    await _box.clear();
  }

  Future<void> clearFailed() async {
    final failedKeys = _box.values
        .where((d) => d.retryCount >= maxRetries)
        .map((d) => d.id)
        .toList();
    await _box.deleteAll(failedKeys);
  }

  Stream<BoxEvent> get events => _box.watch();
}
