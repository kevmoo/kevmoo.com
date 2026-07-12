import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../components/footer.dart';
import '../components/header.dart';
import '../constants.dart';
import '../projects_content.dart';

class ProjectsPage extends StatelessComponent {
  const ProjectsPage({super.key});

  @override
  Component build(BuildContext context) {
    final allProjects = projects;

    return Component.fragment([
      const Document.head(
        children: [link(href: '$siteUrl/projects/', rel: 'canonical')],
      ),
      div(
        classes:
            'bg-white dark:bg-slate-950 text-slate-700 dark:text-slate-200 '
            'flex-1 flex flex-col min-h-screen',
        [
          const Header(activePath: '/projects'),
          div(classes: 'max-w-3xl w-full mx-auto px-6 py-16 flex-1', [
            const h1(
              classes:
                  'text-4xl font-black tracking-tight text-slate-950 '
                  'dark:text-white mb-4',
              [Component.text('Projects & Tools')],
            ),
            const p(
              classes: 'text-lg text-slate-600 dark:text-slate-400 mb-10',
              [
                Component.text(
                  'Personal open-source packages, CLI tools, '
                  'and developer configs.',
                ),
              ],
            ),

            div(classes: 'grid grid-cols-1 gap-8', [
              for (final project in allProjects) _buildProjectCard(project),
            ]),
          ]),
          const Footer(),
        ],
      ),
    ]);
  }

  Component _buildProjectCard(Project project) => div(
    classes:
        'border border-slate-200 dark:border-slate-800/80 rounded-xl p-6 '
        'hover:border-blue-500/40 dark:hover:border-blue-400/50 transition-all '
        'shadow-sm bg-slate-50/50 dark:bg-slate-900/50 flex flex-col justify-between',
    [
      div([
        div(classes: 'flex items-center justify-between gap-3 mb-2', [
          div(
            classes:
                'flex items-center gap-3 text-xs font-medium '
                'text-slate-500 dark:text-slate-400 ml-auto',
            [
              if (project.latestVersion != null)
                span(
                  classes:
                      'flex items-center gap-1 bg-slate-200/60 dark:bg-slate-800 '
                      'px-2 py-0.5 rounded text-slate-700 dark:text-slate-300',
                  [
                    const Component.element(
                      tag: 'i',
                      classes: 'fas fa-tag text-[10px]',
                      children: [],
                    ),
                    Component.text('v${project.latestVersion}'),
                  ],
                ),
              if (project.githubStars != null)
                span(classes: 'flex items-center gap-1', [
                  const Component.element(
                    tag: 'i',
                    classes: 'fas fa-star text-amber-400',
                    children: [],
                  ),
                  Component.text('${project.githubStars}'),
                ]),
            ],
          ),
        ]),
        h2(classes: 'text-2xl font-bold text-slate-900 dark:text-white mb-3', [
          Component.text(project.name),
        ]),
        div(
          classes:
              'prose prose-slate dark:prose-invert max-w-none text-sm '
              'text-slate-600 dark:text-slate-300 mb-6 leading-relaxed',
          [RawText(project.contentHtml)],
        ),
      ]),
      div(
        classes:
            'flex items-center justify-between pt-4 border-t '
            'border-slate-200/60 dark:border-slate-800/80 text-xs font-mono',
        [
          if (project.installCommand != null &&
              project.installCommand!.isNotEmpty)
            code(
              classes:
                  'bg-slate-200/50 dark:bg-slate-800/80 text-slate-700 '
                  'dark:text-slate-200 px-2.5 py-1 rounded select-all',
              [Component.text(project.installCommand!)],
            )
          else
            const span([]),
          div(
            classes:
                'flex items-center gap-4 font-sans font-semibold '
                'text-blue-600 dark:text-blue-400',
            [
              if (project.pubUrl != null)
                a(
                  href: project.pubUrl!,
                  target: Target.blank,
                  classes: 'hover:underline flex items-center gap-1',
                  [
                    const Component.text('pub.dev'),
                    const Component.element(
                      tag: 'i',
                      classes: 'fas fa-external-link-alt text-[10px]',
                      children: [],
                    ),
                  ],
                ),
              a(
                href: project.githubUrl!,
                target: Target.blank,
                classes: 'hover:underline flex items-center gap-1',
                [
                  const Component.text('GitHub'),
                  const Component.element(
                    tag: 'i',
                    classes: 'fab fa-github text-sm',
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
