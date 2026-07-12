// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:work_j832_com/components/interactive_post_list.dart'
    as _interactive_post_list;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clientId: 'main.client.dart.js',
  clients: {
    _interactive_post_list.InteractivePostList:
        ClientTarget<_interactive_post_list.InteractivePostList>(
          'interactive_post_list',
          params: __interactive_post_listInteractivePostList,
        ),
  },
);

Map<String, Object?> __interactive_post_listInteractivePostList(
  _interactive_post_list.InteractivePostList c,
) => {'posts': c.posts.map((i) => i.toRaw()).toList()};
