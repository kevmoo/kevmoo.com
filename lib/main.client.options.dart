// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:work_j832_com/components/interactive_post_list.dart'
    deferred as _interactive_post_list;
import 'package:work_j832_com/models/client_post_item.dart'
    as _client_post_item;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultClientOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ClientOptions get defaultClientOptions => ClientOptions(
  clients: {
    'interactive_post_list': ClientLoader(
      (p) => _interactive_post_list.InteractivePostList(
        posts: (p['posts'] as List<Object?>)
            .map(
              (i) => _client_post_item.ClientPostItem.fromRaw(
                i as Map<String, dynamic>,
              ),
            )
            .toList(),
      ),
      loader: _interactive_post_list.loadLibrary,
    ),
  },
);
