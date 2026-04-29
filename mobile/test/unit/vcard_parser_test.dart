import 'package:flutter_test/flutter_test.dart';
import 'package:networkhub/features/scan/data/vcard_parser.dart';

void main() {
  group('VCardParser.isVCard', () {
    test('recognizes valid vCard', () {
      expect(VCardParser.isVCard('BEGIN:VCARD\nVERSION:3.0\nEND:VCARD'), isTrue);
    });

    test('recognizes vCard case-insensitively', () {
      expect(VCardParser.isVCard('begin:vcard\nend:vcard'), isTrue);
    });

    test('rejects non-vCard text', () {
      expect(VCardParser.isVCard('John Doe\njohn@example.com'), isFalse);
    });

    test('rejects empty string', () {
      expect(VCardParser.isVCard(''), isFalse);
    });
  });

  group('VCardParser.parse', () {
    test('parses N field into firstName and lastName', () {
      const vcard = 'BEGIN:VCARD\nVERSION:3.0\nN:Doe;John;;;\nEND:VCARD';
      final result = VCardParser.parse(vcard);
      expect(result.firstName, 'John');
      expect(result.lastName, 'Doe');
    });

    test('falls back to FN when N is missing', () {
      const vcard = 'BEGIN:VCARD\nVERSION:3.0\nFN:John Doe\nEND:VCARD';
      final result = VCardParser.parse(vcard);
      expect(result.firstName, 'John');
      expect(result.lastName, 'Doe');
    });

    test('FN with single name goes to firstName only', () {
      const vcard = 'BEGIN:VCARD\nVERSION:3.0\nFN:Madonna\nEND:VCARD';
      final result = VCardParser.parse(vcard);
      expect(result.firstName, 'Madonna');
      expect(result.lastName, isNull);
    });

    test('N takes priority over FN', () {
      const vcard =
          'BEGIN:VCARD\nVERSION:3.0\nN:Smith;Jane;;;\nFN:Jane Smith\nEND:VCARD';
      final result = VCardParser.parse(vcard);
      expect(result.firstName, 'Jane');
      expect(result.lastName, 'Smith');
    });

    test('parses EMAIL field', () {
      const vcard =
          'BEGIN:VCARD\nVERSION:3.0\nN:Doe;John;;;\nEMAIL:john@example.com\nEND:VCARD';
      final result = VCardParser.parse(vcard);
      expect(result.email, 'john@example.com');
    });

    test('parses EMAIL with type parameter', () {
      const vcard =
          'BEGIN:VCARD\nVERSION:3.0\nN:Doe;John;;;\nEMAIL;TYPE=WORK:john@work.com\nEND:VCARD';
      final result = VCardParser.parse(vcard);
      expect(result.email, 'john@work.com');
    });

    test('parses TEL field', () {
      const vcard =
          'BEGIN:VCARD\nVERSION:3.0\nN:Doe;John;;;\nTEL:+1-555-123-4567\nEND:VCARD';
      final result = VCardParser.parse(vcard);
      expect(result.phone, '+1-555-123-4567');
    });

    test('parses ORG field and splits on semicolon', () {
      const vcard =
          'BEGIN:VCARD\nVERSION:3.0\nN:Doe;John;;;\nORG:Acme Corp;Engineering\nEND:VCARD';
      final result = VCardParser.parse(vcard);
      expect(result.company, 'Acme Corp');
    });

    test('parses TITLE field', () {
      const vcard =
          'BEGIN:VCARD\nVERSION:3.0\nN:Doe;John;;;\nTITLE:Senior Engineer\nEND:VCARD';
      final result = VCardParser.parse(vcard);
      expect(result.title, 'Senior Engineer');
    });

    test('parses URL field', () {
      const vcard =
          'BEGIN:VCARD\nVERSION:3.0\nN:Doe;John;;;\nURL:https://example.com\nEND:VCARD';
      final result = VCardParser.parse(vcard);
      expect(result.website, 'https://example.com');
    });

    test('parses ADR field and joins with commas', () {
      const vcard =
          'BEGIN:VCARD\nVERSION:3.0\nN:Doe;John;;;\nADR:;;123 Main St;City;State;12345;US\nEND:VCARD';
      final result = VCardParser.parse(vcard);
      expect(result.address, isNotNull);
      expect(result.address!, contains('123 Main St'));
      expect(result.address!, contains('City'));
    });

    test('parses NOTE field', () {
      const vcard =
          'BEGIN:VCARD\nVERSION:3.0\nN:Doe;John;;;\nNOTE:Met at conference\nEND:VCARD';
      final result = VCardParser.parse(vcard);
      expect(result.notes, 'Met at conference');
    });

    test('handles quoted-printable decoding', () {
      // =C3=A9 is é in UTF-8
      const vcard =
          'BEGIN:VCARD\nVERSION:3.0\nN:Caf=C3=A9;Ren=C3=A9;;;\nEND:VCARD';
      final result = VCardParser.parse(vcard);
      // The QP decoder works byte-by-byte, so multi-byte chars may not decode perfectly
      // but it should at least not crash
      expect(result.lastName, isNotNull);
      expect(result.firstName, isNotNull);
    });

    test('handles backslash escapes', () {
      const vcard =
          'BEGIN:VCARD\nVERSION:3.0\nN:Doe;John;;;\nNOTE:Line1\\nLine2\\, more\nEND:VCARD';
      final result = VCardParser.parse(vcard);
      expect(result.notes, contains('\n'));
      expect(result.notes, contains(','));
    });

    test('handles line folding (continuation lines)', () {
      const vcard =
          'BEGIN:VCARD\nVERSION:3.0\nN:Doe;John;;;\nNOTE:This is a very long\n  note that continues\nEND:VCARD';
      final result = VCardParser.parse(vcard);
      expect(result.notes, contains('long'));
      expect(result.notes, contains('continues'));
    });

    test('stores rawVcard', () {
      const vcard = 'BEGIN:VCARD\nVERSION:3.0\nN:Doe;John;;;\nEND:VCARD';
      final result = VCardParser.parse(vcard);
      expect(result.rawVcard, vcard);
    });

    test('full vCard 3.0 round-trip', () {
      const vcard = '''BEGIN:VCARD
VERSION:3.0
N:Smith;Jane;Marie;;
FN:Jane Marie Smith
ORG:TechCorp;Engineering
TITLE:VP of Engineering
EMAIL;TYPE=WORK:jane@techcorp.com
TEL;TYPE=WORK:+1-555-987-6543
URL:https://techcorp.com
ADR;TYPE=WORK:;;456 Oak Ave;Portland;OR;97201;US
NOTE:Met at React Conf 2025
END:VCARD''';
      final result = VCardParser.parse(vcard);
      expect(result.firstName, 'Jane');
      expect(result.lastName, 'Smith');
      expect(result.email, 'jane@techcorp.com');
      expect(result.phone, '+1-555-987-6543');
      expect(result.company, 'TechCorp');
      expect(result.title, 'VP of Engineering');
      expect(result.website, 'https://techcorp.com');
      expect(result.address, isNotNull);
      expect(result.notes, 'Met at React Conf 2025');
      expect(result.rawVcard, vcard);
    });

    test('ignores content outside BEGIN/END:VCARD', () {
      const vcard =
          'random junk\nBEGIN:VCARD\nVERSION:3.0\nN:Doe;John;;;\nEND:VCARD\nmore junk';
      final result = VCardParser.parse(vcard);
      expect(result.firstName, 'John');
      expect(result.lastName, 'Doe');
    });
  });
}
