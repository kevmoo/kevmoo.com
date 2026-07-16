import 'dart:io';
import 'package:path/path.dart' as p;
import 'models/data_model.dart';
import 'server/content_parser.dart';

final List<Project> projects = List.unmodifiable(_loadProjects());

final Map<String, Project> projectsById = Map.unmodifiable({
  for (final project in projects) project.id: project,
});

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
  final parsed = parseFrontmatterFile(file, requireFrontmatter: true);
  final yamlMap = parsed.frontmatter;

  final name = yamlMap['name']?.toString();
  final repo = yamlMap['repo']?.toString();
  if (name == null || name.trim().isEmpty) {
    throw const FormatException('Missing required field "name"');
  }
  if (repo == null || repo.trim().isEmpty) {
    throw const FormatException('Missing required field "repo"');
  }

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
    contentHtml: parsed.bodyHtml,
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
