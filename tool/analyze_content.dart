import 'dart:io';
import 'package:work_j832_com/content.dart' as content;

void main() {
  final posts = content.posts;
  final writingPosts = posts
      .where((p) => p.flavor == content.EntryFlavor.writing)
      .toList();

  print('Total posts: ${posts.length}');
  print('Writing posts: ${writingPosts.length}');

  final tagCounts = <String, int>{};
  for (final post in writingPosts) {
    for (final tag in post.tags) {
      final n = content.normalizeTag(tag);
      tagCounts[n] = (tagCounts[n] ?? 0) + 1;
    }
  }

  final sortedTags = tagCounts.keys.toList()
    ..sort((a, b) => tagCounts[b]!.compareTo(tagCounts[a]!));

  print('\nTag frequency (Writing only, Normalized):');
  for (final tag in sortedTags) {
    print('  ${tag.padRight(20)}: ${tagCounts[tag]}');
  }

  print(
    '\nChecking posts for embedded JavaScript / script tags / inline handlers...',
  );
  var issueCount = 0;
  final scriptTagRegExp = RegExp(r'<script\b', caseSensitive: false);
  final inlineHandlerRegExp = RegExp(
    r'\bon[a-zA-Z]+\s*=',
    caseSensitive: false,
  );

  final postsDir = Directory('_posts');
  if (postsDir.existsSync()) {
    for (final file in postsDir.listSync().whereType<File>()) {
      if (!file.path.endsWith('.md') && !file.path.endsWith('.html')) continue;
      final rawContent = file.readAsStringSync();
      // Split by frontmatter delimiter to only search the body
      final parts = rawContent.split('---');
      final body = parts.length > 2 ? parts.sublist(2).join('---') : rawContent;

      if (scriptTagRegExp.hasMatch(body)) {
        print('  [FAIL] ${file.path}: Found script tag in body');
        issueCount++;
      }
      if (inlineHandlerRegExp.hasMatch(body)) {
        print('  [FAIL] ${file.path}: Found inline event handler in body');
        issueCount++;
      }
    }
  }
  if (issueCount == 0) {
    print('  [PASS] No embedded JS issues found!');
  } else {
    print('  [FAIL] Found $issueCount embedded JS issues!');
  }
}
