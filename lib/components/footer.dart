import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class Footer extends StatelessComponent {
  const Footer({super.key});

  @override
  Component build(BuildContext context) {
    final currentYear = DateTime.now().year;

    return footer(
      classes: 'w-full border-t border-slate-100 bg-slate-50/30 py-8 mt-16',
      [
        div(
          classes:
              'max-w-3xl mx-auto px-6 flex items-center justify-between '
              'text-xs text-slate-400',
          [
            p([Component.text('© $currentYear Kevin Moore.')]),
            const div(classes: 'flex space-x-6 font-medium', [
              a(
                href: '/feed.xml',
                classes: 'hover:text-orange-500 transition-colors',
                [Component.text('RSS')],
              ),
              a(
                href: 'https://github.com/kevmoo',
                target: Target.blank,
                classes: 'hover:text-slate-900 transition-colors',
                [Component.text('GitHub')],
              ),
            ]),
          ],
        ),
      ],
    );
  }
}
