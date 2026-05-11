import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../constants.dart';
import '../content.dart' as content;

class Home extends StatelessComponent {
  const Home({super.key});

  @override
  Component build(BuildContext context) {
    final posts = content.posts;

    return Component.fragment([
      const Document.head(
        children: [link(href: '$siteUrl/', rel: 'canonical')],
      ),
      div(
        classes:
            'glass-theme min-h-screen w-full flex flex-col items-center '
            'py-16 px-4',
        [
          div(classes: 'w-full max-w-3xl', [
            // Header Block (Ported from kevmoo.com)
            Component.element(
              tag: 'header',
              classes: 'text-center mb-12',
              children: [
                const h1(
                  classes: 'text-5xl font-extrabold mb-4 tracking-tight',
                  [Component.text('Kevin Moore')],
                ),
                const p(classes: 'description text-lg', [
                  a(
                    href: 'https://www.google.com/',
                    target: Target.blank,
                    attributes: {'rel': 'noopener'},
                    [Component.text('Google')],
                  ),
                  Component.text(' product manager for '),
                  a(
                    href: 'https://flutter.dev',
                    target: Target.blank,
                    attributes: {'rel': 'noopener'},
                    [Component.text('Flutter')],
                  ),
                  Component.text(' and '),
                  a(
                    href: 'https://dart.dev',
                    target: Target.blank,
                    attributes: {'rel': 'noopener'},
                    [Component.text('Dart')],
                  ),
                  Component.text('.'),
                ]),
                // Social profile animated strips
                div(classes: 'profiles', [
                  _buildSocialLink(
                    'https://bsky.app/profile/kevmoo.com',
                    'Bluesky @kevmoo.com',
                    'fab fa-bluesky fa-2x',
                  ),
                  _buildSocialLink(
                    'https://github.com/kevmoo/',
                    'GitHub/kevmoo',
                    'fab fa-github fa-2x',
                  ),
                  _buildSocialLink(
                    'https://mastodon.social/@kevmoo',
                    'mastodon.social/@kevmoo',
                    'fab fa-mastodon fa-2x',
                  ),
                  _buildSocialLink(
                    'https://www.linkedin.com/in/kevmoo/',
                    'LinkedIn/kevmoo',
                    'fab fa-linkedin fa-2x',
                  ),
                  _buildSocialLink(
                    'https://www.reddit.com/user/kevmoo',
                    'Reddit/kevmoo',
                    'fab fa-reddit fa-2x',
                  ),
                  _buildSocialLink(
                    'https://g.dev/kevmoo',
                    'Google Developers',
                    'fab fa-google fa-2x',
                  ),
                  _buildSocialLink(
                    'https://twitter.com/kevmoo',
                    'Twitter @kevmoo',
                    'fab fa-twitter fa-2x',
                  ),
                ]),
              ],
            ),

            // Appearances & Post list
            Component.element(
              tag: 'main',
              classes: 'flex flex-col gap-4',
              attributes: {'id': 'appearance-list'},
              children: [
                ...() {
                  final list = <Component>[];
                  for (var i = 0; i < posts.length; i++) {
                    final post = posts[i];
                    final postYear = post.date.year;

                    if (i > 0) {
                      final prevYear = posts[i - 1].date.year;
                      if (postYear < prevYear) {
                        final isHidden = i >= 10;
                        final markerClasses =
                            'year-marker flex items-center gap-4 pt-10 pb-4 '
                            '${isHidden ? 'hidden-card' : ''}';
                        list.add(
                          div(classes: markerClasses, [
                            span(
                              classes:
                                  'text-sky-400/90 font-black tracking-widest text-lg',
                              [Component.text('$postYear')],
                            ),
                            const div(
                              classes:
                                  'flex-grow h-[1px] bg-gradient-to-r '
                                  'from-sky-500/30 via-sky-500/10 to-transparent',
                              [],
                            ),
                          ]),
                        );
                      }
                    }

                    final isWriting =
                        post.flavor == content.EntryFlavor.writing;
                    final linkUrl = isWriting
                        ? post.permalink
                        : (post.uri ?? '');
                    final isHidden = i >= 10;
                    final cardClasses =
                        'glass-card appearance-card '
                        '${isHidden ? 'hidden-card' : ''}';

                    list.add(
                      div(classes: cardClasses, [
                        div(classes: 'icon', [RawText(post.flavor.awesome)]),
                        div(classes: 'details', [
                          div(classes: 'title', [
                            a(
                              href: linkUrl,
                              target: isWriting ? null : Target.blank,
                              attributes: isWriting ? {} : {'rel': 'noopener'},
                              [
                                Component.text(post.title.trim()),
                                if (!isWriting) ...[
                                  const RawText('&nbsp;'),
                                  const Component.element(
                                    tag: 'i',
                                    classes:
                                        'fa fa-external-link-alt text-sm '
                                        'opacity-50',
                                    children: [],
                                  ),
                                ],
                              ],
                            ),
                          ]),
                          if (post.subTitle != null &&
                              post.subTitle!.isNotEmpty)
                            div(classes: 'subtitle', [
                              Component.text(post.subTitle!),
                            ]),
                        ]),
                        div(classes: 'date', [
                          Component.text(_formatDate(post.date)),
                        ]),
                      ]),
                    );
                  }
                  return list;
                }(),
              ],
            ),

            // Progressive "Show More" Button
            if (posts.length > 10)
              const Component.fragment([
                div(classes: 'mt-12 text-center', [
                  button(
                    classes: 'glass-show-more-btn',
                    attributes: {'id': 'show-more-btn'},
                    [Component.text('Show More')],
                  ),
                ]),
                Component.element(
                  tag: 'script',
                  attributes: {'nonce': 'okoboji'},
                  children: [_buttonScript],
                ),
              ]),

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

  Component _buildSocialLink(String href, String title, String iconClass) {
    return a(
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
}

const _buttonScript = RawText('''
(function() {
  var btn = document.getElementById('show-more-btn');
  if (btn) {
    btn.addEventListener('click', function() {
      var elements = document.querySelectorAll('#appearance-list > .hidden-card');
      for (var i = 0; i < 10 && i < elements.length; i++) {
        elements[i].classList.remove('hidden-card');
      }
      if (document.querySelectorAll('#appearance-list > .hidden-card').length === 0) {
        btn.style.display = 'none';
      }
    });
  }
})();
''');
