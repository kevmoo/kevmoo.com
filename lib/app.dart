import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'content.dart' as content;
import 'pages/about.dart';
import 'pages/home.dart';
import 'pages/post_page.dart';

class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    // Dynamically compile post routes from our parsed content database
    final postRoutes = content.posts
        .where((post) => post.flavor == content.EntryFlavor.writing)
        .map((post) {
          return Route(
            path: post.permalink,
            title: post.title,
            builder: (context, state) => PostPage(permalink: post.permalink),
          );
        })
        .toList();

    return div(classes: 'min-h-screen flex flex-col text-slate-700 font-sans', [
      Router(
        routes: [
          Route(
            path: '/',
            title: 'kevmoo @ Work',
            builder: (context, state) => const Home(),
          ),
          Route(
            path: '/about',
            title: 'About | kevmoo @ Work',
            builder: (context, state) => const About(),
          ),
          ...postRoutes,
        ],
      ),
    ]);
  }
}
