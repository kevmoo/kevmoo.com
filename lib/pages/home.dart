import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../constants.dart';
import '../content.dart' as content;

class Home extends StatelessComponent {
  const Home({super.key});

  @override
  Component build(BuildContext context) {
    final posts = content.posts;

    final displayTags = _calculateDisplayTags(posts);

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

            // Subtle Tag Filter Dropdown
            div(classes: 'text-right mb-2', [
              div(classes: 'relative inline-block text-left', [
                select(
                  classes:
                      'bg-white/5 border border-white/10 text-white/50 '
                      'text-[10px] rounded-md focus:ring-sky-500 '
                      'focus:border-sky-500 py-1 pl-2 pr-6 outline-none '
                      'cursor-pointer hover:bg-white/10 transition-colors '
                      'appearance-none',
                  attributes: {'id': 'tag-select'},
                  [
                    const option(value: '', [Component.text('All Topics')]),
                    for (final tag in displayTags)
                      option(value: tag, [Component.text(tag)]),
                  ],
                ),
                // Custom arrow icon
                const div(
                  classes:
                      'absolute inset-y-0 right-0 flex items-center '
                      'px-1.5 pointer-events-none',
                  [
                    Component.element(
                      tag: 'i',
                      classes: 'fas fa-chevron-down text-[8px] opacity-30',
                      children: [],
                    ),
                  ],
                ),
              ]),
            ]),

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
                          div(
                            classes: markerClasses,
                            attributes: {'data-year': '$postYear'},
                            [
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
                            ],
                          ),
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

                    final normalizedTags = post.tags
                        .map(content.normalizeTag)
                        .join(',');

                    list.add(
                      div(
                        classes: cardClasses,
                        attributes: {
                          'data-tags': normalizedTags,
                          'data-year': postYear.toString(),
                        },
                        [
                          div(classes: 'icon', [RawText(post.flavor.awesome)]),
                          div(classes: 'details', [
                            div(classes: 'title', [
                              a(
                                href: linkUrl,
                                target: isWriting ? null : Target.blank,
                                attributes: isWriting
                                    ? {}
                                    : {'rel': 'noopener'},
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
                        ],
                      ),
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
                  children: [_filterScript],
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

List<String> _calculateDisplayTags(List<content.Post> posts) {
  final tagCounts = <String, int>{};
  for (final post in posts) {
    if (post.flavor == content.EntryFlavor.writing) {
      for (final tag in post.tags) {
        final n = content.normalizeTag(tag);
        tagCounts[n] = (tagCounts[n] ?? 0) + 1;
      }
    }
  }
  return (tagCounts.keys.toList()
        ..sort((j, k) => tagCounts[k]!.compareTo(tagCounts[j]!)))
      .take(15)
      .toList()
    ..sort();
}

const _filterScript = RawText('''
(function() {
  var btn = document.getElementById('show-more-btn');
  var select = document.getElementById('tag-select');
  var cards = document.querySelectorAll('.appearance-card');
  var markers = document.querySelectorAll('.year-marker');
  var currentTag = null;

  function update() {
    var hash = window.location.hash.substring(1);
    currentTag = hash ? decodeURIComponent(hash) : null;

    // Update select value
    if (select) {
      select.value = currentTag || '';
    }

    if (!currentTag) {
      // No filter: respect original hidden-card logic
      cards.forEach(function(c) {
        c.classList.remove('tag-filtered', 'tag-matched');
      });
      if (btn) {
        var hasHidden = document.querySelectorAll('.appearance-card.hidden-card').length > 0;
        btn.style.display = hasHidden ? 'inline-block' : 'none';
      }
    } else {
      // Filtered: hide non-matching, show matching (overriding hidden-card)
      cards.forEach(function(c) {
        var cardTags = (c.getAttribute('data-tags') || '').split(',');
        if (cardTags.indexOf(currentTag) !== -1) {
          c.classList.remove('tag-filtered');
          c.classList.add('tag-matched');
        } else {
          c.classList.add('tag-filtered');
          c.classList.remove('tag-matched');
        }
      });
      if (btn) btn.style.display = 'none';
    }

    // Hide/show year markers based on visible cards in that year
    markers.forEach(function(m) {
       var year = m.getAttribute('data-year');
       var hasVisible = false;
       cards.forEach(function(c) {
         if (c.getAttribute('data-year') === year) {
            var isFiltered = c.classList.contains('tag-filtered');
            var isHidden = !currentTag && c.classList.contains('hidden-card');
            if (!isFiltered && !isHidden) {
              hasVisible = true;
            }
         }
       });
       m.style.display = hasVisible ? 'flex' : 'none';
    });
  }

  if (select) {
    select.addEventListener('change', function() {
      var tag = select.value;
      if (!tag) {
        // Use history.replaceState to clear hash without scrolling
        history.replaceState(null, null, ' ');
      } else {
        // Use history.replaceState to update hash without scrolling
        history.replaceState(null, null, '#' + encodeURIComponent(tag));
      }
      update();
    });
  }

  window.addEventListener('hashchange', update);
  update(); // Initial run

  if (btn) {
    btn.addEventListener('click', function() {
      var elements = document.querySelectorAll('#appearance-list > .hidden-card');
      for (var i = 0; i < 10 && i < elements.length; i++) {
        elements[i].classList.remove('hidden-card');
      }
      update();
    });
  }
})();
''');
