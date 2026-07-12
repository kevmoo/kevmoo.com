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

  final frontmatterRegExp = RegExp(
    r'^---[ \t]*[\r\n]+([\s\S]*?)[\r\n]+---[ \t]*[\r\n]*([\s\S]*)$',
  );
  final match = frontmatterRegExp.firstMatch(content);
  if (match == null) {
    throw const FormatException(
      'Malformed frontmatter (missing closing --- on its own line)',
    );
  }

  final frontmatterString = match.group(1) ?? '';
  final bodyMarkdown = (match.group(2) ?? '').trim();

  final yaml = loadYaml(frontmatterString);
  final YamlMap yamlMap;
  if (yaml == null) {
    yamlMap = YamlMap.wrap(const {});
  } else if (yaml is YamlMap) {
    yamlMap = yaml;
  } else {
    throw const FormatException('Frontmatter is not a key-value map');
  }

  return ParsedContent(
    frontmatter: yamlMap,
    bodyMarkdown: bodyMarkdown,
    blockSyntaxes: blockSyntaxes,
  );
}
