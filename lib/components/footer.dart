import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../constants.dart';
import '../models/data_model.dart';

class Footer extends StatelessComponent {
  const Footer({super.key});

  @override
  Component build(BuildContext context) {
    final currentYear = DateTime.now().year;

    return footer(
      classes:
          'w-full border-t border-slate-100 dark:border-slate-800/80 '
          'bg-slate-50/30 dark:bg-slate-900/30 py-8 mt-16',
      [
        div(
          classes:
              'max-w-3xl mx-auto px-6 flex items-center justify-between '
              'text-xs text-slate-400 dark:text-slate-500',
          [
            p([Component.text('© $currentYear $authorName.')]),
            div(
              classes:
                  'flex items-center space-x-6 text-slate-400 '
                  'dark:text-slate-500',
              [
                for (final link in socialLinks)
                  a(
                    href: link.href,
                    target: Target.blank,
                    classes:
                        'hover:text-sky-500 dark:hover:text-sky-400 '
                        'transition-colors',
                    attributes: {'title': link.title, 'rel': 'me noopener'},
                    [
                      Component.element(
                        tag: 'i',
                        classes: '${link.iconClass} text-lg',
                        children: [],
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
