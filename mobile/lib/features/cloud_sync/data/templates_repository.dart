import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networkhub/core/network/api_client.dart';
import 'package:networkhub/core/network/api_endpoints.dart';
import 'package:networkhub/features/cloud_sync/data/contact_models.dart';

final templatesRepositoryProvider = Provider<TemplatesRepository>((ref) {
  return TemplatesRepository(ApiClient());
});

final templatesListProvider = FutureProvider<List<Template>>((ref) async {
  final repo = ref.read(templatesRepositoryProvider);
  return repo.listTemplates();
});

class TemplatesRepository {
  final ApiClient _client;

  TemplatesRepository(this._client);

  Future<List<Template>> listTemplates() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.templates,
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? data['data'] as List<dynamic>? ?? [];
    return items
        .map((item) => Template.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Template> getTemplate(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.template(id),
    );
    return Template.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Template> createTemplate(Map<String, dynamic> data) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.templates,
      data: data,
    );
    return Template.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Template> updateTemplate(String id, Map<String, dynamic> data) async {
    final response = await _client.patch<Map<String, dynamic>>(
      ApiEndpoints.template(id),
      data: data,
    );
    return Template.fromJson(response.data as Map<String, dynamic>);
  }
}
