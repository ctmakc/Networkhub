import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:8000/api/v1';

  static String get appName => dotenv.env['APP_NAME'] ?? 'NetworkHub';

  static Duration get connectTimeout => const Duration(seconds: 30);
  static Duration get receiveTimeout => const Duration(seconds: 30);
  static Duration get sendTimeout => const Duration(seconds: 30);

  static int get maxRetryAttempts => 3;
  static Duration get retryDelay => const Duration(seconds: 2);

  static bool get isDebug =>
      const bool.fromEnvironment('dart.vm.product') == false;
}
