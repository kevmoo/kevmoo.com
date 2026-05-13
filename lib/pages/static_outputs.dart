import 'dart:io';
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

String? _cachedCss;
DateTime? _lastModified;

class StylesOutput extends AsyncStatelessComponent {
  const StylesOutput({super.key});

  @override
  Future<Component> build(BuildContext context) async {
    final inputFile = File('styles.tw.css');
    final currentModified = inputFile.existsSync()
        ? inputFile.lastModifiedSync()
        : null;

    if (_cachedCss == null || _lastModified != currentModified) {
      final result = await Process.run('npx', [
        '@tailwindcss/cli',
        '--input',
        'styles.tw.css',
        '--minify',
      ]);
      if (result.exitCode != 0) {
        throw Exception('Tailwind compilation failed:\n${result.stderr}');
      }
      _cachedCss = result.stdout as String;
      _lastModified = currentModified;
    }

    context.setHeader('Content-Type', 'text/css; charset=utf-8');
    context.setStatusCode(200, responseBody: _cachedCss);
    return const Component.empty();
  }
}
