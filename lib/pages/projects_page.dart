import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import '../components/footer.dart';
import '../components/header.dart';
import '../constants.dart';
import '../models/data_model.dart';

class ProjectsPage extends StatelessComponent {
  final List<Project> projects;
  final List<Post> posts;

  const ProjectsPage({required this.projects, required this.posts, super.key});

  @override
  Component build(BuildContext context) {
    final allProjects = projects;

    final postsByProject = <String, List<Post>>{};
    for (final post in posts) {
      final projectId = post.projectId;
      if (projectId != null) {
        postsByProject.putIfAbsent(projectId, () => []).add(post);
      }
    }

    return Component.fragment([
      const Document.head(
        children: [link(href: '$siteUrl/projects', rel: 'canonical')],
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
              for (final project in allProjects)
                ProjectCard(
                  project: project,
                  relatedPosts: postsByProject[project.id] ?? const [],
                  key: ValueKey(project.id),
                ),
            ]),
          ]),
          const Footer(),
        ],
      ),
    ]);
  }
}

class ProjectCard extends StatelessComponent {
  final Project project;
  final List<Post> relatedPosts;

  const ProjectCard({
    required this.project,
    required this.relatedPosts,
    super.key,
  });

  @override
  Component build(BuildContext context) {
    final installCommand = project.installCommand;
    final pubUrl = project.pubUrl;
    final githubUrl = project.githubUrl;

    return div(id: project.id, classes: 'project-card', [
      div([
        div(classes: 'flex items-center justify-between gap-3 mb-2', [
          div(classes: 'project-metadata', [
            if (project.latestVersion != null)
              span(classes: 'project-version', [
                const Component.element(
                  tag: 'i',
                  classes: 'fas fa-tag text-[10px]',
                  children: [],
                ),
                Component.text('v${project.latestVersion}'),
              ]),
            if (project.githubStars != null)
              span(classes: 'flex items-center gap-1', [
                const Component.element(
                  tag: 'i',
                  classes: 'fas fa-star text-amber-400',
                  children: [],
                ),
                Component.text('${project.githubStars}'),
              ]),
          ]),
        ]),
        h2(classes: 'project-title', [Component.text(project.name)]),
        div(classes: 'prose prose-slate dark:prose-invert project-desc', [
          RawText(project.contentHtml),
        ]),
        if (relatedPosts.isNotEmpty) ...[
          div(
            classes:
                'mt-4 pt-4 border-t border-slate-100 '
                'dark:border-slate-800/60',
            [
              const div(
                classes:
                    'text-xs font-semibold text-slate-400 '
                    'dark:text-slate-500 uppercase tracking-wider mb-2',
                [Component.text('Related Posts')],
              ),
              ul(classes: 'space-y-1.5', [
                for (final post in relatedPosts)
                  li(
                    classes:
                        'text-sm flex items-center '
                        'justify-between gap-4',
                    [
                      a(
                        href: post.permalink,
                        classes:
                            'hover:underline text-slate-700 '
                            'dark:text-slate-200 font-medium flex-1',
                        [Component.text(post.title)],
                      ),
                      span(
                        classes:
                            'text-xs font-mono text-slate-400 '
                            'dark:text-slate-500 whitespace-nowrap',
                        [
                          Component.text(
                            formatReadableDate(post.date, shortMonth: true),
                          ),
                        ],
                      ),
                    ],
                  ),
              ]),
            ],
          ),
        ],
      ]),
      div(classes: 'project-footer', [
        if (installCommand != null && installCommand.isNotEmpty)
          code(classes: 'project-install-cmd', [
            Component.text(installCommand),
          ]),
        div(classes: 'project-links', [
          if (pubUrl != null)
            a(
              href: pubUrl,
              target: Target.blank,
              attributes: const {'rel': 'noopener'},
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
          if (githubUrl != null)
            a(
              href: githubUrl,
              target: Target.blank,
              attributes: const {'rel': 'noopener'},
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
        ]),
      ]),
    ]);
  }
}
