import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../components/header.dart';
import '../components/interactive_post_list.dart';
import '../constants.dart';
import '../content.dart' as content;
import '../models/client_post_item.dart';

class Home extends StatelessComponent {
  const Home({super.key});

  @override
  Component build(BuildContext context) {
    final posts = content.posts;

    final clientPosts = posts.map((post) {
      final isWriting = post.flavor == content.EntryFlavor.writing;
      return ClientPostItem(
        permalink: post.permalink,
        title: post.title,
        subTitle: post.subTitle ?? '',
        dateString: _formatDate(post.date),
        year: post.date.year,
        tags: post.tags.map(content.normalizeTag).toList(),
        awesomeHtml: post.flavor.awesome,
        isWriting: isWriting,
        linkUrl: isWriting ? post.permalink : (post.uri ?? ''),
        flavor: post.flavor,
      );
    }).toList();

    return Component.fragment([
      const Document.head(
        children: [link(href: '$siteUrl/', rel: 'canonical')],
      ),
      div(
        classes:
            'bg-white dark:bg-slate-950 text-slate-700 dark:text-slate-200 '
            'min-h-screen w-full flex flex-col items-center font-sans',
        [
          const Header(activePath: '/'),
          div(classes: 'w-full max-w-3xl flex flex-col flex-1 py-10 px-4', [
            // Header Block (Ported from kevmoo.com)
            Component.element(
              tag: 'header',
              classes: 'text-center mb-0',
              children: [
                const p(
                  classes:
                      'text-xl sm:text-2xl text-slate-800 dark:text-slate-200 '
                      'font-medium tracking-tight mb-6 leading-relaxed',
                  [
                    a(
                      href: 'https://www.google.com/',
                      target: Target.blank,
                      attributes: {'rel': 'noopener'},
                      classes:
                          'text-blue-600 dark:text-blue-400 hover:underline '
                          'font-semibold',
                      [Component.text('Google')],
                    ),
                    Component.text(' product manager for '),
                    a(
                      href: 'https://flutter.dev',
                      target: Target.blank,
                      attributes: {'rel': 'noopener'},
                      classes:
                          'text-blue-600 dark:text-blue-400 hover:underline '
                          'font-semibold',
                      [Component.text('Flutter')],
                    ),
                    Component.text(' and '),
                    a(
                      href: 'https://dart.dev',
                      target: Target.blank,
                      attributes: {'rel': 'noopener'},
                      classes:
                          'text-blue-600 dark:text-blue-400 hover:underline '
                          'font-semibold',
                      [Component.text('Dart')],
                    ),
                    Component.text('.'),
                  ],
                ),
                // Social profile animated strips
                div(
                  classes:
                      'profiles flex justify-center gap-6 text-slate-400 '
                      'dark:text-slate-500',
                  [
                    for (final link in content.socialLinks)
                      _buildSocialLink(
                        link.href,
                        link.title,
                        '${link.iconClass} text-xl',
                      ),
                  ],
                ),
              ],
            ),

            InteractivePostList(posts: clientPosts),

            // Footer
            const div(classes: 'mt-16 text-center text-sm opacity-60', [
              Component.text('Source: '),
              a(
                href: 'https://github.com/kevmoo/kevmoo.com/',
                target: Target.blank,
                attributes: {'rel': 'noopener'},
                [Component.text('github.com/kevmoo/kevmoo.com')],
              ),
            ]),
          ]),
        ],
      ),
    ]);
  }

  Component _buildSocialLink(String href, String title, String iconClass) => a(
    href: href,
    target: Target.blank,
    attributes: {'title': title, 'rel': 'me noopener'},
    [Component.element(tag: 'i', classes: iconClass, children: [])],
  );
}

String _formatDate(DateTime date) {
  final year = date.year;
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year‑$month‑$day'; // Using non-breaking hyphens matching original
}
