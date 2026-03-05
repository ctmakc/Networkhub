class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String requestMagicLink = '/auth/magic-link';
  static const String verifyMagicLink = '/auth/verify';
  static const String getMe = '/auth/me';
  static const String logout = '/auth/logout';

  // Contacts
  static const String contacts = '/contacts';
  static String contact(String id) => '/contacts/$id';
  static String contactInteractions(String id) => '/contacts/$id/interactions';

  // Events
  static const String events = '/events';
  static String event(String id) => '/events/$id';

  // Templates
  static const String templates = '/templates';
  static String template(String id) => '/templates/$id';

  // Email
  static const String sendEmail = '/email/send';
  static String emailJob(String id) => '/email/jobs/$id';

  // Profile discovery
  static String profileDiscovery(String contactId) =>
      '/contacts/$contactId/profile-discovery';
}
