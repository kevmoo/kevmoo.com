import 'package:checks/checks.dart';
import 'package:test/test.dart';
import 'package:work_j832_com/server/content_parser.dart';

void main() {
  group('Content Parser Tests', () {
    test('Parse valid frontmatter', () {
      const content = '''
---
title: Hello World
tags:
  - dart
  - jaspr
---
This is the body.
''';
      final parsed = parseFrontmatterString(content, requireFrontmatter: true);
      check(parsed.frontmatter['title'].toString()).equals('Hello World');
      check(parsed.frontmatter['tags']).isA<List<dynamic>>();
      check(parsed.bodyMarkdown).equals('This is the body.');
    });

    test('Parse optional frontmatter when not present', () {
      const content = 'This is just markdown without frontmatter.';
      final parsed = parseFrontmatterString(content, requireFrontmatter: false);
      check(parsed.frontmatter).isEmpty();
      check(parsed.bodyMarkdown).equals(content);
    });

    test('Throw on missing frontmatter when requireFrontmatter is true', () {
      const content = 'This is just markdown without frontmatter.';
      check(
        () => parseFrontmatterString(content, requireFrontmatter: true),
      ).throws<FormatException>();
    });

    test('Gracefully handle malformed closing delimiter when '
        'requireFrontmatter is false', () {
      const content = '''
---
title: No closing delimiter
This is the body that starts with horizontal rule-like delimiter
''';
      final parsed = parseFrontmatterString(content, requireFrontmatter: false);
      check(parsed.frontmatter).isEmpty();
      check(parsed.bodyMarkdown).equals(content);
    });

    test(
      'Throw on malformed closing delimiter when requireFrontmatter is true',
      () {
        const content = '''
---
title: No closing delimiter
This is the body.
''';
        check(
          () => parseFrontmatterString(content, requireFrontmatter: true),
        ).throws<FormatException>();
      },
    );

    test('Gracefully handle invalid YAML when requireFrontmatter is false', () {
      const content = '''
---
invalid: yaml: parsing: error: here
---
Body
''';
      final parsed = parseFrontmatterString(content, requireFrontmatter: false);
      check(parsed.frontmatter).isEmpty();
      check(parsed.bodyMarkdown).equals(content);
    });

    test('Throw on invalid YAML when requireFrontmatter is true', () {
      const content = '''
---
invalid: yaml: parsing: error: here
---
Body
''';
      check(
        () => parseFrontmatterString(content, requireFrontmatter: true),
      ).throws<FormatException>();
    });
  });
}
