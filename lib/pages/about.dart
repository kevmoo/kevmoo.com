import 'dart:io';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:markdown/markdown.dart' as md;

import '../components/footer.dart';
import '../components/header.dart';
import '../constants.dart';

class About extends StatelessComponent {
  const About({super.key});

  @override
  Component build(BuildContext context) {
    // Load and render about.md dynamically at build time
    var pageTitle = 'About';
    var pageContentHtml = '';

    try {
      final file = File('_pages/about.md');
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        if (content.startsWith('---')) {
          final parts = content.split('---');
          if (parts.length >= 3) {
            final body = parts.sublist(2).join('---').trim();
            pageContentHtml = md.markdownToHtml(
              body,
              extensionSet: md.ExtensionSet.gitHubFlavored,
            );
          }
        } else {
          pageContentHtml = md.markdownToHtml(
            content,
            extensionSet: md.ExtensionSet.gitHubFlavored,
          );
        }
      }
    } catch (e) {
      print('Error loading about.md: $e');
    }

    if (pageContentHtml.isEmpty) {
      pageContentHtml =
          '<p>See <a href="https://j832.com">j832.com</a> – '
          'which just points back here.</p>';
    }

    return Component.fragment([
      const Document.head(
        children: [link(href: '$siteUrl/about/', rel: 'canonical')],
      ),
      div(classes: 'bg-white text-slate-700 flex-1 flex flex-col', [
        const Header(),
        div(classes: 'max-w-2xl w-full mx-auto px-6 py-16 flex-1', [
          h1(
            classes:
                'text-3xl font-black tracking-tight text-slate-950 '
                'mb-8',
            [Component.text(pageTitle)],
          ),
          article(classes: 'prose', [RawText(pageContentHtml)]),
        ]),
        const Footer(),
      ]),
    ]);
  }
}
