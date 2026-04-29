import 'package:flutter_test/flutter_test.dart';
import 'package:networkhub/features/scan/data/scan_models.dart';
import 'package:networkhub/core/storage/offline_queue.dart';

void main() {
  group('DraftContact', () {
    test('fullName returns "FirstName LastName"', () {
      const draft = DraftContact(firstName: 'John', lastName: 'Doe');
      expect(draft.fullName, 'John Doe');
    });

    test('fullName returns firstName only when no lastName', () {
      const draft = DraftContact(firstName: 'John');
      expect(draft.fullName, 'John');
    });

    test('fullName returns empty string when both null', () {
      const draft = DraftContact();
      expect(draft.fullName, '');
    });

    test('hasEmail returns true when email present', () {
      const draft = DraftContact(email: 'john@example.com');
      expect(draft.hasEmail, isTrue);
    });

    test('hasEmail returns false when email is null', () {
      const draft = DraftContact();
      expect(draft.hasEmail, isFalse);
    });

    test('hasEmail returns false when email is empty', () {
      const draft = DraftContact(email: '');
      expect(draft.hasEmail, isFalse);
    });

    test('hasPhone returns true when phone present', () {
      const draft = DraftContact(phone: '+15551234567');
      expect(draft.hasPhone, isTrue);
    });

    test('hasPhone returns false when phone is null', () {
      const draft = DraftContact();
      expect(draft.hasPhone, isFalse);
    });

    test('toJson produces snake_case keys', () {
      const draft = DraftContact(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        tags: ['prospect'],
      );
      final json = draft.toJson();
      expect(json['first_name'], 'John');
      expect(json['last_name'], 'Doe');
      expect(json['email'], 'john@example.com');
      expect(json['tags'], ['prospect']);
      expect(json['add_to_device_contacts'], isTrue);
      expect(json['send_follow_up_email'], isFalse);
    });

    test('toContactDraft maps all fields correctly', () {
      const draft = DraftContact(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        phone: '+15551234567',
        company: 'Acme',
        title: 'Engineer',
        website: 'https://acme.com',
        notes: 'Met at conf',
        address: '123 Main St',
        linkedinUrl: 'linkedin.com/in/john',
        tags: ['prospect'],
        eventId: 'evt-1',
        rawOcrText: 'raw text',
        rawVcard: 'vcard data',
        addToDeviceContacts: false,
        sendFollowUpEmail: true,
        templateId: 'tmpl-1',
      );
      final cd = draft.toContactDraft('test-id');
      expect(cd.id, 'test-id');
      expect(cd.firstName, 'John');
      expect(cd.lastName, 'Doe');
      expect(cd.email, 'john@example.com');
      expect(cd.phone, '+15551234567');
      expect(cd.company, 'Acme');
      expect(cd.title, 'Engineer');
      expect(cd.website, 'https://acme.com');
      expect(cd.notes, 'Met at conf');
      expect(cd.address, '123 Main St');
      expect(cd.linkedinUrl, 'linkedin.com/in/john');
      expect(cd.tags, ['prospect']);
      expect(cd.eventId, 'evt-1');
      expect(cd.rawOcrText, 'raw text');
      expect(cd.rawVcard, 'vcard data');
      expect(cd.addToDeviceContacts, isFalse);
      expect(cd.sendFollowUpEmail, isTrue);
      expect(cd.templateId, 'tmpl-1');
    });

    test('defaults: tags empty, addToDeviceContacts true, sendFollowUpEmail false', () {
      const draft = DraftContact();
      expect(draft.tags, isEmpty);
      expect(draft.addToDeviceContacts, isTrue);
      expect(draft.sendFollowUpEmail, isFalse);
      expect(draft.rawOcrText, '');
    });
  });

  group('ContactDraft', () {
    test('fullName returns "FirstName LastName"', () {
      final cd = ContactDraft(id: '1', firstName: 'John', lastName: 'Doe');
      expect(cd.fullName, 'John Doe');
    });

    test('fullName returns "Unknown Contact" when both null', () {
      final cd = ContactDraft(id: '1');
      expect(cd.fullName, 'Unknown Contact');
    });

    test('fullName returns firstName when only firstName set', () {
      final cd = ContactDraft(id: '1', firstName: 'Jane');
      expect(cd.fullName, 'Jane');
    });

    test('copyWith preserves unchanged fields', () {
      final cd = ContactDraft(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        retryCount: 0,
      );
      final updated = cd.copyWith(retryCount: 2, lastError: 'Network error');
      expect(updated.id, '1');
      expect(updated.firstName, 'John');
      expect(updated.lastName, 'Doe');
      expect(updated.email, 'john@example.com');
      expect(updated.retryCount, 2);
      expect(updated.lastError, 'Network error');
    });

    test('copyWith overrides all provided fields', () {
      final cd = ContactDraft(id: '1', firstName: 'John');
      final updated = cd.copyWith(firstName: 'Jane', company: 'Acme');
      expect(updated.firstName, 'Jane');
      expect(updated.company, 'Acme');
    });

    test('toJson produces snake_case keys', () {
      final cd = ContactDraft(
        id: 'test-id',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        tags: ['customer'],
      );
      final json = cd.toJson();
      expect(json['id'], 'test-id');
      expect(json['first_name'], 'John');
      expect(json['last_name'], 'Doe');
      expect(json['tags'], ['customer']);
      expect(json['add_to_device_contacts'], isTrue);
      expect(json['send_follow_up_email'], isFalse);
    });

    test('default values', () {
      final cd = ContactDraft(id: '1');
      expect(cd.tags, isEmpty);
      expect(cd.rawOcrText, '');
      expect(cd.addToDeviceContacts, isTrue);
      expect(cd.sendFollowUpEmail, isFalse);
      expect(cd.retryCount, 0);
      expect(cd.lastError, isNull);
      expect(cd.createdAt, isNotNull);
    });
  });
}
