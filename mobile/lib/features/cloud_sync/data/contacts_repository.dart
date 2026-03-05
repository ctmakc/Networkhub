import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networkhub/core/network/api_client.dart';
import 'package:networkhub/core/network/api_endpoints.dart';
import 'package:networkhub/features/cloud_sync/data/contact_models.dart';

final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  return ContactsRepository(ApiClient());
});

class ContactsRepository {
  final ApiClient _client;

  ContactsRepository(this._client);

  Future<Contact> createContact(Map<String, dynamic> data) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.contacts,
      data: data,
    );
    return Contact.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Contact> updateContact(String id, Map<String, dynamic> data) async {
    final response = await _client.patch<Map<String, dynamic>>(
      ApiEndpoints.contact(id),
      data: data,
    );
    return Contact.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Contact>> listContacts({
    String? search,
    String? tag,
    String? eventId,
    int page = 1,
    int perPage = 20,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (tag != null && tag.isNotEmpty) params['tag'] = tag;
    if (eventId != null && eventId.isNotEmpty) params['event_id'] = eventId;

    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.contacts,
      queryParameters: params,
    );

    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? data['data'] as List<dynamic>? ?? [];
    return items
        .map((item) => Contact.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Contact> getContact(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.contact(id),
    );
    return Contact.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Interaction>> getInteractions(String contactId) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.contactInteractions(contactId),
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? data['data'] as List<dynamic>? ?? [];
    return items
        .map((item) => Interaction.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<EmailJob> sendEmail({
    required String contactId,
    required String templateId,
    bool consentGiven = false,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.sendEmail,
      data: {
        'contact_id': contactId,
        'template_id': templateId,
        'consent_given': consentGiven,
      },
    );
    return EmailJob.fromJson(response.data as Map<String, dynamic>);
  }

  Future<EmailJob> getEmailJob(String jobId) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.emailJob(jobId),
    );
    return EmailJob.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProfileDiscovery?> getProfileDiscovery(String contactId) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        ApiEndpoints.profileDiscovery(contactId),
      );
      return ProfileDiscovery.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
