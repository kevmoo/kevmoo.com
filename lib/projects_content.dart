import 'dart:io';
import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class Project {
  final String id;
  final String name;
  final String repo; // e.g. kevmoo/pubviz
  final String? pubPackage; // e.g. pubviz
  final String? installCommand;
  final bool featured;
  final bool ignore;
  final List<String> relatedPostPermalinks;
  final String contentHtml;
  final String? latestVersion;
  final int? githubStars;
  final String? pubUrl;
  final String? githubUrl;
  final String? lastReviewedSha;
  final DateTime? lastReviewedAt;

  Project({
    required this.id,
    required this.name,
    required this.repo,
    this.pubPackage,
    this.installCommand,
    this.featured = false,
    this.ignore = false,
    this.relatedPostPermalinks = const [],
    required this.contentHtml,
    this.latestVersion,
    this.githubStars,
    this.pubUrl,
    this.githubUrl,
    this.lastReviewedSha,
    this.lastReviewedAt,
  });
}

List<Project> get projects => _loadProjects();

List<Project> _loadProjects() {
  final dir = Directory('_projects');
  if (!dir.existsSync()) return [];

  final list = <Project>[];
  for (final file in dir.listSync().whereType<File>().where(
    (f) => f.path.endsWith('.md'),
  )) {
    try {
      final p = parseProjectFile(file);
      if (!p.ignore) list.add(p);
    } catch (e, stack) {
      print('Error parsing project ${file.path}: $e\n$stack');
    }
  }
  // Sort featured first, then alphabetically by name
  list.sort((a, b) {
    if (a.featured != b.featured) {
      return a.featured ? -1 : 1;
    }
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return list;
}

Project parseProjectFile(File file) {
  final content = file.readAsStringSync();
  if (!content.startsWith('---')) {
    throw const FormatException(
      'File does not start with YAML frontmatter delimiter (---)',
    );
  }

  final parts = content.split('---');
  if (parts.length < 3) {
    throw const FormatException(
      'Malformed YAML frontmatter (missing closing ---)',
    );
  }

  final yamlMap = loadYaml(parts[1]);
  if (yamlMap is! YamlMap) {
    throw const FormatException('YAML frontmatter is not a key-value map');
  }

  final name = yamlMap['name']?.toString();
  final repo = yamlMap['repo']?.toString();
  if (name == null || name.trim().isEmpty) {
    throw const FormatException('Missing required field "name"');
  }
  if (repo == null || repo.trim().isEmpty) {
    throw const FormatException('Missing required field "repo"');
  }

  final bodyContent = parts.sublist(2).join('---').trim();
  final contentHtml = md.markdownToHtml(
    bodyContent,
    extensionSet: md.ExtensionSet.gitHubFlavored,
  );

  final id = p.basenameWithoutExtension(file.path);
  final pubPkg = yamlMap['pub_package']?.toString();
  final installCmd =
      yamlMap['install_command']?.toString() ??
      (pubPkg != null ? 'dart pub add $pubPkg' : null);

  DateTime? lastReviewedAt;
  if (yamlMap['last_reviewed_at'] != null) {
    lastReviewedAt = DateTime.tryParse(yamlMap['last_reviewed_at'].toString());
  }

  return Project(
    id: id,
    name: name,
    repo: repo,
    pubPackage: pubPkg,
    installCommand: installCmd,
    featured: yamlMap['featured'] == true,
    ignore: yamlMap['ignore'] == true,
    relatedPostPermalinks:
        (yamlMap['related_posts'] as YamlList?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
    contentHtml: contentHtml,
    latestVersion: yamlMap['version']?.toString(),
    githubStars: yamlMap['stars'] is int
        ? yamlMap['stars'] as int
        : int.tryParse(yamlMap['stars']?.toString() ?? ''),
    pubUrl: pubPkg != null ? 'https://pub.dev/packages/$pubPkg' : null,
    githubUrl: 'https://github.com/$repo',
    lastReviewedSha: yamlMap['last_reviewed_sha']?.toString(),
    lastReviewedAt: lastReviewedAt,
  );
}
