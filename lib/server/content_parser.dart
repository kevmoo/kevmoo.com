import 'dart:io';
import 'package:markdown/markdown.dart' as md;
import 'package:yaml/yaml.dart';

class ParsedContent {
  final YamlMap frontmatter;
  final String bodyMarkdown;
  final List<md.BlockSyntax> _blockSyntaxes;

  ParsedContent({
    required this.frontmatter,
    required this.bodyMarkdown,
    this._blockSyntaxes = const [],
  });

  late final String bodyHtml = md.markdownToHtml(
    bodyMarkdown,
    extensionSet: md.ExtensionSet.gitHubFlavored,
    blockSyntaxes: _blockSyntaxes,
  );
}

ParsedContent parseFrontmatterFile(
  File file, {
  List<md.BlockSyntax> blockSyntaxes = const [],
  bool requireFrontmatter = false,
}) {
  final content = file.readAsStringSync();
  return parseFrontmatterString(
    content,
    blockSyntaxes: blockSyntaxes,
    requireFrontmatter: requireFrontmatter,
  );
}

ParsedContent parseFrontmatterString(
  String content, {
  List<md.BlockSyntax> blockSyntaxes = const [],
  bool requireFrontmatter = false,
}) {
  if (!content.startsWith('---')) {
    if (requireFrontmatter) {
      throw const FormatException(
        'File does not start with frontmatter delimiter (---)',
      );
    }
    return ParsedContent(
      frontmatter: YamlMap.wrap(const {}),
      bodyMarkdown: content,
      blockSyntaxes: blockSyntaxes,
    );
  }

  final parts = content.split('---');
  if (parts.length < 3) {
    throw const FormatException('Malformed frontmatter (missing closing ---)');
  }

  final frontmatterString = parts[1];
  final bodyMarkdown = parts.sublist(2).join('---').trim();

  final yaml = loadYaml(frontmatterString);
  if (yaml is! YamlMap) {
    throw const FormatException('Frontmatter is not a key-value map');
  }

  return ParsedContent(
    frontmatter: yaml,
    bodyMarkdown: bodyMarkdown,
    blockSyntaxes: blockSyntaxes,
  );
}
