import 'dart:io';
import 'package:markdown/markdown.dart' as md;
import 'package:yaml/yaml.dart';

final _frontmatterStart = RegExp(r'^---[ \t]*\r?(?:\n|$)');
final _frontmatterDelimiter = RegExp(r'^---[ \t]*\r?$', multiLine: true);

class ParsedContent {
  final YamlMap frontmatter;
  final String bodyMarkdown;
  final List<md.BlockSyntax> blockSyntaxes;

  ParsedContent({
    required this.frontmatter,
    required this.bodyMarkdown,
    this.blockSyntaxes = const [],
  });

  late final String bodyHtml = md.markdownToHtml(
    bodyMarkdown,
    extensionSet: md.ExtensionSet.gitHubFlavored,
    blockSyntaxes: blockSyntaxes,
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
  if (!_frontmatterStart.hasMatch(content)) {
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

  final firstLineEnd = content.indexOf('\n');
  if (firstLineEnd == -1) {
    if (requireFrontmatter) {
      throw const FormatException(
        'Malformed frontmatter (missing closing --- on its own line)',
      );
    }
    return ParsedContent(
      frontmatter: YamlMap.wrap(const {}),
      bodyMarkdown: content,
      blockSyntaxes: blockSyntaxes,
    );
  }

  final matches = _frontmatterDelimiter.allMatches(content, firstLineEnd + 1);

  if (matches.isEmpty) {
    if (requireFrontmatter) {
      throw const FormatException(
        'Malformed frontmatter (missing closing --- on its own line)',
      );
    }
    return ParsedContent(
      frontmatter: YamlMap.wrap(const {}),
      bodyMarkdown: content,
      blockSyntaxes: blockSyntaxes,
    );
  }

  final closingMatch = matches.first;
  final frontmatterString = content.substring(
    firstLineEnd + 1,
    closingMatch.start,
  );
  final bodyMarkdown = content.substring(closingMatch.end).trim();

  try {
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
  } catch (e) {
    if (requireFrontmatter) {
      rethrow;
    }
    return ParsedContent(
      frontmatter: YamlMap.wrap(const {}),
      bodyMarkdown: content,
      blockSyntaxes: blockSyntaxes,
    );
  }
}
