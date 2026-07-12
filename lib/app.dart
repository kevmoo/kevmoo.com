import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'models/data_model.dart';
import 'pages/about.dart';
import 'pages/home.dart';
import 'pages/post_page.dart';
import 'pages/projects_page.dart';
import 'pages/static_outputs.dart';

class App extends StatelessComponent {
  final List<Post> posts;
  final List<Project> projects;
  final String aboutContentHtml;

  const App({
    required this.posts,
    required this.projects,
    required this.aboutContentHtml,
    super.key,
  });

  @override
  Component build(BuildContext context) {
    // Dynamically compile post routes from our parsed content database
    final postRoutes = posts
        .where((post) => post.flavor == EntryFlavor.writing)
        .map(
          (post) => Route(
            path: post.permalink,
            title: post.title,
            builder: (context, state) => PostPage(permalink: post.permalink),
          ),
        )
        .toList();

    return div(classes: 'min-h-screen flex flex-col text-slate-700 font-sans', [
      Router(
        routes: [
          Route(
            path: '/',
            title: 'kevmoo @ Work',
            builder: (context, state) => Home(posts: posts),
          ),
          Route(
            path: '/about',
            title: 'About | kevmoo @ Work',
            builder: (context, state) => About(contentHtml: aboutContentHtml),
          ),
          Route(
            path: '/projects',
            title: 'Projects | kevmoo @ Work',
            builder: (context, state) => ProjectsPage(projects: projects),
          ),
          Route(
            path: '/feed.xml',
            title: 'Feed | kevmoo @ Work',
            builder: (context, state) => const FeedOutput(),
          ),
          Route(
            path: '/sitemap.xml',
            title: 'Sitemap | kevmoo @ Work',
            builder: (context, state) => const SitemapOutput(),
          ),
          Route(
            path: '/styles.css',
            title: 'Styles | kevmoo @ Work',
            builder: (context, state) => const StylesOutput(),
          ),
          ...postRoutes,
        ],
      ),
    ]);
  }
}
