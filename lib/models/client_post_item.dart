import 'package:jaspr/jaspr.dart';
import 'data_model.dart';

class ClientPostItem {
  final String permalink;
  final String title;
  final String subTitle;
  final String dateString;
  final int year;
  final List<String> tags;
  final String awesomeHtml;
  final bool isWriting;
  final String linkUrl;
  final EntryFlavor flavor;

  const ClientPostItem({
    required this.permalink,
    required this.title,
    required this.subTitle,
    required this.dateString,
    required this.year,
    required this.tags,
    required this.awesomeHtml,
    required this.isWriting,
    required this.linkUrl,
    required this.flavor,
  });

  @decoder
  factory ClientPostItem.fromRaw(Map<String, dynamic> raw) => ClientPostItem(
    permalink: raw['permalink'] as String,
    title: raw['title'] as String,
    subTitle: raw['subTitle'] as String,
    dateString: raw['dateString'] as String,
    year: raw['year'] as int,
    tags: (raw['tags'] as List).cast<String>(),
    awesomeHtml: raw['awesomeHtml'] as String,
    isWriting: raw['isWriting'] as bool,
    linkUrl: raw['linkUrl'] as String,
    flavor: EntryFlavor.values.byName(raw['flavor'] as String),
  );

  @encoder
  Map<String, dynamic> toRaw() => {
    'permalink': permalink,
    'title': title,
    'subTitle': subTitle,
    'dateString': dateString,
    'year': year,
    'tags': tags,
    'awesomeHtml': awesomeHtml,
    'isWriting': isWriting,
    'linkUrl': linkUrl,
    'flavor': flavor.name,
  };
}
