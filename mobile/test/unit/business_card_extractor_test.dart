import 'package:flutter_test/flutter_test.dart';
import 'package:networkhub/features/scan/data/business_card_extractor.dart';

void main() {
  group('BusinessCardExtractor', () {
    test('returns empty DraftContact for empty input', () {
      final result = BusinessCardExtractor.extract('');
      expect(result.firstName, isNull);
      expect(result.lastName, isNull);
      expect(result.email, isNull);
      expect(result.phone, isNull);
      expect(result.company, isNull);
      expect(result.title, isNull);
      expect(result.website, isNull);
      expect(result.linkedinUrl, isNull);
    });

    test('returns empty DraftContact for whitespace-only input', () {
      final result = BusinessCardExtractor.extract('   \n  \n  ');
      expect(result.firstName, isNull);
      expect(result.email, isNull);
    });

    test('extracts email and lowercases it', () {
      final result = BusinessCardExtractor.extract(
        'John Doe\nJohn.Doe@AcmeCorp.COM\n+1 555 123 4567',
      );
      expect(result.email, 'john.doe@acmecorp.com');
    });

    test('extracts phone number filtering out short matches', () {
      final result = BusinessCardExtractor.extract(
        'Jane Smith\njane@example.com\n+380 44 123 4567',
      );
      expect(result.phone, isNotNull);
      expect(result.phone!.replaceAll(RegExp(r'\D'), '').length,
          greaterThanOrEqualTo(7));
    });

    test('does not treat a year as a phone number', () {
      final result = BusinessCardExtractor.extract(
        'Founded 2019\njane@example.com',
      );
      // 2019 is only 4 digits, should not match phone
      expect(result.phone, isNull);
    });

    test('extracts website URL and normalizes to https', () {
      final result = BusinessCardExtractor.extract(
        'John Doe\nwww.acmecorp.com\njohn@acmecorp.com',
      );
      expect(result.website, startsWith('https://'));
      expect(result.website, contains('acmecorp.com'));
    });

    test('does not treat LinkedIn URL as website', () {
      final result = BusinessCardExtractor.extract(
        'John Doe\nlinkedin.com/in/johndoe\nwww.acme.com',
      );
      expect(result.website, contains('acme.com'));
      expect(result.website, isNot(contains('linkedin')));
    });

    test('extracts LinkedIn URL', () {
      final result = BusinessCardExtractor.extract(
        'John Doe\nlinkedin.com/in/johndoe\njohn@acme.com',
      );
      expect(result.linkedinUrl, contains('linkedin.com/in/johndoe'));
    });

    test('extracts job title from known keywords', () {
      final result = BusinessCardExtractor.extract(
        'John Doe\nSenior Engineer\nAcme Corp\njohn@acme.com',
      );
      expect(result.title, 'Senior Engineer');
    });

    test('skips title line if too long (>60 chars)', () {
      final longLine =
          'Senior Engineer and Head of All Global Engineering Departments and More Stuff Here';
      final result = BusinessCardExtractor.extract(
        'John Doe\n$longLine\nAcme Corp\njohn@acme.com',
      );
      // The long line exceeds 60 chars, should not be extracted as title
      expect(result.title != longLine, isTrue);
    });

    test('extracts company name from suffix (Inc, LLC, etc)', () {
      final result = BusinessCardExtractor.extract(
        'John Doe\nSenior Engineer\nAcme Corp Inc.\njohn@acme.com',
      );
      expect(result.company, 'Acme Corp Inc.');
    });

    test('extracts ALL CAPS line as company', () {
      final result = BusinessCardExtractor.extract(
        'John Doe\nSenior Developer\nGLOBAL DYNAMICS\njohn@gd.com',
      );
      expect(result.company, 'GLOBAL DYNAMICS');
    });

    test('does not treat short ALL CAPS as company', () {
      final result = BusinessCardExtractor.extract(
        'CEO\nJohn Doe\njohn@acme.com',
      );
      // "CEO" is only 3 chars, should not be treated as company
      expect(result.company, isNot('CEO'));
    });

    test('extracts name (first and last) from capitalized line', () {
      final result = BusinessCardExtractor.extract(
        'John Doe\nSenior Engineer\nAcme Corp\njohn@acme.com',
      );
      expect(result.firstName, 'John');
      expect(result.lastName, 'Doe');
    });

    test('handles single-word name', () {
      final result = BusinessCardExtractor.extract(
        'Madonna\nSinger\njohn@example.com',
      );
      expect(result.firstName, 'Madonna');
      expect(result.lastName, isNull);
    });

    test('handles three-part name', () {
      final result = BusinessCardExtractor.extract(
        'John Michael Doe\nEngineer\njohn@example.com',
      );
      expect(result.firstName, 'John');
      expect(result.lastName, 'Michael Doe');
    });

    test('full realistic business card extraction', () {
      const cardText = '''
John Smith
Senior Product Manager
Acme Technologies Inc.
jsmith@acmetech.com
+1 (555) 987-6543
www.acmetech.com
linkedin.com/in/johnsmith
''';
      final result = BusinessCardExtractor.extract(cardText);
      expect(result.email, 'jsmith@acmetech.com');
      expect(result.phone, isNotNull);
      expect(result.company, 'Acme Technologies Inc.');
      expect(result.title, 'Senior Product Manager');
      expect(result.firstName, 'John');
      expect(result.lastName, 'Smith');
      expect(result.website, contains('acmetech.com'));
      expect(result.linkedinUrl, contains('linkedin.com/in/johnsmith'));
      expect(result.rawOcrText, cardText);
    });

    test('preserves rawOcrText', () {
      const text = 'some random text';
      final result = BusinessCardExtractor.extract(text);
      expect(result.rawOcrText, text);
    });
  });
}
