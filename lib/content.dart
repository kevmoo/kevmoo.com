import 'dart:io';
import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';
import 'package:yaml/yaml.dart';
import 'constants.dart';

class Post {
  final String permalink;
  final String title;
  final DateTime date;
  final List<String> tags;
  final String contentHtml;
  final bool isHtml;

  Post({
    required this.permalink,
    required this.title,
    required this.date,
    required this.tags,
    required this.contentHtml,
    required this.isHtml,
  });
}

final List<Post> posts = _loadPosts();

List<Post> _loadPosts() {
  final postsList = <Post>[];
  final dir = Directory('_posts');
  if (!dir.existsSync()) {
    print('WARNING: _posts directory not found.');
    return [];
  }

  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.md') || f.path.endsWith('.html'))
      .toList();

  for (final file in files) {
    try {
      final filename = p.basename(file.path);
      final content = file.readAsStringSync();

      // Parse Jekyll frontmatter
      if (!content.startsWith('---')) {
        continue;
      }

      final parts = content.split('---');
      if (parts.length < 3) {
        continue;
      }

      final frontmatterString = parts[1];
      final bodyContent = parts.sublist(2).join('---').trim();

      final yaml = loadYaml(frontmatterString) as YamlMap;
      final title = yaml['title']?.toString() ?? 'Untitled';

      // Parse date
      DateTime? date;
      final yamlDate = yaml['date'];
      if (yamlDate is DateTime) {
        date = yamlDate;
      } else if (yamlDate != null) {
        date = DateTime.tryParse(yamlDate.toString());
      }

      // Extract date from filename if frontmatter date is missing or invalid
      // Jekyll filename format: YYYY-MM-DD-title.ext
      final fileDateMatch = RegExp(
        r'^(\d{4})-(\d{2})-(\d{2})-(.+)\.(md|html)$',
      ).firstMatch(filename);

      if (date == null && fileDateMatch != null) {
        final year = int.parse(fileDateMatch.group(1)!);
        final month = int.parse(fileDateMatch.group(2)!);
        final day = int.parse(fileDateMatch.group(3)!);
        date = DateTime(year, month, day);
      }
      date ??= DateTime.now();

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
      if (permalink == null && fileDateMatch != null) {
        final year = fileDateMatch.group(1);
        final month = fileDateMatch.group(2);
        final titleSlug = fileDateMatch.group(4);
        permalink = '/$year/$month/$titleSlug.html';
      }
      final monthStr = date.month.toString().padLeft(2, '0');
      final fileSlug = p.basenameWithoutExtension(filename);
      permalink ??= '/${date.year}/$monthStr/$fileSlug.html';

      // Ensure permalink starts with a slash and has no trailing slash
      if (!permalink.startsWith('/')) {
        permalink = '/$permalink';
      }

      final isHtml = file.path.endsWith('.html');

      // Compile body markdown to HTML if needed
      var contentHtml = '';
      if (isHtml) {
        contentHtml = bodyContent;
      } else {
        // Clean up kramdown attributes like {: width='650' ... }
        // to prevent rendering issues in the standard markdown library
        final cleanedBody = bodyContent.replaceAll(
          RegExp(r'\{:\s*[^}]*\}'),
          '',
        );
        contentHtml = md.markdownToHtml(
          cleanedBody,
          extensionSet: md.ExtensionSet.gitHubFlavored,
        );
      }

      postsList.add(
        Post(
          permalink: permalink,
          title: title,
          date: date,
          tags: tags,
          contentHtml: contentHtml,
          isHtml: isHtml,
        ),
      );
    } catch (e, stack) {
      print('Error parsing file ${file.path}: $e\n$stack');
    }
  }

  // Sort posts chronologically descending
  postsList.sort((a, b) => b.date.compareTo(a.date));
  return postsList;
}

String generateAtomFeed() {
  final lastPostDate = posts.isNotEmpty ? posts.first.date : DateTime.now();
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

      for (final post in posts) {
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
              nest: post.contentHtml,
            );
            builder.element(
              'author',
              nest: () {
                builder.element('name', nest: 'Kevin Moore');
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
      // Home page
      builder.element(
        'url',
        nest: () {
          builder.element('loc', nest: '$siteUrl/');
          builder.element('changefreq', nest: 'weekly');
          builder.element('priority', nest: '1.0');
        },
      );
      // About page
      builder.element(
        'url',
        nest: () {
          builder.element('loc', nest: '$siteUrl/about/');
          builder.element('changefreq', nest: 'monthly');
          builder.element('priority', nest: '0.8');
        },
      );

      for (final post in posts) {
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
