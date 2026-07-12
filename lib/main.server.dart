import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'app.dart';
import 'constants.dart';
import 'content.dart' as content;
import 'main.server.options.dart';
import 'projects_content.dart' as projects_content;

void main() {
  Jaspr.initializeApp(
    options: defaultServerOptions,
    allowedPathSuffixes: ['html', 'htm', 'xml', 'css'],
  );

  runApp(
    Document(
      title: homePageTitle,
      meta: const {
        'description':
            'Googler working on Dart and Flutter web technology. '
            'Thoughts, notes, and bag of tricks.',
        'viewport': 'width=device-width, initial-scale=1.0',
      },
      head: const [
        // Google Analytics (gtag.js)
        Component.element(
          tag: 'script',
          attributes: {
            'async': '',
            'src': 'https://www.googletagmanager.com/gtag/js?id=UA-3441863-3',
          },
          children: [],
        ),
        Component.element(
          tag: 'script',
          attributes: {'nonce': 'okoboji'},
          children: [
            RawText('''
              window.dataLayer = window.dataLayer || [];
              function gtag(){dataLayer.push(arguments);}
              gtag('js', new Date());
              gtag('config', 'UA-3441863-3');'''),
          ],
        ),
        // Auto-discovery SEO links for Sitemap and RSS/Atom feed
        Component.element(
          tag: 'link',
          attributes: {
            'rel': 'alternate',
            'type': 'application/atom+xml',
            'href': '/feed.xml',
            'title': siteTitle,
          },
          children: [],
        ),
        Component.element(
          tag: 'link',
          attributes: {
            'rel': 'sitemap',
            'type': 'application/xml',
            'href': '/sitemap.xml',
            'title': 'Sitemap',
          },
          children: [],
        ),
        // Stylesheets loaded as standard link tags to comply with strict CSP
        Component.element(
          tag: 'link',
          attributes: {
            'rel': 'stylesheet',
            'href':
                'https://fonts.googleapis.com/css2?'
                'family=Inter:wght@300;400;500;600;700;800;900'
                '&family=Roboto+Slab:wght@300;400;600&display=swap',
          },
          children: [],
        ),
        Component.element(
          tag: 'link',
          attributes: {
            'rel': 'stylesheet',
            'href':
                'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/'
                '7.0.1/css/all.min.css',
          },
          children: [],
        ),
        Component.element(
          tag: 'link',
          attributes: {'rel': 'stylesheet', 'href': '/styles.css'},
          children: [],
        ),
      ],
      styles: const [],
      body: App(
        posts: content.posts,
        projects: projects_content.projects,
        aboutContentHtml: content.loadAboutContent(),
      ),
    ),
  );
}
