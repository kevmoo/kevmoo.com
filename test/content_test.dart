import 'package:checks/checks.dart';
import 'package:test/test.dart';
import 'package:work_j832_com/content.dart';

void main() {
  group('Content System Tests', () {
    test('Verify total posts and appearances loaded', () {
      // We should have the 127 original posts plus the 27 new appearances
      check(posts).isNotEmpty();
      check(posts.length).isGreaterThan(150);
    });

    test('Verify YAML appearances are parsed correctly', () {
      // Filter all parsed YAML appearance entries
      final appearances = posts
          .where((p) => p.flavor != EntryFlavor.writing)
          .toList();

      check(appearances).isNotEmpty();

      // Verify that every appearance has no markdown body and has a URI/flavor
      for (final appearance in appearances) {
        check(appearance.contentHtml).isNull();
        check(appearance.uri).isNotNull();
        check(appearance.flavor).not((it) => it.equals(EntryFlavor.writing));
      }

      // Check a specific known appearance
      final unifiedTechStack = posts.firstWhere(
        (p) => p.title == 'Unify your tech stack with Dart',
      );

      check(unifiedTechStack.subTitle).equals('Google Cloud Next 2026');
      check(
        unifiedTechStack.uri,
      ).equals('https://www.youtube.com/watch?v=XOU5dZJvHXk');
      check(unifiedTechStack.flavor).equals(EntryFlavor.youtube);
      check(unifiedTechStack.date.year).equals(2026);
      check(unifiedTechStack.date.month).equals(4);
      check(unifiedTechStack.date.day).equals(24);

      // Check the new link appearances
      final firebaseAnnounce = posts.firstWhere(
        (p) =>
            p.title ==
            'Announcing Dart support in Cloud Functions for Firebase',
      );
      check(firebaseAnnounce.subTitle).equals('Firebase Blog');
      check(
        firebaseAnnounce.uri,
      ).equals('https://firebase.blog/posts/2026/05/dart-functions-exp');
      check(firebaseAnnounce.flavor).equals(EntryFlavor.link);
      check(firebaseAnnounce.date.year).equals(2026);
      check(firebaseAnnounce.date.month).equals(5);
      check(firebaseAnnounce.date.day).equals(6);

      final dartBlogMissingLink = posts.firstWhere(
        (p) =>
            p.title ==
            'The Flutter missing link: Why full-stack Dart changes everything',
      );
      check(dartBlogMissingLink.subTitle).equals('The Dart Blog');
      check(dartBlogMissingLink.uri).equals(
        'https://dart.dev/blog/flutter-missing-link-why-full-stack-dart-changes-everything',
      );
      check(dartBlogMissingLink.flavor).equals(EntryFlavor.link);
      check(dartBlogMissingLink.date.year).equals(2026);
      check(dartBlogMissingLink.date.month).equals(5);
      check(dartBlogMissingLink.date.day).equals(18);
    });

    test('Verify blog posts parse correctly as writings', () {
      final writings = posts
          .where((p) => p.flavor == EntryFlavor.writing)
          .toList();

      check(writings).isNotEmpty();

      for (final post in writings) {
        check(post.contentHtml).isNotNull();
        check(post.permalink).isNotEmpty();
        check(post.permalink.startsWith('/')).isTrue();
      }

      // Check a specific known post (e.g. migrating-to-jaspr)
      final migrationPost = posts.firstWhere(
        (p) => p.title == 'Migrating to Jaspr',
      );

      check(migrationPost.flavor).equals(EntryFlavor.writing);
      check(migrationPost.permalink).equals('/2026/05/migrating-to-jaspr.html');
      check(
        migrationPost.contentHtml,
      ).isNotNull().contains('migrated the entire blog to Dart and');

      // Verify that project metadata is parsed
      final gitAliasPost = posts.firstWhere(
        (p) => p.title == 'Git aliases are awesome, even locally',
      );
      check(gitAliasPost.projectId).equals('personal_dotfiles');
    });

    test('generateAtomFeed filters out appearances', () {
      final feedXml = generateAtomFeed();

      // Verify the feed generated correctly
      check(feedXml).isNotEmpty();
      check(feedXml).contains('<feed xmlns="http://www.w3.org/2005/Atom">');

      // The feed should contain actual blog posts (writings)
      check(feedXml).contains('Migrating to Jaspr');

      // The feed must NOT contain any appearance external URIs or titles
      check(
        feedXml,
      ).not((it) => it.contains('Unify your tech stack with Dart'));
      check(
        feedXml,
      ).not((it) => it.contains('https://www.youtube.com/watch?v=XOU5dZJvHXk'));
    });

    test('generateSitemap filters out appearances', () {
      final sitemapXml = generateSitemap();

      check(sitemapXml).isNotEmpty();
      check(sitemapXml).contains(
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
      );

      // Sitemap should have sitemaps structure and about page
      check(sitemapXml).contains('/about/');
      check(sitemapXml).contains('/2026/05/migrating-to-jaspr.html');

      // Sitemap must NOT have any entry without a permalink
      check(sitemapXml).not(
        (it) => it.contains(
          '<loc>http://localhost:8080/</loc>',
        ), // Home page is fine, but no empty locs
      );
      check(
        sitemapXml,
      ).not((it) => it.contains('https://www.youtube.com/watch?v=XOU5dZJvHXk'));
    });
  });
}
