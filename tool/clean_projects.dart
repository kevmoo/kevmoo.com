import 'dart:io';

import 'package:work_j832_com/server/content_parser.dart';
import 'package:yaml/yaml.dart';

void main() {
  final dir = Directory('_projects');
  if (!dir.existsSync()) {
    print('No _projects directory found.');
    return;
  }

  var modifiedCount = 0;
  for (final file in dir.listSync().whereType<File>().where(
    (f) => f.path.endsWith('.md'),
  )) {
    final content = file.readAsStringSync();
    if (!content.startsWith('---')) continue;

    final ParsedContent parsed;
    try {
      parsed = parseFrontmatterString(content, requireFrontmatter: true);
    } catch (e) {
      print('Warning: Failed to parse frontmatter in ${file.path}: $e');
      continue;
    }

    final yamlMap = parsed.frontmatter;
    final bodyContent = parsed.bodyMarkdown;

    final pubPkg = yamlMap['pub_package']?.toString();
    final lines = <String>['---'];

    for (final entry in yamlMap.entries) {
      final key = entry.key.toString();
      final val = entry.value;

      // Strip redundant defaults
      if (key == 'featured' && val == false) continue;
      if (key == 'ignore' && val == false) continue;
      if (key == 'related_posts' &&
          ((val is YamlList && val.isEmpty) || val == null)) {
        continue;
      }
      if (key == 'install_command') {
        final cmdStr = val?.toString().trim() ?? '';
        if (cmdStr.isEmpty) continue;
        if (pubPkg != null && cmdStr == 'dart pub add $pubPkg') continue;
      }
      if (key == 'last_reviewed_sha' &&
          (val?.toString().trim().isEmpty ?? true)) {
        continue;
      }

      if (val is YamlList) {
        lines.add('$key:');
        for (final item in val) {
          lines.add('  - $item');
        }
      } else if (val is String &&
          (val.contains(':') || val.contains(' ') || val.contains('#'))) {
        lines.add('$key: "$val"');
      } else {
        lines.add('$key: $val');
      }
    }
    lines.add('---');
    if (bodyContent.isNotEmpty) {
      lines.add('');
      lines.add(bodyContent);
    }
    lines.add('');

    final newContent = lines.join('\n');
    if (newContent != content) {
      file.writeAsStringSync(newContent);
      modifiedCount++;
      print('Cleaned ${file.path}');
    }
  }
  print('✅ Cleaned and normalized $modifiedCount file(s) in _projects/.');
}
