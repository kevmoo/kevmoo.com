import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/footer.dart';
import '../components/header.dart';
import '../constants.dart';

class About extends StatelessComponent {
  final String contentHtml;

  const About({required this.contentHtml, super.key});

  @override
  Component build(BuildContext context) {
    const pageTitle = 'About';
    var pageContentHtml = contentHtml;

    if (pageContentHtml.isEmpty) {
      pageContentHtml =
          '<p>See <a href="https://j832.com">j832.com</a> – '
          'which just points back here.</p>';
    }

    return Component.fragment([
      const Document.head(
        children: [link(href: '$siteUrl/about/', rel: 'canonical')],
      ),
      div(
        classes:
            'bg-white dark:bg-slate-950 text-slate-700 dark:text-slate-200 '
            'flex-1 flex flex-col min-h-screen',
        [
          const Header(activePath: '/about'),
          div(classes: 'max-w-2xl w-full mx-auto px-6 py-16 flex-1', [
            const h1(
              classes:
                  'text-3xl font-black tracking-tight text-slate-950 '
                  'dark:text-white mb-8',
              [Component.text(pageTitle)],
            ),
            article(classes: 'prose dark:prose-invert', [
              RawText(pageContentHtml),
            ]),
          ]),
          const Footer(),
        ],
      ),
    ]);
  }
}
