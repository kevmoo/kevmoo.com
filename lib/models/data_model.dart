enum EntryFlavor {
  calendar,
  youtube,
  podcast,
  writing,
  link;

  String get label => switch (this) {
    EntryFlavor.youtube => 'YouTube',
    EntryFlavor.podcast => 'Podcast',
    EntryFlavor.calendar => 'Event',
    EntryFlavor.writing => 'Writing',
    EntryFlavor.link => 'Link',
  };

  String get awesome {
    String clazz;
    String title;
    switch (this) {
      case EntryFlavor.youtube:
        clazz = 'fab fa-youtube fa-2x';
        title = 'YouTube';
      case EntryFlavor.podcast:
        clazz = 'fa fa-podcast fa-2x';
        title = 'Podcast';
      case EntryFlavor.calendar:
        clazz = 'fa fa-calendar fa-2x';
        title = 'Future event';
      case EntryFlavor.writing:
        clazz = 'fa fa-pencil-alt fa-2x';
        title = 'Writing';
      case EntryFlavor.link:
        clazz = 'fa fa-link fa-2x';
        title = 'Link';
    }
    return '<i class="$clazz" title="$title"></i>';
  }
}

class Post {
  final String permalink;
  final String title;
  final String? subTitle;
  final DateTime date;
  final List<String> tags;
  final String? contentHtml;
  final bool isHtml;
  final String? uri;
  final EntryFlavor flavor;

  Post({
    required this.permalink,
    required this.title,
    this.subTitle,
    required this.date,
    required this.tags,
    this.contentHtml,
    required this.isHtml,
    this.uri,
    required this.flavor,
  });
}

class Project {
  final String id;
  final String name;
  final String repo; // e.g. kevmoo/pubviz
  final String? pubPackage; // e.g. pubviz
  final String? installCommand;
  final bool featured;
  final bool ignore;
  final List<String> relatedPostPermalinks;
  final String contentHtml;
  final String? latestVersion;
  final int? githubStars;
  final String? pubUrl;
  final String? githubUrl;
  final String? lastReviewedSha;
  final DateTime? lastReviewedAt;

  Project({
    required this.id,
    required this.name,
    required this.repo,
    this.pubPackage,
    this.installCommand,
    this.featured = false,
    this.ignore = false,
    this.relatedPostPermalinks = const [],
    required this.contentHtml,
    this.latestVersion,
    this.githubStars,
    this.pubUrl,
    this.githubUrl,
    this.lastReviewedSha,
    this.lastReviewedAt,
  });
}

typedef SocialLink = ({String href, String title, String iconClass});

const socialLinks = <SocialLink>[
  (
    href: 'https://bsky.app/profile/kevmoo.com',
    title: 'Bluesky @kevmoo.com',
    iconClass: 'fab fa-bluesky',
  ),
  (
    href: 'https://github.com/kevmoo/',
    title: 'GitHub/kevmoo',
    iconClass: 'fab fa-github',
  ),
  (
    href: 'https://mastodon.social/@kevmoo',
    title: 'mastodon.social/@kevmoo',
    iconClass: 'fab fa-mastodon',
  ),
  (
    href: 'https://www.linkedin.com/in/kevmoo/',
    title: 'LinkedIn/kevmoo',
    iconClass: 'fab fa-linkedin',
  ),
  (
    href: 'https://www.reddit.com/user/kevmoo',
    title: 'Reddit/kevmoo',
    iconClass: 'fab fa-reddit',
  ),
  (
    href: 'https://g.dev/kevmoo',
    title: 'Google Developers',
    iconClass: 'fab fa-google',
  ),
  (
    href: 'https://twitter.com/kevmoo',
    title: 'Twitter @kevmoo',
    iconClass: 'fab fa-twitter',
  ),
];
