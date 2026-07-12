import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../constants.dart';

class Header extends StatelessComponent {
  final String activePath;

  const Header({this.activePath = '', super.key});

  @override
  Component build(BuildContext context) {
    Component buildNavItem(String href, String label, bool isActive) => a(
      href: href,
      classes: isActive
          ? 'text-sm font-extrabold text-blue-600 dark:text-blue-400 '
                'border-b-2 border-blue-600 dark:border-blue-400 pb-0.5 '
                'transition-all'
          : 'text-sm font-medium text-slate-500 dark:text-slate-400 '
                'hover:text-slate-900 dark:hover:text-white '
                'transition-colors',
      [Component.text(label)],
    );

    final isPosts =
        activePath == '/' ||
        activePath.startsWith('/20') ||
        activePath.startsWith('/feed');

    return header(
      classes:
          'sticky top-0 z-50 w-full border-b border-slate-100 '
          'dark:border-slate-800/80 bg-white/80 dark:bg-slate-950/80 '
          'backdrop-blur',
      [
        div(
          classes:
              'max-w-3xl mx-auto px-6 h-16 flex items-center justify-between',
          [
            // Logo / Title
            const a(
              href: '/',
              classes:
                  'text-lg font-black text-slate-950 dark:text-white '
                  'hover:text-blue-600 dark:hover:text-blue-400 '
                  'transition-colors',
              [Component.text(authorName)],
            ),
            // Navigation
            nav(classes: 'flex items-center space-x-6', [
              buildNavItem('/', 'Posts', isPosts),
              // buildNavItem('/projects', 'Projects', activePath == '/projects'),
              // buildNavItem('/about', 'About', activePath == '/about'),
            ]),
          ],
        ),
      ],
    );
  }
}
