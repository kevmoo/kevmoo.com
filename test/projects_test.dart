import 'dart:io';
import 'package:test/test.dart';
import 'package:work_j832_com/projects_content.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('_projects/ verification', () {
    final projectsDir = Directory('_projects');

    test('_projects directory exists', () {
      expect(projectsDir.existsSync(), isTrue);
    });

    final files = projectsDir.existsSync()
        ? projectsDir
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.md'))
              .toList()
        : <File>[];

    test('at least one markdown file exists in _projects', () {
      expect(files, isNotEmpty);
    });

    for (final file in files) {
      test('verify ${file.path}', () {
        final content = file.readAsStringSync();
        expect(
          content,
          startsWith('---'),
          reason: 'Must start with YAML frontmatter',
        );

        final parts = content.split('---');
        expect(
          parts.length,
          greaterThanOrEqualTo(3),
          reason: 'Must contain closing --- for frontmatter',
        );

        final yamlMap = loadYaml(parts[1]);
        expect(
          yamlMap,
          isA<YamlMap>(),
          reason: 'Frontmatter must be a valid YAML map',
        );
        final map = yamlMap as YamlMap;

        // Verify required fields
        expect(map.containsKey('name'), isTrue, reason: 'Must define "name"');
        expect(
          map['name'].toString().trim(),
          isNotEmpty,
          reason: '"name" must not be empty',
        );

        expect(map.containsKey('repo'), isTrue, reason: 'Must define "repo"');
        expect(
          map['repo'].toString().trim(),
          isNotEmpty,
          reason: '"repo" must not be empty',
        );

        // Verify no redundant defaults
        if (map.containsKey('featured')) {
          expect(
            map['featured'],
            isTrue,
            reason: 'If defined, "featured" must be true; omit key if false',
          );
        }

        if (map.containsKey('ignore')) {
          expect(
            map['ignore'],
            isTrue,
            reason: 'If defined, "ignore" must be true; omit key if false',
          );
        }

        if (map.containsKey('related_posts')) {
          final posts = map['related_posts'] as YamlList;
          expect(
            posts,
            isA<YamlList>(),
            reason: '"related_posts" must be a list',
          );
          expect(
            posts,
            isNotEmpty,
            reason: 'If defined, "related_posts" must not be empty; omit if []',
          );
        }

        if (map.containsKey('install_command')) {
          final cmd = map['install_command'].toString().trim();
          expect(
            cmd,
            isNotEmpty,
            reason:
                '"install_command" must not be empty string; '
                'omit if not needed',
          );
          if (map.containsKey('pub_package')) {
            final pubPkg = map['pub_package'].toString().trim();
            expect(
              cmd,
              isNot(equals('dart pub add $pubPkg')),
              reason:
                  '"install_command" is redundant when it equals default '
                  '"dart pub add $pubPkg"; strip it out',
            );
          }
        }

        if (map.containsKey('last_reviewed_at')) {
          final parsedDate = DateTime.tryParse(
            map['last_reviewed_at'].toString(),
          );
          expect(
            parsedDate,
            isNotNull,
            reason: '"last_reviewed_at" must be a valid ISO-8601 date string',
          );
        }

        // Verify parsing via parseProjectFile does not throw
        expect(() => parseProjectFile(file), returnsNormally);
      });
    }
  });
}
