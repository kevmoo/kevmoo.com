import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

import 'app.dart';
import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(
    Document(
      title: 'kevmoo @ Work',
      meta: {
        'description':
            'Googler working on Dart and Flutter web technology. '
            'Thoughts, notes, and bag of tricks.',
        'viewport': 'width=device-width, initial-scale=1.0',
      },
      head: [
        // Google Analytics (gtag.js)
        const Component.element(
          tag: 'script',
          attributes: {
            'async': '',
            'src': 'https://www.googletagmanager.com/gtag/js?id=UA-3441863-3',
          },
          children: [],
        ),
        const Component.element(
          tag: 'script',
          children: [
            RawText('''
              window.dataLayer = window.dataLayer || [];
              function gtag(){dataLayer.push(arguments);}
              gtag('js', new Date());
              gtag('config', 'UA-3441863-3');'''),
          ],
        ),
      ],
      styles: [
        css.import(
          'https://fonts.googleapis.com/css2?'
          'family=Inter:wght@300;400;500;600;700;800;900&display=swap',
        ),
        // Include local Tailwind stylesheet
        css.import('/styles.css'),
      ],
      body: const App(),
    ),
  );
}
