import 'dart:js_interop';

import 'package:web/web.dart';

void main() {
  final linksTable = document.querySelector('table') as HTMLTableElement;

  final tableBody = linksTable.createTBody();

  for (var entry in _entries.reversed) {
    final link =
        '<a href="${entry.uri}" rel="noopener" target="_blank">${entry.title}</a>';

    final subContent = entry.subTitle ?? '&nbsp;';
    tableBody.insertAdjacentHTML(
      'beforeend',
      '''
<tr>
  <td class="icon">${entry.flavor.awesome}</td>
  <td class="details">$link<br>$subContent</td>
  <td class="date">${entry.date.pretty}</td>
</tr>
'''
          .toJS,
    );
  }
}

final _entries = [
  Entry(
    title: "Let's go far with Flutter",
    subTitle: 'fluttercon EU',
    uri: 'https://www.youtube.com/watch?v=lgG3O_sScqU',
    date: DateTime(2025, 9, 24),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: 'Flutter Web Updates with Kevin Moore',
    subTitle: 'Flying High with Flutter',
    uri: 'https://www.youtube.com/watch?v=-JAej7KKTUQ',
    date: DateTime(2024, 11, 27),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title:
        'Flutter: Google’s UI toolkit for Mobile, Web, & Desktop Apps '
        'from a Single Codebase',
    subTitle: 'GOSIM China 2024',
    uri: 'https://www.youtube.com/watch?v=vbcPv0kiRdU',
    date: DateTime(2024, 10, 17),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: 'Interview with Łukasz Kosman - Why do we need Flutter for Web?',
    subTitle: 'Flutter CTO Survey 2024',
    uri: 'https://www.youtube.com/watch?v=USTi-_KxJV0',
    date: DateTime(2024, 5, 16),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: "What's new in Flutter",
    subTitle: 'Google I/O',
    uri: 'https://www.youtube.com/watch?v=lpnKWK-KEYs',
    date: DateTime(2024, 5, 15),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: 'Flutter, Dart, AND Wasm: Shipping a new model for web applications',
    subTitle: 'Wasm I/O',
    uri: 'https://www.youtube.com/watch?v=qx42r29HhcM',
    date: DateTime(2024, 3, 14),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: 'Writing a code generator',
    subTitle: 'Observable Flutter #35',
    uri: 'https://www.youtube.com/watch?v=ngUiuIdcGjk',
    date: DateTime(2024, 2, 8),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: 'Front-end and backend with Flutter and Firebase',
    subTitle: 'F3 Conference',
    uri: 'https://www.youtube.com/watch?v=wNmPWLTZC2o',
    date: DateTime(2023, 9, 23),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: 'Developer Platforms with Kevin Moore',
    subTitle: 'KIRUPA',
    uri: 'https://www.youtube.com/watch?v=p9I2Ozvtpvc',
    date: DateTime(2023, 6, 27),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: "Evolving Flutter's support for the web",
    subTitle: 'Google I/O',
    uri: 'https://www.youtube.com/watch?v=PY42FysQTgw',
    date: DateTime(2023, 5, 10),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: 'Flutter, Dart, AND WASM-GC: A New Model for Web Applications',
    subTitle: 'Wasm I/O',
    uri: 'https://www.youtube.com/watch?v=Nkjc9r0WDNo',
    date: DateTime(2023, 3, 23),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: 'Q&A/AMA with @MatanLurey',
    subTitle: 'Humpday Q&A/AMA',
    uri: 'https://www.youtube.com/watch?v=Y361N1jCu50',
    date: DateTime(2022, 9, 14),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: 'How Flutter enhances web apps',
    subTitle: 'Google I/O',
    uri: 'https://www.youtube.com/watch?v=kCnYRhkfWHY',
    date: DateTime(2022, 5, 12),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: 'Full Stack Dart',
    subTitle: 'Humpday Q&A/AMA',
    uri: 'https://www.youtube.com/watch?v=ThhjDJ8uYzU',
    date: DateTime(2022, 3, 23),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: 'Power-up your Flutter app with Google APIs',
    subTitle: 'Google I/O',
    uri: 'https://www.youtube.com/watch?v=z4MsuZiEezY',
    date: DateTime(2021, 5, 19),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: 'Cloud, Dart, and full-stack Flutter Q & A',
    subTitle: 'Google I/O',
    uri: 'https://www.youtube.com/watch?v=r8rVm4-RJJM',
    date: DateTime(2021, 5, 19),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: 'Building platform adaptive apps',
    subTitle: 'Google I/O',
    uri: 'https://www.youtube.com/watch?v=RCdeSKVt7LI',
    date: DateTime(2021, 5, 19),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: 'Dart in the Cloud',
    subTitle: 'Rubber Duck Engineering',
    uri: 'https://www.youtube.com/watch?v=SImcty5QJhM',
    date: DateTime(2021, 7, 29),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: 'Dart: Productive, Fast, Multi-Platform - Pick 3',
    subTitle: 'Google I/O',
    uri: 'https://www.youtube.com/watch?v=J5DQRPRBiFI',
    date: DateTime(2019, 5, 9),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: 'Null safety in Dart',
    subTitle: 'Flutter Day 2020',
    uri: 'https://www.youtube.com/watch?v=W4IpdomZb6g',
    date: DateTime(2020, 7, 14),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: 'Full Stack Dart',
    subTitle: 'Google Cloud Platform Podcast',
    uri:
        'https://www.gcppodcast.com/post/episode-261-full-stack-dart-with-tony-pujals-and-kevin-moore/',
    date: DateTime(2021, 5, 25),
    flavor: EntryFlavor.podcast,
  ),
  Entry(
    title: 'Dart in the Cloud, Backend, Command Line, and Shelf',
    subTitle: 'Flutter 101 Podcast',
    uri:
        'https://flutter101.dev/episodes/dart-backend-cloud-command-line-shelf-with-kevin-moore',
    date: DateTime(2021, 7, 23),
    flavor: EntryFlavor.podcast,
  ),
  Entry(
    title: 'Dart Language Funnel',
    subTitle: 'Humpday Q&A/AMA',
    uri: 'https://youtu.be/zkq8XYLm53Y?t=2668',
    date: DateTime(2021, 9, 22),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: 'Null Safety and Cloud Functions',
    subTitle: 'Humpday Q&A/AMA',
    uri: 'https://youtu.be/IjrzpE1dB1w?t=1220',
    date: DateTime(2021, 3, 24),
    flavor: EntryFlavor.youtube,
  ),
  Entry(
    title: 'Flutter Web',
    subTitle: "It's All Widgets",
    uri: 'https://itsallwidgets.com/podcast/episodes/27/kevin-moore',
    date: DateTime(2019, 5, 23),
    flavor: EntryFlavor.podcast,
  ),
]..sort();

class Entry implements Comparable<Entry> {
  Entry({
    required this.title,
    this.subTitle,
    required this.uri,
    required this.date,
    required this.flavor,
  });

  final String title;
  final String? subTitle;
  final String uri;
  final EntryFlavor flavor;
  final DateTime date;

  @override
  int compareTo(Entry other) {
    var value = date.compareTo(other.date);
    if (value == 0) {
      value = title.compareTo(other.title);
    }
    return value;
  }
}

enum EntryFlavor {
  calendar,
  youtube,
  podcast;

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
    }
    return '<i class="$clazz" title="$title"></i>';
  }
}

const _nbh = '&#x2011;';

extension on DateTime {
  String get pretty =>
      '$year$_nbh${month.toString().padLeft(2, '0')}$_nbh'
      '${day.toString().padLeft(2, '0')}';
}
