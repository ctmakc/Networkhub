import 'package:networkhub/features/scan/data/scan_models.dart';

/// Parses vCard 2.1 and 3.0 format strings into DraftContact
class VCardParser {
  /// Parse a vCard string and return a DraftContact
  static DraftContact parse(String vcard) {
    final lines = _unfoldLines(vcard);
    final properties = _parseProperties(lines);

    String? firstName;
    String? lastName;
    String? email;
    String? phone;
    String? company;
    String? title;
    String? website;
    String? address;
    String? notes;

    for (final entry in properties.entries) {
      final key = entry.key.toUpperCase();
      final value = entry.value;

      if (key == 'N' || key.startsWith('N;')) {
        // N:LastName;FirstName;MiddleName;Prefix;Suffix
        final parts = _decodeValue(value).split(';');
        if (parts.isNotEmpty) {
          lastName = parts[0].trim().isNotEmpty ? parts[0].trim() : null;
        }
        if (parts.length > 1) {
          firstName = parts[1].trim().isNotEmpty ? parts[1].trim() : null;
        }
      } else if (key == 'FN' || key.startsWith('FN;')) {
        // FN (Formatted Name) - use as fallback
        final fullName = _decodeValue(value).trim();
        if (firstName == null && lastName == null && fullName.isNotEmpty) {
          final nameParts = fullName.split(' ');
          if (nameParts.length >= 2) {
            firstName = nameParts.first;
            lastName = nameParts.sublist(1).join(' ');
          } else {
            firstName = fullName;
          }
        }
      } else if (key.startsWith('EMAIL') || key == 'EMAIL') {
        final decoded = _decodeValue(value).trim();
        if (decoded.isNotEmpty && email == null) {
          email = decoded;
        }
      } else if (key.startsWith('TEL') || key == 'TEL') {
        final decoded = _decodeValue(value).trim();
        if (decoded.isNotEmpty && phone == null) {
          phone = decoded;
        }
      } else if (key == 'ORG' || key.startsWith('ORG;')) {
        final decoded = _decodeValue(value).trim();
        if (decoded.isNotEmpty) {
          // ORG can be: Company;Department
          company = decoded.split(';').first.trim();
        }
      } else if (key == 'TITLE' || key.startsWith('TITLE;')) {
        title = _decodeValue(value).trim();
        if (title.isEmpty) title = null;
      } else if (key.startsWith('URL') || key == 'URL') {
        final decoded = _decodeValue(value).trim();
        if (decoded.isNotEmpty && website == null) {
          website = decoded;
        }
      } else if (key.startsWith('ADR') || key == 'ADR') {
        // ADR: PO Box;Extended;Street;City;State;ZIP;Country
        final decoded = _decodeValue(value).trim();
        if (decoded.isNotEmpty && address == null) {
          address = decoded.replaceAll(';', ', ').replaceAll(RegExp(r',\s*,'), ',').trim();
        }
      } else if (key == 'NOTE' || key.startsWith('NOTE;')) {
        notes = _decodeValue(value).trim();
        if (notes.isEmpty) notes = null;
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
      address: address,
      notes: notes,
      rawVcard: vcard,
    );
  }

  /// Check if a string looks like a vCard
  static bool isVCard(String text) {
    return text.trim().toUpperCase().startsWith('BEGIN:VCARD');
  }

  /// Unfold multi-line vCard fields
  static List<String> _unfoldLines(String vcard) {
    // RFC 2425/2426 line folding: continuation lines start with space or tab
    final unfolded = vcard.replaceAll(RegExp(r'\r\n[ \t]'), '').replaceAll(RegExp(r'\n[ \t]'), '');
    return unfolded.split(RegExp(r'\r\n|\n|\r'));
  }

  /// Parse vCard properties into a map
  static Map<String, String> _parseProperties(List<String> lines) {
    final properties = <String, String>{};
    bool inVCard = false;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.toUpperCase() == 'BEGIN:VCARD') {
        inVCard = true;
        continue;
      }
      if (trimmed.toUpperCase() == 'END:VCARD') {
        inVCard = false;
        continue;
      }
      if (!inVCard) continue;

      final colonIndex = trimmed.indexOf(':');
      if (colonIndex < 0) continue;

      final key = trimmed.substring(0, colonIndex);
      final value = trimmed.substring(colonIndex + 1);

      // Handle multiple values for same key (e.g. multiple TEL, EMAIL)
      final baseKey = key.split(';').first.toUpperCase();
      if (properties.containsKey(baseKey)) {
        // Use key with type for disambiguation
        properties[key.toUpperCase()] = value;
      } else {
        properties[baseKey] = value;
        properties[key.toUpperCase()] = value;
      }
    }

    return properties;
  }

  /// Decode vCard encoded value (quoted-printable, base64, utf-8)
  static String _decodeValue(String value) {
    // Handle quoted-printable encoding
    if (value.contains('=')) {
      return _decodeQuotedPrintable(value);
    }
    // Handle backslash escapes
    return value
        .replaceAll('\\n', '\n')
        .replaceAll('\\N', '\n')
        .replaceAll('\\,', ',')
        .replaceAll('\\;', ';')
        .replaceAll('\\\\', '\\');
  }

  static String _decodeQuotedPrintable(String input) {
    final buffer = StringBuffer();
    int i = 0;
    while (i < input.length) {
      if (input[i] == '=' && i + 2 < input.length) {
        final hex = input.substring(i + 1, i + 3);
        if (RegExp(r'^[0-9A-Fa-f]{2}$').hasMatch(hex)) {
          buffer.writeCharCode(int.parse(hex, radix: 16));
          i += 3;
          continue;
        }
      }
      buffer.write(input[i]);
      i++;
    }
    return buffer.toString();
  }
}
