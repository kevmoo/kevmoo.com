import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart run tool/new_post.dart "Your Post Title"');
    exit(1);
  }

  final title = args.join(' ');
  final now = DateTime.now();
  final slug = _generateSlug(title);

  final year = now.year.toString();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  final dateStr = '$year-$month-$day';

  final filename = '_posts/$dateStr-$slug.md';
  final file = File(filename);

  if (file.existsSync()) {
    print('Error: File $filename already exists!');
    exit(1);
  }

  // Format timezone offset (e.g., -07:00)
  final offset = now.timeZoneOffset;
  final offsetSign = offset.isNegative ? '-' : '+';
  final offsetHours = offset.inHours.abs().toString().padLeft(2, '0');
  final offsetMinutes = (offset.inMinutes.abs() % 60).toString().padLeft(
    2,
    '0',
  );
  final timezoneStr = '$offsetSign$offsetHours:$offsetMinutes';

  final hour = now.hour.toString().padLeft(2, '0');
  final minute = now.minute.toString().padLeft(2, '0');
  final second = now.second.toString().padLeft(2, '0');
  final fullDateStr = '$dateStr $hour:$minute:$second $timezoneStr';

  final template =
      '''
---
title: "$title"
date: $fullDateStr
tags:
  - general
---

Write your post content here in markdown format!
''';

  file.writeAsStringSync(template);
  print('🎉 Created new blog post stub at:');
  print('👉 $filename');
}

String _generateSlug(String title) => title
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
    .trim()
    .replaceAll(RegExp(r'\s+'), '-');
