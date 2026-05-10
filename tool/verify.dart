import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:work_j832_com/constants.dart';

void main() async {
  print('=== Starting Production Integrity Verification ===');

  final liveBase = siteUrl;
  final localBase = 'http://localhost:8080';

  // 1. Fetch live RSS/Atom Feed to extract all blog post URLs dynamically
  print('Fetching live RSS feed from $liveBase/feed.xml...');
  String rssBody;
  try {
    final rssResponse = await http.get(Uri.parse('$liveBase/feed.xml'));
    if (rssResponse.statusCode != 200) {
      print('Error: Live RSS feed returned HTTP ${rssResponse.statusCode}');
      exit(1);
    }
    rssBody = rssResponse.body;
  } catch (e) {
    print('Failed to connect to live site: $e');
    exit(1);
  }

  // 2. Extract relative post paths using RegExp
  // (supports both RSS and Atom feed links)
  final linkRegExp = RegExp(
    r'(?:<link href="|<link>|id>)(https://work\.j832\.com/([^"<\s]+))',
  );
  final matches = linkRegExp.allMatches(rssBody);

  final paths = <String>[
    '/', // Home page
    '/about/', // About page
    '/feed.xml', // RSS feed page
    '/sitemap.xml', // Sitemap page
  ];

  for (final match in matches) {
    final path = match.group(2)!;
    if (path.isNotEmpty && !paths.contains('/$path')) {
      paths.add('/$path');
    }
  }

  print('Extracted ${paths.length - 4} post URLs from live feed.');
  print('Verifying a total of ${paths.length} critical production files...\n');

  var successCount = 0;
  var failureCount = 0;

  // 3. Query the local development server on port 8080
  for (final path in paths) {
    final localUrl = '$localBase$path';

    stdout.write('Verifying $path... ');

    try {
      final localResponse = await http.get(Uri.parse(localUrl));
      if (localResponse.statusCode == 200) {
        stdout.write('✅ Production OK (200)');
        successCount++;
      } else {
        stdout.write('❌ Production FAILED (${localResponse.statusCode})');
        failureCount++;
      }

      if (localResponse.statusCode == 200) {
        final localLength = localResponse.bodyBytes.length;
        stdout.write(' | Size: $localLength bytes');
      }
      stdout.writeln();
    } catch (e) {
      stdout.writeln('❌ Production ERROR: $e');
      failureCount++;
    }
  }

  print('\n=== Verification Summary ===');
  print('✅ Successful: $successCount');
  if (failureCount > 0) {
    print('❌ Failed/Errors: $failureCount');
    print('Please check and fix any missing routes or 404s before deploying.');
    exit(1);
  } else {
    print(
      '🎉 All critical production files are verified and '
      'loading successfully in build/jaspr!',
    );
  }
}
