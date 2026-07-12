import 'dart:io';
import 'package:markdown/markdown.dart' as md;
import 'package:yaml/yaml.dart';

typedef ParsedContent = ({
  YamlMap frontmatter,
  String bodyMarkdown,
  String bodyHtml,
});

ParsedContent parseFrontmatterFile(
  File file, {
  List<md.BlockSyntax> blockSyntaxes = const [],
}) {
  final content = file.readAsStringSync();
  return parseFrontmatterString(content, blockSyntaxes: blockSyntaxes);
}

ParsedContent parseFrontmatterString(
  String content, {
  List<md.BlockSyntax> blockSyntaxes = const [],
}) {
  if (!content.startsWith('---')) {
    final bodyHtml = md.markdownToHtml(
      content,
      extensionSet: md.ExtensionSet.gitHubFlavored,
      blockSyntaxes: blockSyntaxes,
    );
    return (frontmatter: YamlMap(), bodyMarkdown: content, bodyHtml: bodyHtml);
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

  final bodyHtml = md.markdownToHtml(
    bodyMarkdown,
    extensionSet: md.ExtensionSet.gitHubFlavored,
    blockSyntaxes: blockSyntaxes,
  );

  return (frontmatter: yaml, bodyMarkdown: bodyMarkdown, bodyHtml: bodyHtml);
}
