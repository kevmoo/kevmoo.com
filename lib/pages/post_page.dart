import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/footer.dart';
import '../components/header.dart';
import '../constants.dart';
import '../content.dart' as content;
import '../projects_content.dart' as projects_content;

class PostPage extends StatelessComponent {
  final String permalink;

  const PostPage({required this.permalink, super.key});

  @override
  Component build(BuildContext context) {
    // Search for post by permalink
    final post = content.posts
        .where((entry) => entry.permalink == permalink)
        .firstOrNull;

    // 404 fallback
    if (post == null) {
      return const div(classes: 'max-w-3xl mx-auto px-6 py-24 text-center', [
        h1(classes: 'text-5xl font-black text-slate-900 dark:text-white mb-6', [
          Component.text('404'),
        ]),
        p(classes: 'text-lg text-slate-600 dark:text-slate-400 mb-8', [
          Component.text(
            'Oops! We couldn\'t find the article you were looking for.',
          ),
        ]),
        a(
          href: '/',
          classes:
              'inline-flex items-center px-6 py-3 rounded-lg bg-blue-600 '
              'hover:bg-blue-700 text-white font-semibold text-sm shadow-sm '
              'transition-colors',
          [Component.text('Back to Home')],
        ),
      ]);
    }

    final dateString = _formatDate(post.date);
    final hasSubtitle = post.subTitle != null && post.subTitle!.isNotEmpty;
    final project = post.projectId == null
        ? null
        : projects_content.projects
              .where((proj) => proj.id == post.projectId)
              .firstOrNull;

    return Component.fragment([
      Document.head(
        children: [link(href: '$siteUrl${post.permalink}', rel: 'canonical')],
      ),
      div(
        classes:
            'bg-white dark:bg-slate-950 text-slate-700 dark:text-slate-200 '
            'flex-1 flex flex-col',
        [
          Header(activePath: permalink),
          div(classes: 'max-w-2xl w-full mx-auto px-6 py-16 flex-1', [
            // Back link
            const a(
              href: '/',
              classes:
                  'inline-flex items-center space-x-2 text-xs font-bold '
                  'text-slate-400 hover:text-slate-900 mb-12 transition-colors '
                  'group',
              [
                span(
                  classes: 'group-hover:-translate-x-0.5 transition-transform',
                  [Component.text('←')],
                ),
                Component.text('Back to posts'),
              ],
            ),

            // Article Header
            header(classes: 'mb-12', [
              Component.element(
                tag: 'time',
                classes:
                    'text-xs font-semibold text-blue-600 uppercase '
                    'tracking-wider mb-3 block',
                children: [Component.text(dateString)],
              ),
              h1(
                classes:
                    'text-3xl md:text-4xl font-black tracking-tight '
                    'text-slate-950 leading-tight '
                    '${hasSubtitle ? 'mb-3' : 'mb-6'}',
                [Component.text(post.title)],
              ),
              if (post.subTitle != null && post.subTitle!.isNotEmpty)
                p(
                  classes:
                      'text-lg md:text-xl text-slate-500 dark:text-slate-400 '
                      'font-medium leading-relaxed mb-6 italic',
                  [Component.text(post.subTitle!)],
                ),
              if (post.tags.isNotEmpty || project != null)
                div(classes: 'flex items-center space-x-2 flex-wrap gap-y-2', [
                  if (project != null)
                    span(
                      classes:
                          'text-xs font-semibold text-blue-600 '
                          'dark:text-blue-400 px-2.5 py-0.5 '
                          'border border-blue-200 '
                          'dark:border-blue-900 rounded-md '
                          'bg-blue-50/50 dark:bg-blue-950/20',
                      [
                        a(
                          href: '/projects#${project.id}',
                          classes: 'hover:underline',
                          [Component.text('Project: ${project.name}')],
                        ),
                      ],
                    ),
                  ...post.tags.map(
                    (tag) => span(
                      classes:
                          'text-xs font-semibold text-slate-400 '
                          'px-2.5 py-0.5 border border-slate-200 '
                          'rounded-md',
                      [Component.text(tag)],
                    ),
                  ),
                ]),
            ]),

            // Article Body (Beautiful Prose)
            article(classes: 'prose dark:prose-invert', [
              RawText(post.contentHtml ?? ''),
            ]),
          ]),
          const Footer(),
        ],
      ),
    ]);
  }
}

String _formatDate(DateTime date) =>
    '${_months[date.month - 1]} ${date.day}, ${date.year}';

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
