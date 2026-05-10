import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../content.dart' as content;

class Home extends StatelessComponent {
  const Home({super.key});

  @override
  Component build(BuildContext context) {
    final posts = content.posts;

    return div(classes: 'max-w-2xl mx-auto px-6 py-16', [
      // Blog Introduction / Hero
      const div(classes: 'mb-16 text-center md:text-left', [
        h1(
          classes:
              'text-4xl md:text-5xl font-black tracking-tight '
              'text-slate-950 mb-4',
          [Component.text('kevmoo @ Work')],
        ),
        p(classes: 'text-base text-slate-500 max-w-xl leading-relaxed', [
          Component.text(
            'Googler working on Dart and Flutter web technology. '
            'Thoughts, notes, and bag of tricks.',
          ),
        ]),
      ]),

      // Posts Header
      div(
        classes:
            'border-b border-slate-100 pb-4 mb-8 flex items-center '
            'justify-between',
        [
          const h2(classes: 'text-lg font-extrabold text-slate-900', [
            Component.text('Latest Articles'),
          ]),
          span(
            classes:
                'text-[11px] font-bold text-blue-600 px-2.5 py-1 '
                'bg-blue-50 border border-blue-100/50 rounded-full '
                'tracking-wider uppercase',
            [Component.text('${posts.length} Posts')],
          ),
        ],
      ),

      // Post List
      ul(
        classes: 'divide-y divide-slate-100',
        posts.map((post) {
          final dateString = _formatDate(post.date);

          return li(
            classes:
                'py-8 first:pt-0 last:pb-0 group transition-all '
                'duration-200',
            [
              // Card container
              div(classes: 'flex flex-col items-start', [
                // Date above title
                Component.element(
                  tag: 'time',
                  classes:
                      'text-xs font-semibold text-slate-400 '
                      'uppercase tracking-wider mb-2 block',
                  children: [Component.text(dateString)],
                ),
                // Title
                a(href: post.permalink, classes: 'block w-full', [
                  h3(
                    classes:
                        'text-xl font-black text-slate-900 '
                        'group-hover:text-blue-600 leading-snug mb-3 '
                        'transition-colors duration-200',
                    [Component.text(post.title)],
                  ),
                ]),
                // Tags as modern pills
                if (post.tags.isNotEmpty)
                  div(
                    classes: 'flex flex-wrap gap-1.5 mt-1',
                    post.tags.map((tag) {
                      return span(
                        classes:
                            'text-[11px] font-semibold text-slate-500 '
                            'px-2.5 py-0.5 bg-slate-100/70 border '
                            'border-slate-200/40 rounded-md transition-all '
                            'duration-150 hover:bg-blue-50 '
                            'hover:text-blue-600 cursor-pointer',
                        [Component.text(tag)],
                      );
                    }).toList(),
                  ),
              ]),
            ],
          );
        }).toList(),
      ),
    ]);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
