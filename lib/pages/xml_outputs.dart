import 'package:jaspr/server.dart';

import '../content.dart' as content;

class FeedOutput extends StatelessComponent {
  const FeedOutput({super.key});

  @override
  Component build(BuildContext context) {
    context.setHeader('Content-Type', 'application/atom+xml; charset=utf-8');
    context.setStatusCode(200, responseBody: content.generateAtomFeed());
    return const Component.empty();
  }
}

class SitemapOutput extends StatelessComponent {
  const SitemapOutput({super.key});

  @override
  Component build(BuildContext context) {
    context.setHeader('Content-Type', 'application/xml; charset=utf-8');
    context.setStatusCode(200, responseBody: content.generateSitemap());
    return const Component.empty();
  }
}
