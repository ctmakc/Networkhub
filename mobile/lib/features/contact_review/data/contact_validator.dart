/// Validates and normalizes contact fields
class ContactValidator {
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  static final _phoneCleanRegex = RegExp(r'[^\d+\-\s().]');

  /// Validate email format
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  /// Validate email with error message
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    if (!isValidEmail(value)) return 'Please enter a valid email address';
    return null;
  }

  /// Validate required email
  static String? validateRequiredEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!isValidEmail(value)) return 'Please enter a valid email address';
    return null;
  }

  /// Validate phone (lenient)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) return 'Phone number is too short';
    if (digits.length > 15) return 'Phone number is too long';
    return null;
  }

  /// Normalize phone number: strip extra whitespace, keep + prefix
  static String normalizePhone(String phone) {
    final trimmed = phone.trim();
    // Remove characters that shouldn't be in a phone number
    return trimmed.replaceAll(_phoneCleanRegex, '').trim();
  }

  /// Normalize URL: ensure https:// prefix
  static String normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return 'https://$trimmed';
    }
    return trimmed;
  }

  /// Validate URL format
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = normalizeUrl(value);
    try {
      final uri = Uri.parse(normalized);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return 'Please enter a valid URL';
      }
    } catch (_) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  /// Validate name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 1) return 'Name is too short';
    return null;
  }

  /// Validate that at least one of first name or last name is provided
  static String? validateContactName(String? firstName, String? lastName) {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    if (first.isEmpty && last.isEmpty) {
      return 'Please provide at least a first or last name';
    }
    return null;
  }
}
