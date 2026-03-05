import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage._();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _onboardingKey = 'onboarding_complete';
  static const String _defaultTemplateKey = 'default_template_id';
  static const String _userNameKey = 'user_name';
  static const String _userSignatureKey = 'user_signature';
  static const String _userEmailKey = 'user_email';

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  // Token
  static Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  static Future<void> setToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // User data (stored as JSON string)
  static Future<String?> getUserData() async {
    final prefs = await _prefs;
    return prefs.getString(_userKey);
  }

  static Future<void> setUserData(String jsonData) async {
    final prefs = await _prefs;
    await prefs.setString(_userKey, jsonData);
  }

  static Future<void> clearUserData() async {
    final prefs = await _prefs;
    await prefs.remove(_userKey);
  }

  // User profile fields
  static Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString(_userNameKey);
  }

  static Future<void> setUserName(String name) async {
    final prefs = await _prefs;
    await prefs.setString(_userNameKey, name);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await _prefs;
    return prefs.getString(_userEmailKey);
  }

  static Future<void> setUserEmail(String email) async {
    final prefs = await _prefs;
    await prefs.setString(_userEmailKey, email);
  }

  static Future<String?> getUserSignature() async {
    final prefs = await _prefs;
    return prefs.getString(_userSignatureKey);
  }

  static Future<void> setUserSignature(String signature) async {
    final prefs = await _prefs;
    await prefs.setString(_userSignatureKey, signature);
  }

  // Onboarding
  static Future<bool> isOnboardingComplete() async {
    final prefs = await _prefs;
    return prefs.getBool(_onboardingKey) ?? false;
  }

  static Future<void> setOnboardingComplete(bool complete) async {
    final prefs = await _prefs;
    await prefs.setBool(_onboardingKey, complete);
  }

  // Default template
  static Future<String?> getDefaultTemplateId() async {
    final prefs = await _prefs;
    return prefs.getString(_defaultTemplateKey);
  }

  static Future<void> setDefaultTemplateId(String id) async {
    final prefs = await _prefs;
    await prefs.setString(_defaultTemplateKey, id);
  }

  // Clear all
  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
