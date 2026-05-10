import 'dart:io';
import 'package:work_j832_com/content.dart' as content;

void main() async {
  print('=== Starting Production Build ===');

  // 1. Compile Tailwind CSS to the source web directory
  // (for dev server support)
  print('Compiling Tailwind CSS...');
  final tailwindResult = await Process.run('npx', [
    '@tailwindcss/cli',
    '--input',
    'styles.tw.css',
    '--output',
    'web/styles.css',
    '--minify',
  ]);
  if (tailwindResult.exitCode != 0) {
    stderr.write(tailwindResult.stderr);
    exit(tailwindResult.exitCode);
  }
  print('Tailwind CSS compiled successfully.');

  // 2. Generate sitemaps and feeds inside the source web directory
  // (for dev server support)
  print('Generating RSS/Atom feed (feed.xml)...');
  File('web/feed.xml').writeAsStringSync(content.generateAtomFeed());
  print('Atom feed generated successfully.');

  print('Generating sitemap (sitemap.xml)...');
  File('web/sitemap.xml').writeAsStringSync(content.generateSitemap());
  print('Sitemap generated successfully.');

  // 3. Build Jaspr Static Site (automatically bundles all web/ assets to build/jaspr)
  print('Building Jaspr static site...');
  final jasprResult = await Process.run('dart', [
    'pub',
    'global',
    'run',
    'jaspr_cli:jaspr',
    'build',
  ]);
  if (jasprResult.exitCode != 0) {
    stderr.write(jasprResult.stderr);
    exit(jasprResult.exitCode);
  }
  print('Jaspr build completed successfully.');
  print('=== Build Successful ===');
}
