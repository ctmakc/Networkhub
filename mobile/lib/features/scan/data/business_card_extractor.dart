import 'package:networkhub/features/scan/data/scan_models.dart';

/// Extracts structured fields from raw OCR text of a business card
class BusinessCardExtractor {
  // Email regex
  static final _emailRegex = RegExp(
    r'\b[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}\b',
    caseSensitive: false,
  );

  // Phone: supports international formats
  static final _phoneRegex = RegExp(
    r'(?:\+\d{1,3}[\s.-]?)?'
    r'(?:\(?\d{1,4}\)?[\s.\-]?)?'
    r'(?:\d{1,4}[\s.\-]?){2,4}'
    r'\d{1,4}',
    caseSensitive: false,
  );

  // Website / URL
  static final _websiteRegex = RegExp(
    r'(?:https?://)?(?:www\.)?[a-zA-Z0-9\-]+(?:\.[a-zA-Z]{2,})+(?:/[^\s]*)?',
    caseSensitive: false,
  );

  // LinkedIn URL
  static final _linkedinRegex = RegExp(
    r'(?:https?://)?(?:www\.)?linkedin\.com/in/[a-zA-Z0-9\-_]+/?',
    caseSensitive: false,
  );

  // Job titles - common patterns
  static final _titleKeywords = [
    'CEO', 'CTO', 'CFO', 'COO', 'CMO', 'CIO', 'CISO', 'CPO',
    'President', 'Vice President', 'VP', 'SVP', 'EVP',
    'Director', 'Senior Director', 'Managing Director',
    'Manager', 'Senior Manager', 'General Manager',
    'Engineer', 'Senior Engineer', 'Principal Engineer', 'Staff Engineer',
    'Developer', 'Software Developer', 'Senior Developer',
    'Designer', 'UX Designer', 'Product Designer',
    'Analyst', 'Business Analyst', 'Data Analyst',
    'Consultant', 'Senior Consultant', 'Principal Consultant',
    'Associate', 'Senior Associate',
    'Partner', 'Managing Partner',
    'Founder', 'Co-Founder',
    'Head of', 'Lead', 'Tech Lead',
    'Account Executive', 'Account Manager',
    'Sales', 'Marketing', 'Operations',
    'Researcher', 'Scientist', 'Professor', 'Doctor', 'Dr.',
    'Coordinator', 'Specialist', 'Representative',
    'Intern', 'Trainee',
  ];

  // Common company suffixes
  static final _companySuffixRegex = RegExp(
    r'\b(?:Inc\.?|LLC|Ltd\.?|Corp\.?|Co\.?|Group|Holdings|Solutions|Services|Technologies|Tech|Systems|Consulting|International|Global|Enterprises|Associates|Partners)\b',
    caseSensitive: false,
  );

  /// Extract structured contact info from raw OCR text
  static DraftContact extract(String rawText) {
    if (rawText.trim().isEmpty) {
      return DraftContact(rawOcrText: rawText);
    }

    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final email = _extractEmail(rawText);
    final phone = _extractPhone(rawText, email);
    final website = _extractWebsite(rawText, email);
    final linkedin = _extractLinkedIn(rawText);
    final title = _extractTitle(lines);
    final company = _extractCompany(lines, title);
    final name = _extractName(lines, email, phone, website, title, company);

    String? firstName;
    String? lastName;

    if (name != null) {
      final nameParts = name.trim().split(RegExp(r'\s+'));
      if (nameParts.length >= 2) {
        firstName = nameParts.first;
        lastName = nameParts.sublist(1).join(' ');
      } else if (nameParts.length == 1) {
        firstName = nameParts.first;
      }
    }

    return DraftContact(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      company: company,
      title: title,
      website: website,
      linkedinUrl: linkedin,
      rawOcrText: rawText,
    );
  }

  static String? _extractEmail(String text) {
    final match = _emailRegex.firstMatch(text);
    return match?.group(0)?.toLowerCase();
  }

  static String? _extractPhone(String text, String? email) {
    // Remove email to avoid matching parts of it
    final cleanText = email != null ? text.replaceAll(email, '') : text;

    final matches = _phoneRegex.allMatches(cleanText);
    for (final match in matches) {
      final candidate = match.group(0)?.trim() ?? '';
      // Filter out short matches and things that look like years or zip codes
      final digitsOnly = candidate.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.length >= 7 && digitsOnly.length <= 15) {
        // Make sure it's not just a year or short number
        if (!RegExp(r'^(?:19|20)\d{2}$').hasMatch(digitsOnly)) {
          return candidate;
        }
      }
    }
    return null;
  }

  static String? _extractWebsite(String text, String? email) {
    final emailDomain = email != null ? email.split('@').last : null;

    final matches = _websiteRegex.allMatches(text);
    for (final match in matches) {
      final candidate = match.group(0)?.trim() ?? '';

      // Skip LinkedIn URLs (handled separately)
      if (candidate.toLowerCase().contains('linkedin.com')) continue;

      // Skip email-like patterns
      if (email != null && candidate.contains(email)) continue;

      // Prefer company website that shares domain with email
      if (emailDomain != null && candidate.toLowerCase().contains(emailDomain)) {
        return _normalizeUrl(candidate);
      }

      // Skip if it's just a TLD with no meaningful domain
      if (candidate.split('.').length < 2) continue;
      if (candidate.length < 5) continue;

      return _normalizeUrl(candidate);
    }
    return null;
  }

  static String? _extractLinkedIn(String text) {
    final match = _linkedinRegex.firstMatch(text);
    return match?.group(0);
  }

  static String? _extractTitle(List<String> lines) {
    for (final line in lines) {
      final lineLower = line.toLowerCase();
      for (final keyword in _titleKeywords) {
        if (lineLower.contains(keyword.toLowerCase())) {
          // Make sure the line isn't too long (company name vs title)
          if (line.length <= 60) {
            return line;
          }
        }
      }
    }
    return null;
  }

  static String? _extractCompany(List<String> lines, String? title) {
    for (final line in lines) {
      if (line == title) continue;

      // Check if line contains common company suffixes
      if (_companySuffixRegex.hasMatch(line)) {
        return line;
      }

      // Check if line is ALL CAPS (common for company names on business cards)
      if (line.length > 3 &&
          line == line.toUpperCase() &&
          !line.contains('@') &&
          !RegExp(r'^\d').hasMatch(line)) {
        return line;
      }
    }
    return null;
  }

  static String? _extractName(
    List<String> lines,
    String? email,
    String? phone,
    String? website,
    String? title,
    String? company,
  ) {
    // Build a set of "used" lines to skip
    final skipLines = <String>{};
    if (email != null) skipLines.add(email);
    if (phone != null) skipLines.add(phone);
    if (website != null) skipLines.add(website);
    if (title != null) skipLines.add(title);
    if (company != null) skipLines.add(company);

    for (final line in lines) {
      if (skipLines.contains(line)) continue;
      if (line.contains('@')) continue; // email
      if (_phoneRegex.hasMatch(line) &&
          line.replaceAll(RegExp(r'\D'), '').length >= 7) continue;
      if (_websiteRegex.hasMatch(line) && line.contains('.')) continue;

      // A name line typically:
      // - Has 2-3 words
      // - Each word starts with a capital
      // - No numbers (except suffixes like Jr., II, etc.)
      final words = line.split(RegExp(r'\s+'));
      if (words.length >= 1 && words.length <= 5) {
        final appearsToBeAName = words.every((word) {
          if (word.isEmpty) return false;
          if (RegExp(r'^\d').hasMatch(word)) return false; // starts with number
          return word[0] == word[0].toUpperCase() || word.length <= 2;
        });

        if (appearsToBeAName && line.length >= 3 && line.length <= 50) {
          return line;
        }
      }
    }
    return null;
  }

  static String _normalizeUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }
}
