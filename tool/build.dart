import 'dart:io';

void main() async {
  print('=== Starting Production Build ===');

  // Build Jaspr Static Site (automatically bundles all web/ assets to build/jaspr)
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
