import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networkhub/core/network/api_client.dart';
import 'package:networkhub/core/network/api_endpoints.dart';
import 'package:networkhub/features/cloud_sync/data/contact_models.dart';

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return EventsRepository(ApiClient());
});

final eventsListProvider = FutureProvider<List<Event>>((ref) async {
  final repo = ref.read(eventsRepositoryProvider);
  return repo.listEvents();
});

class EventsRepository {
  final ApiClient _client;

  EventsRepository(this._client);

  Future<List<Event>> listEvents() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.events,
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? data['data'] as List<dynamic>? ?? [];
    return items
        .map((item) => Event.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Event> getEvent(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.event(id),
    );
    return Event.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Event> createEvent(Map<String, dynamic> data) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.events,
      data: data,
    );
    return Event.fromJson(response.data as Map<String, dynamic>);
  }
}
