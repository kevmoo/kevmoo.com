import 'dart:io';
import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';
import 'package:yaml/yaml.dart';
import 'constants.dart';
import 'models/data_model.dart';
import 'server/content_parser.dart';

export 'models/data_model.dart';

final List<Post> posts = List.unmodifiable(_loadPosts());

List<Post> _loadPosts() {
  final postsList = <Post>[];
  final dir = Directory('_posts');
  if (!dir.existsSync()) {
    throw Exception('Error: _posts directory not found.');
  }

  final files = dir
      .listSync()
      .whereType<File>()
      .where(
        (f) =>
            f.path.endsWith('.md') ||
            f.path.endsWith('.html') ||
            f.path.endsWith('.yaml'),
      )
      .toList();

  for (final file in files) {
    try {
      final filename = p.basename(file.path);
      final content = file.readAsStringSync();

      // Parse YAML Appearance files
      if (file.path.endsWith('.yaml')) {
        final yaml = loadYaml(content) as YamlMap;
        postsList.add(_parseYamlPost(file.path, yaml));
        continue;
      }

      // Parse Jekyll frontmatter for standard posts
      postsList.add(_parseJekyllPost(file.path, filename, content));
    } catch (e, stack) {
      print('Error parsing file ${file.path}: $e\n$stack');
    }
  }

  // Sort posts chronologically descending
  postsList.sort((a, b) => b.date.compareTo(a.date));
  return postsList;
}

Post _parseYamlPost(String filePath, YamlMap yaml) {
  if (yaml case {
    'title': String title,
    'subTitle': String subTitle,
    'uri': String uri,
    'flavor': String flavorStr,
    'date': Object dateObj,
  }) {
    final date = switch (dateObj) {
      DateTime d => d,
      String s =>
        DateTime.tryParse(s) ??
            (throw FormatException('Invalid date format: $s in $filePath')),
      _ => throw FormatException(
        'Date must be a String or DateTime, got '
        '${dateObj.runtimeType} in $filePath',
      ),
    };

    final flavor = EntryFlavor.values.byName(flavorStr);

    final tags = <String>[];
    final yamlTags = yaml['tags'] ?? yaml['topics'];
    if (yamlTags is YamlList) {
      tags.addAll(yamlTags.map((e) => e.toString()));
    } else if (yamlTags is List) {
      tags.addAll(yamlTags.map((e) => e.toString()));
    }

    return Post(
      permalink: '',
      title: title,
      subTitle: subTitle,
      date: date,
      tags: tags,
      contentHtml: null,
      isHtml: false,
      uri: uri,
      flavor: flavor,
    );
  } else {
    throw FormatException('Invalid YAML structure in $filePath');
  }
}

final _fileDateRegExp = RegExp(r'^(\d{4})-(\d{2})-(\d{2})-(.+)\.(md|html)$');
final _markdownCleanupRegExp = RegExp(r'\{:\s*[^}]*\}');

Post _parseJekyllPost(String filePath, String filename, String content) {
  final parsed = parseFrontmatterString(content, requireFrontmatter: true);
  final yaml = parsed.frontmatter;
  final title = yaml['title']?.toString() ?? 'Untitled';

  // Extract date from filename
  final fileDateMatch = _fileDateRegExp.firstMatch(filename);
  if (fileDateMatch == null) {
    throw FormatException(
      'Filename does not start with YYYY-MM-DD prefix in $filePath',
    );
  }

  final year = int.parse(fileDateMatch.group(1)!);
  final month = int.parse(fileDateMatch.group(2)!);
  final day = int.parse(fileDateMatch.group(3)!);
  final date = DateTime(year, month, day);

  // Parse tags
  final tags = <String>[];
  final yamlTags = yaml['tags'];
  if (yamlTags is YamlList) {
    tags.addAll(yamlTags.map((e) => e.toString()));
  } else if (yamlTags is List) {
    tags.addAll(yamlTags.map((e) => e.toString()));
  }

  // Parse permalink
  var permalink = yaml['permalink']?.toString();
  if (permalink == null) {
    final year = fileDateMatch.group(1);
    final month = fileDateMatch.group(2);
    final titleSlug = fileDateMatch.group(4);
    permalink = '/$year/$month/$titleSlug.html';
  }

  if (!permalink.startsWith('/')) {
    permalink = '/$permalink';
  }

  final isHtml = filePath.endsWith('.html');

  var contentHtml = '';
  if (isHtml) {
    contentHtml = parsed.bodyMarkdown;
  } else {
    final cleanedBody = parsed.bodyMarkdown.replaceAll(
      _markdownCleanupRegExp,
      '',
    );
    contentHtml = md.markdownToHtml(
      cleanedBody,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      blockSyntaxes: const [md.AlertBlockSyntax()],
    );
  }

  final projectId = yaml['project']?.toString();

  return Post(
    permalink: permalink,
    title: title,
    subTitle: yaml['subtitle']?.toString(),
    date: date,
    tags: tags,
    contentHtml: contentHtml,
    isHtml: isHtml,
    uri: null,
    flavor: EntryFlavor.writing,
    projectId: projectId,
  );
}

String generateAtomFeed() {
  final writings = posts.where((p) => p.flavor == EntryFlavor.writing).toList();
  final lastPostDate = writings.isNotEmpty
      ? writings.first.date
      : DateTime.now();
  final updatedStr = _formatIso8601(lastPostDate);

  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0" encoding="utf-8"');
  builder.element(
    'feed',
    attributes: {'xmlns': 'http://www.w3.org/2005/Atom'},
    nest: () {
      builder.element(
        'generator',
        attributes: {'uri': 'https://pub.dev/packages/jaspr'},
        nest: 'Jaspr',
      );
      builder.element(
        'link',
        attributes: {
          'href': '$siteUrl/feed.xml',
          'rel': 'self',
          'type': 'application/atom+xml',
        },
      );
      builder.element(
        'link',
        attributes: {
          'href': '$siteUrl/',
          'rel': 'alternate',
          'type': 'text/html',
        },
      );
      builder.element('updated', nest: updatedStr);
      builder.element('id', nest: '$siteUrl/feed.xml');
      builder.element('title', attributes: {'type': 'html'}, nest: siteTitle);
      builder.element('subtitle', nest: siteSubtitle);

      for (final post in writings) {
        final postDateStr = _formatIso8601(post.date);
        final permalinkUrl = '$siteUrl${post.permalink}';

        builder.element(
          'entry',
          nest: () {
            builder.element(
              'title',
              attributes: {'type': 'html'},
              nest: post.title,
            );
            builder.element(
              'link',
              attributes: {
                'href': permalinkUrl,
                'rel': 'alternate',
                'type': 'text/html',
                'title': post.title,
              },
            );
            builder.element('published', nest: postDateStr);
            builder.element('updated', nest: postDateStr);
            builder.element('id', nest: permalinkUrl);
            builder.element(
              'content',
              attributes: {'type': 'html', 'xml:base': permalinkUrl},
              nest: post.contentHtml ?? '',
            );
            builder.element(
              'author',
              nest: () {
                builder.element('name', nest: authorName);
              },
            );
            for (final tag in post.tags) {
              builder.element('category', attributes: {'term': tag});
            }
          },
        );
      }
    },
  );

  return builder.buildDocument().toXmlString(pretty: true);
}

String generateSitemap() {
  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0" encoding="UTF-8"');
  builder.element(
    'urlset',
    attributes: {'xmlns': 'http://www.sitemaps.org/schemas/sitemap/0.9'},
    nest: () {
      builder.element(
        'url',
        nest: () {
          builder.element('loc', nest: '$siteUrl/');
          builder.element('changefreq', nest: 'weekly');
          builder.element('priority', nest: '1.0');
        },
      );
      builder.element(
        'url',
        nest: () {
          builder.element('loc', nest: '$siteUrl/about/');
          builder.element('changefreq', nest: 'monthly');
          builder.element('priority', nest: '0.8');
        },
      );

      final writings = posts
          .where((p) => p.flavor == EntryFlavor.writing)
          .toList();
      for (final post in writings) {
        final postDateStr = post.date.toIso8601String().substring(0, 10);
        builder.element(
          'url',
          nest: () {
            builder.element('loc', nest: '$siteUrl${post.permalink}');
            builder.element('lastmod', nest: postDateStr);
            builder.element('changefreq', nest: 'monthly');
            builder.element('priority', nest: '0.6');
          },
        );
      }
    },
  );

  return builder.buildDocument().toXmlString(pretty: true);
}

String _formatIso8601(DateTime date) => date.toUtc().toIso8601String();

String loadAboutContent() {
  try {
    final file = File('_pages/about.md');
    if (file.existsSync()) {
      return parseFrontmatterFile(file).bodyHtml;
    }
  } catch (e) {
    print('Error loading about.md: $e');
  }
  return '';
}
