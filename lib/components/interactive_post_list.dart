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
                  'year-marker flex items-center gap-4 $topPadding '
                  'first:pt-0 pb-4',
              attributes: {'data-year': '$postYear'},
              [
                span(
                  classes: 'text-sky-400/90 font-black tracking-widest text-lg',
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

      if (isVisible) {
        itemsToRender.add(_buildPostCard(post));
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
              classes:
                  'bg-slate-100 dark:bg-slate-900 border border-slate-200 '
                  'dark:border-slate-800 text-slate-700 dark:text-slate-300 '
                  'text-sm font-semibold rounded-xl hover:bg-slate-200/80 '
                  'dark:hover:bg-slate-800 transition-all shadow-sm '
                  'cursor-pointer py-2.5 px-4 flex items-center gap-2',
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
              div(
                classes:
                    'absolute right-0 mt-2 w-56 rounded-xl bg-white '
                    'dark:bg-slate-900 border border-slate-200 '
                    'dark:border-slate-800 shadow-xl p-1.5 z-50 '
                    'flex flex-col gap-0.5 text-left',
                [
                  for (final f in availableFlavors)
                    _buildDropdownItem(
                      label: f.label,
                      isSelected: selectedFlavor == f,
                      onClick: () => _onFlavorSelected(f.name),
                    ),
                  _buildDropdownItem(
                    label: 'Everything',
                    isSelected: selectedFlavor == null,
                    onClick: () => _onFlavorSelected(''),
                  ),
                ],
              ),
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
            classes:
                'bg-slate-100 dark:bg-slate-900 border '
                'border-slate-200 dark:border-slate-800 text-slate-700 '
                'dark:text-slate-300 px-6 py-2.5 rounded-lg text-sm '
                'font-semibold hover:bg-slate-200/80 '
                'dark:hover:bg-slate-800 transition-all shadow-sm '
                'cursor-pointer',
            events: {'click': (event) => setState(() => visibleCount += 10)},
            [const Component.text('Show more posts...')],
          ),
        ]),
    ]);
  }

  Component _buildPostCard(ClientPostItem post) => div(
    classes:
        'border border-slate-200 dark:border-slate-800/80 rounded-xl '
        'p-5 bg-slate-50/50 dark:bg-slate-900/50 shadow-sm '
        'hover:border-blue-500/40 dark:hover:border-blue-400/50 '
        'transition-all appearance-card flex items-center gap-4',
    attributes: {
      'data-tags': post.tags.join(','),
      'data-year': post.year.toString(),
    },
    [
      div(
        classes:
            'icon text-blue-600 dark:text-blue-400 w-10 text-center '
            'flex-shrink-0',
        [RawText(post.awesomeHtml)],
      ),
      div(classes: 'details flex flex-col text-left flex-1', [
        div(
          classes:
              'title text-base font-bold text-slate-900 dark:text-white '
              'mb-0.5',
          [
            a(
              href: post.linkUrl,
              target: post.isWriting ? null : Target.blank,
              attributes: post.isWriting ? {} : {'rel': 'noopener'},
              classes:
                  'hover:text-blue-600 dark:hover:text-blue-400 '
                  'transition-colors',
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
          ],
        ),
        if (post.subTitle.isNotEmpty)
          div(classes: 'subtitle text-xs text-slate-500 dark:text-slate-400', [
            Component.text(post.subTitle),
          ]),
      ]),
      div(
        classes:
            'date font-mono text-xs text-slate-400 dark:text-slate-500 '
            'whitespace-nowrap ml-2',
        [Component.text(post.dateString)],
      ),
    ],
  );

  Component _buildDropdownItem({
    required String label,
    required bool isSelected,
    required VoidCallback onClick,
  }) {
    final activeClasses =
        'bg-blue-50 dark:bg-blue-950/40 text-blue-600 dark:text-blue-400 '
        'font-bold';
    final inactiveClasses =
        'text-slate-700 dark:text-slate-300 hover:bg-slate-100 '
        'dark:hover:bg-slate-800/80';
    final stateClasses = isSelected ? activeClasses : inactiveClasses;

    return button(
      classes:
          'w-full px-4 py-2.5 rounded-lg text-left text-sm font-medium '
          'transition-colors cursor-pointer flex items-center '
          'justify-between $stateClasses',
      events: {'click': (event) => onClick()},
      [
        Component.text(label),
        if (isSelected)
          const Component.element(
            tag: 'i',
            classes:
                'fas fa-check text-blue-600 dark:text-blue-400 text-xs ml-2',
            children: [],
          ),
      ],
    );
  }
}
