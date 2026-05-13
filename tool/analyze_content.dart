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
}
