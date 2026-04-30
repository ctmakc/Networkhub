import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networkhub/core/network/api_client.dart';
import 'package:networkhub/core/network/api_endpoints.dart';
import 'package:networkhub/core/storage/local_storage.dart';
import 'package:networkhub/features/auth/data/auth_models.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ApiClient());
});

class AuthRepository {
  final ApiClient _client;

  AuthRepository(this._client);

  /// Sends magic link to the given email address
  Future<void> requestMagicLink(String email) async {
    await _client.post(
      ApiEndpoints.requestMagicLink,
      data: {'email': email},
    );
  }

  /// Verifies the magic link code and returns token
  Future<TokenResponse> verifyMagicLink(String email, String code) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.verifyMagicLink,
      data: {'email': email, 'code': code},
    );

    final tokenResponse = TokenResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    // Persist token
    await LocalStorage.setToken(tokenResponse.token);

    return tokenResponse;
  }

  /// Gets the current authenticated user
  Future<User> getMe() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.getMe,
    );

    final user = User.fromJson(response.data as Map<String, dynamic>);

    // Cache user data locally
    await LocalStorage.setUserData(jsonEncode(user.toJson()));
    if (user.email.isNotEmpty) {
      await LocalStorage.setUserEmail(user.email);
    }
    if (user.name != null) {
      await LocalStorage.setUserName(user.name!);
    }
    if (user.signature != null) {
      await LocalStorage.setUserSignature(user.signature!);
    }

    return user;
  }

  /// Updates the user profile (name, signature, default template)
  Future<User> updateProfile({
    String? name,
    String? signature,
    String? defaultTemplateId,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (signature != null) data['signature'] = signature;
    if (defaultTemplateId != null) {
      data['default_template_id'] = defaultTemplateId;
    }

    final response = await _client.patch<Map<String, dynamic>>(
      ApiEndpoints.getMe,
      data: data,
    );

    final user = User.fromJson(response.data as Map<String, dynamic>);
    await LocalStorage.setUserData(jsonEncode(user.toJson()));
    return user;
  }

  /// Logs out the user
  Future<void> logout() async {
    try {
      await _client.post(ApiEndpoints.logout);
    } catch (_) {
      // Ignore errors on logout
    } finally {
      await LocalStorage.clearToken();
      await LocalStorage.clearUserData();
    }
  }

  /// Returns cached user data if available
  Future<User?> getCachedUser() async {
    final jsonStr = await LocalStorage.getUserData();
    if (jsonStr == null) return null;
    try {
      return User.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
