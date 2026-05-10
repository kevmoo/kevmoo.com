import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class Header extends StatelessComponent {
  const Header({super.key});

  @override
  Component build(BuildContext context) {
    return const header(
      classes:
          'sticky top-0 z-50 w-full border-b border-slate-100 '
          'bg-white/80 backdrop-blur',
      [
        div(
          classes:
              'max-w-3xl mx-auto px-6 h-16 flex items-center '
              'justify-between',
          [
            // Logo / Title
            a(
              href: '/',
              classes:
                  'text-lg font-black text-slate-950 hover:text-blue-600 '
                  'transition-colors',
              [Component.text('kevmoo @ Work')],
            ),
            // Navigation
            nav(classes: 'flex items-center space-x-6', [
              a(href: '/', classes: 'text-sm font-semibold text-slate-900', [
                Component.text('Posts'),
              ]),
              a(
                href: '/about',
                classes:
                    'text-sm font-medium text-slate-500 '
                    'hover:text-slate-900 transition-colors',
                [Component.text('About')],
              ),
            ]),
          ],
        ),
      ],
    );
  }
}
