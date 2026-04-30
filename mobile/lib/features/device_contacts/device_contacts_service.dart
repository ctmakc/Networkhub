import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:networkhub/core/error/app_exception.dart';
import 'package:networkhub/features/scan/data/scan_models.dart';

final deviceContactsServiceProvider = Provider<DeviceContactsService>(
  (_) => DeviceContactsService(),
);

class DeviceContactsService {
  final _logger = Logger();

  /// Request contacts permission
  Future<bool> requestPermission() async {
    return FlutterContacts.requestPermission();
  }

  /// Check if contacts permission is granted
  Future<bool> hasPermission() async {
    return FlutterContacts.requestPermission(readonly: true);
  }

  /// Check for duplicate contact by email or phone
  Future<Contact?> findDuplicate(DraftContact draft) async {
    final hasPermission = await this.hasPermission();
    if (!hasPermission) return null;

    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
      );

      for (final contact in contacts) {
        // Check email match
        if (draft.email != null && draft.email!.isNotEmpty) {
          for (final emailEntry in contact.emails) {
            if (emailEntry.address.toLowerCase() ==
                draft.email!.toLowerCase()) {
              return contact;
            }
          }
        }

        // Check phone match
        if (draft.phone != null && draft.phone!.isNotEmpty) {
          final normalizedDraft = _normalizePhone(draft.phone!);
          for (final phoneEntry in contact.phones) {
            final normalizedContact = _normalizePhone(phoneEntry.number);
            if (normalizedDraft == normalizedContact && normalizedDraft.length >= 7) {
              return contact;
            }
          }
        }
      }
    } catch (e) {
      _logger.w('Error checking for duplicate contacts: $e');
    }
    return null;
  }

  /// Create a new device contact from DraftContact
  Future<Contact> createContact(DraftContact draft) async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw PermissionException(
        message: 'Contacts permission not granted',
        permission: 'contacts',
      );
    }

    final contact = Contact(
      name: Name(
        first: draft.firstName ?? '',
        last: draft.lastName ?? '',
      ),
      emails: draft.email != null && draft.email!.isNotEmpty
          ? [Email(draft.email!)]
          : [],
      phones: draft.phone != null && draft.phone!.isNotEmpty
          ? [Phone(draft.phone!)]
          : [],
      organizations: (draft.company != null || draft.title != null)
          ? [
              Organization(
                company: draft.company ?? '',
                title: draft.title ?? '',
              )
            ]
          : [],
      websites: draft.website != null && draft.website!.isNotEmpty
          ? [Website(draft.website!)]
          : [],
      addresses: draft.address != null && draft.address!.isNotEmpty
          ? [Address(draft.address!)]
          : [],
      notes: draft.notes != null && draft.notes!.isNotEmpty
          ? [Note(draft.notes!)]
          : [],
    );

    try {
      return await FlutterContacts.insertContact(contact);
    } catch (e) {
      throw StorageException(message: 'Failed to create device contact: $e');
    }
  }

  /// Update an existing device contact
  Future<Contact> updateContact(Contact existing, DraftContact draft) async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw PermissionException(
        message: 'Contacts permission not granted',
        permission: 'contacts',
      );
    }

    // Merge data - don't overwrite existing if draft is empty
    final updatedName = Name(
      first: draft.firstName ?? existing.name.first,
      last: draft.lastName ?? existing.name.last,
    );

    // Merge emails
    final existingEmails = existing.emails.map((e) => e.address).toSet();
    final newEmails = [...existing.emails];
    if (draft.email != null &&
        draft.email!.isNotEmpty &&
        !existingEmails.contains(draft.email!.toLowerCase())) {
      newEmails.add(Email(draft.email!));
    }

    // Merge phones
    final existingPhones =
        existing.phones.map((p) => _normalizePhone(p.number)).toSet();
    final newPhones = [...existing.phones];
    if (draft.phone != null &&
        draft.phone!.isNotEmpty &&
        !existingPhones.contains(_normalizePhone(draft.phone!))) {
      newPhones.add(Phone(draft.phone!));
    }

    final newOrgs = (draft.company != null || draft.title != null)
        ? [
            Organization(
              company: draft.company ?? existing.organizations.firstOrNull?.company ?? '',
              title: draft.title ?? existing.organizations.firstOrNull?.title ?? '',
            )
          ]
        : existing.organizations;
    existing.name = updatedName;
    existing.emails = newEmails;
    existing.phones = newPhones;
    existing.organizations = newOrgs;
    final updated = existing;

    try {
      await FlutterContacts.updateContact(updated);
      return updated;
    } catch (e) {
      throw StorageException(message: 'Failed to update device contact: $e');
    }
  }

  /// Create a new contact or update existing one if duplicate found
  Future<void> createOrUpdateContact(DraftContact draft) async {
    final existing = await findDuplicate(draft);
    if (existing != null) {
      _logger.d('Found existing contact: ${existing.displayName}, updating...');
      await updateContact(existing, draft);
    } else {
      _logger.d('Creating new device contact...');
      await createContact(draft);
    }
  }

  /// Normalize phone number for comparison
  String _normalizePhone(String phone) {
    // Remove all non-digit characters except leading +
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d+]'), '');
    // Take last 10 digits for comparison (handles country code differences)
    if (digitsOnly.length > 10) {
      return digitsOnly.substring(digitsOnly.length - 10);
    }
    return digitsOnly;
  }
}
