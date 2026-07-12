import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../models/client_post_item.dart';
import '../models/data_model.dart';

@client
class InteractivePostList extends StatefulComponent {
  final List<ClientPostItem> posts;

  const InteractivePostList({required this.posts, super.key});

  @override
  State<InteractivePostList> createState() => _InteractivePostListState();
}

class _InteractivePostListState extends State<InteractivePostList> {
  EntryFlavor? selectedFlavor;
  int visibleCount = 10;
  bool isMenuOpen = false;
  JSExportedDartFunction? _hashListener;

  List<EntryFlavor> get availableFlavors => EntryFlavor.values
      .where((flavor) => component.posts.any((post) => post.flavor == flavor))
      .toList();

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _syncFromHash();
      _hashListener = ((web.Event _) {
        _syncFromHash();
      }).toJS;
      web.window.addEventListener('hashchange', _hashListener);
    }
  }

  @override
  void dispose() {
    if (kIsWeb && _hashListener != null) {
      web.window.removeEventListener('hashchange', _hashListener);
    }
    super.dispose();
  }

  void _syncFromHash() {
    final hash = web.window.location.hash;
    EntryFlavor? flavor;
    if (hash.isNotEmpty && hash.startsWith('#')) {
      final name = Uri.decodeComponent(hash.substring(1));
      for (final f in availableFlavors) {
        if (f.name == name) {
          flavor = f;
          break;
        }
      }
    }
    if (flavor != selectedFlavor) {
      setState(() {
        selectedFlavor = flavor;
      });
    }
  }

  void _onFlavorSelected(String value) {
    EntryFlavor? flavor;
    for (final f in availableFlavors) {
      if (f.name == value) {
        flavor = f;
        break;
      }
    }
    if (kIsWeb) {
      if (flavor == null) {
        web.window.history.replaceState(null, '', ' ');
      } else {
        web.window.history.replaceState(
          null,
          '',
          '#${Uri.encodeComponent(flavor.name)}',
        );
      }
    }
    setState(() {
      selectedFlavor = flavor;
      isMenuOpen = false;
    });
  }

  @override
  Component build(BuildContext context) {
    final isFiltered = selectedFlavor != null;

    final itemsToRender = <Component>[];
    for (var i = 0; i < component.posts.length; i++) {
      final post = component.posts[i];
      final postYear = post.year;

      final matchesFlavor = !isFiltered || post.flavor == selectedFlavor;
      final isHiddenByLimit = !isFiltered && i >= visibleCount;
      final isVisible = matchesFlavor && !isHiddenByLimit;

      // Check if we should render a year marker above this post
      if (i == 0 || component.posts[i - 1].year != postYear) {
        // Only render the marker if this year has at least one visible post
        final hasVisibleInYear = component.posts
            .where((item) => item.year == postYear)
            .any((item) {
              final idx = component.posts.indexOf(item);
              final itemMatches = !isFiltered || item.flavor == selectedFlavor;
              final itemLimit = !isFiltered && idx >= visibleCount;
              return itemMatches && !itemLimit;
            });

        if (hasVisibleInYear) {
          final isFirst = itemsToRender.isEmpty;
          final topPadding = isFirst ? 'pt-0' : 'pt-10';
          itemsToRender.add(
            div(
              classes:
                  'year-marker year-marker-container $topPadding first:pt-0',
              attributes: {'data-year': '$postYear'},
              [
                span(classes: 'year-marker-text', [
                  Component.text('$postYear'),
                ]),
                const div(classes: 'year-marker-line', []),
              ],
            ),
          );
        }
      }

      if (isVisible) {
        itemsToRender.add(PostCard(post: post));
      }
    }

    final hasMore = !isFiltered && component.posts.length > visibleCount;

    return div(classes: 'relative w-full', [
      // Custom HTML/Tailwind Dropdown Menu (Floating)
      div(
        classes:
            'absolute right-0 top-[-6px] z-20 transition-opacity '
            'duration-150 '
            '${isMenuOpen ? 'opacity-100' : 'opacity-50 hover:opacity-100'}',
        [
          div(classes: 'relative inline-block text-left', [
            // Trigger Button
            button(
              classes: 'dropdown-trigger',
              attributes: {'id': 'flavor-dropdown-trigger'},
              events: {
                'click': (event) => setState(() => isMenuOpen = !isMenuOpen),
              },
              [
                Component.text(selectedFlavor?.label ?? 'Everything'),
                Component.element(
                  tag: 'i',
                  classes:
                      'fas fa-chevron-down text-xs text-slate-400 '
                      'dark:text-slate-500 transition-transform '
                      '${isMenuOpen ? 'rotate-180' : ''}',
                  children: [],
                ),
              ],
            ),

            // Floating Menu Popup
            if (isMenuOpen)
              div(classes: 'dropdown-menu', [
                for (final f in availableFlavors)
                  _DropdownItem(
                    label: f.label,
                    isSelected: selectedFlavor == f,
                    onClick: () => _onFlavorSelected(f.name),
                  ),
                _DropdownItem(
                  label: 'Everything',
                  isSelected: selectedFlavor == null,
                  onClick: () => _onFlavorSelected(''),
                ),
              ]),
          ]),
        ],
      ),

      // Main posts list
      Component.element(
        tag: 'main',
        classes: 'flex flex-col gap-4',
        attributes: {'id': 'appearance-list'},
        children: itemsToRender,
      ),

      // Progressive "Show More" Button
      if (hasMore)
        div(classes: 'text-center mt-12', [
          button(
            attributes: {'id': 'show-more-btn'},
            classes: 'show-more-btn',
            events: {'click': (event) => setState(() => visibleCount += 10)},
            [const Component.text('Show more posts...')],
          ),
        ]),
    ]);
  }
}

class PostCard extends StatelessComponent {
  final ClientPostItem post;

  const PostCard({required this.post, super.key});

  @override
  Component build(BuildContext context) => div(
    classes: 'appearance-card',
    attributes: {
      'data-tags': post.tags.join(','),
      'data-year': post.year.toString(),
    },
    [
      div(classes: 'card-icon', [RawText(post.awesomeHtml)]),
      div(classes: 'card-details', [
        div(classes: 'card-title', [
          a(
            href: post.linkUrl,
            target: post.isWriting ? null : Target.blank,
            attributes: post.isWriting ? const {} : const {'rel': 'noopener'},
            classes: 'card-title-link',
            [
              Component.text(post.title.trim()),
              if (!post.isWriting) ...[
                const RawText('&nbsp;'),
                const Component.element(
                  tag: 'i',
                  classes: 'fa fa-external-link-alt text-xs opacity-50',
                  children: [],
                ),
              ],
            ],
          ),
        ]),
        if (post.subTitle.isNotEmpty)
          div(classes: 'card-subtitle', [Component.text(post.subTitle)]),
      ]),
      div(classes: 'card-date', [Component.text(post.dateString)]),
    ],
  );
}

class _DropdownItem extends StatelessComponent {
  final String label;
  final bool isSelected;
  final VoidCallback onClick;

  const _DropdownItem({
    required this.label,
    required this.isSelected,
    required this.onClick,
  });

  @override
  Component build(BuildContext context) => button(
    classes:
        'dropdown-item-base '
        '${isSelected ? 'dropdown-item-active' : 'dropdown-item-inactive'}',
    events: {'click': (event) => onClick()},
    [
      Component.text(label),
      if (isSelected)
        const Component.element(
          tag: 'i',
          classes: 'fas fa-check text-blue-600 dark:text-blue-400 text-xs ml-2',
          children: [],
        ),
    ],
  );
}
