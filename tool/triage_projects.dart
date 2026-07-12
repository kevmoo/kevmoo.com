import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

void main(List<String> args) async {
  final dir = Directory('_projects');
  if (!dir.existsSync()) {
    print('No _projects directory found.');
    return;
  }

  final isAccept = args.contains('--accept');
  final isClean = args.contains('--clean');

  if (isClean) {
    await Process.run('dart', ['run', 'tool/clean_projects.dart']);
    return;
  }

  print('🔍 Inspecting personal projects in _projects/...\n');

  var updatedCount = 0;
  for (final file in dir.listSync().whereType<File>().where(
    (f) => f.path.endsWith('.md'),
  )) {
    final content = file.readAsStringSync();
    if (!content.startsWith('---')) continue;

    final parts = content.split('---');
    if (parts.length < 3) continue;

    final yamlMap = loadYaml(parts[1]) as YamlMap;
    final bodyContent = parts.sublist(2).join('---').trim();

    final name = yamlMap['name']?.toString() ?? p.basename(file.path);
    final repo = yamlMap['repo']?.toString();
    final pubPkg = yamlMap['pub_package']?.toString();
    final lastReviewedAtStr = yamlMap['last_reviewed_at']?.toString();
    final lastReviewedAt = lastReviewedAtStr != null
        ? DateTime.tryParse(lastReviewedAtStr)
        : null;

    if (repo == null) continue;

    print('=== 📦 $name ($repo) ===');

    var newVersion = yamlMap['version']?.toString();
    var newStars = yamlMap['stars'] is int
        ? yamlMap['stars'] as int
        : int.tryParse(yamlMap['stars']?.toString() ?? '');
    var newSha = yamlMap['last_reviewed_sha']?.toString();

    // Query Pub.dev for version
    if (pubPkg != null) {
      try {
        final client = HttpClient();
        final req = await client.getUrl(
          Uri.parse('https://pub.dev/api/packages/$pubPkg'),
        );
        final res = await req.close();
        if (res.statusCode == 200) {
          final dataString = await res.transform(utf8.decoder).join();
          final data = json.decode(dataString) as Map<String, dynamic>;
          final latestVer =
              (data['latest'] as Map<String, dynamic>)['version'] as String?;
          if (latestVer != null && latestVer != newVersion) {
            print(
              '  🚀 Pub release: v$latestVer '
              '(current in frontmatter: ${newVersion ?? "none"})',
            );
            newVersion = latestVer;
          } else {
            print('  • Pub version up to date: v${newVersion ?? latestVer}');
          }
        }
        client.close();
      } catch (e) {
        print('  ⚠️ Could not check pub.dev for $pubPkg: $e');
      }
    }

    // Query GitHub for stars and recent commits using gh CLI
    try {
      final repoRes = await Process.run('gh', [
        'api',
        'repos/$repo',
        '--jq',
        '.stargazers_count',
      ]);
      if (repoRes.exitCode == 0) {
        final fetchedStars = int.tryParse(repoRes.stdout.toString().trim());
        if (fetchedStars != null && fetchedStars != newStars) {
          print(
            '  ⭐ Stars updated: $fetchedStars '
            '(previous: ${newStars ?? "none"})',
          );
          newStars = fetchedStars;
        } else {
          print('  • Stars: ${newStars ?? fetchedStars}');
        }
      }

      final commitsArgs = ['api', 'repos/$repo/commits', '--jq', '.[0].sha'];
      if (lastReviewedAt != null) {
        commitsArgs.insert(
          2,
          'repos/$repo/commits?since=${lastReviewedAt.toIso8601String()}',
        );
        commitsArgs.removeAt(3); // replace repos/$repo/commits
      }

      final shaRes = await Process.run('gh', ['api', 'repos/$repo/commits']);
      if (shaRes.exitCode == 0) {
        final commitsList =
            json.decode(shaRes.stdout.toString()) as List<dynamic>;
        if (commitsList.isNotEmpty) {
          final latestCommit = commitsList.first as Map<String, dynamic>;
          newSha = latestCommit['sha']?.toString();

          // Count commits since last review
          var newCommitCount = 0;
          for (final c in commitsList) {
            final commitMap = c as Map<String, dynamic>;
            final commitInfo = commitMap['commit'] as Map<dynamic, dynamic>?;
            final committerInfo =
                commitInfo?['committer'] as Map<dynamic, dynamic>?;
            final dateStr = committerInfo?['date']?.toString();
            if (dateStr != null && lastReviewedAt != null) {
              final commitDate = DateTime.tryParse(dateStr);
              if (commitDate != null && commitDate.isAfter(lastReviewedAt)) {
                newCommitCount++;
              }
            } else if (lastReviewedAt == null) {
              newCommitCount++;
            }
          }
          if (newCommitCount > 0) {
            final sinceMsg = lastReviewedAtStr ?? 'beginning of time';
            print('  📝 $newCommitCount new commit(s) since $sinceMsg');
          } else {
            final sinceMsg = lastReviewedAtStr ?? 'last review';
            print('  • No new commits since $sinceMsg');
          }
        }
      }
    } catch (e) {
      print('  ⚠️ Could not check GitHub API via gh CLI for $repo: $e');
    }

    if (isAccept) {
      final lines = <String>['---'];
      for (final entry in yamlMap.entries) {
        final key = entry.key.toString();
        if (key == 'version' ||
            key == 'stars' ||
            key == 'last_reviewed_sha' ||
            key == 'last_reviewed_at') {
          continue;
        }
        final val = entry.value;
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

      if (newVersion != null) lines.add('version: $newVersion');
      if (newStars != null) lines.add('stars: $newStars');
      if (newSha != null) lines.add('last_reviewed_sha: "$newSha"');
      lines.add(
        'last_reviewed_at: "${DateTime.now().toUtc().toIso8601String()}"',
      );
      lines.add('---');
      if (bodyContent.isNotEmpty) {
        lines.add('');
        lines.add(bodyContent);
      }
      lines.add('');

      file.writeAsStringSync(lines.join('\n'));
      updatedCount++;
      print('  ✅ Updated and accepted state in ${file.path}');
    }
    print('');
  }

  if (isAccept) {
    print('🎉 Accepted triage updates for $updatedCount project(s).');
  } else {
    print(
      '💡 Run `dart run tool/triage_projects.dart --accept` to record '
      'current SHAs/versions and update frontmatter.',
    );
  }
}
