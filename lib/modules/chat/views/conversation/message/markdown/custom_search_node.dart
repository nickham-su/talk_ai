import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as m;

const tag = 'search_result';

/// 搜索渲染节点
class SearchNode extends SpanNode {
  final String value;
  final MarkdownConfig config;

  SearchNode({required this.value, required this.config});

  @override
  InlineSpan build() => TextSpan(
        text: value,
        style: parentStyle?.copyWith(
              color: Get.theme.colorScheme.inversePrimary,
              backgroundColor: Get.theme.colorScheme.primary,
            ) ??
            config.p.textStyle.copyWith(
                backgroundColor: Get.theme.colorScheme.inversePrimary),
      );
}

/// 搜索渲染节点生成器
SpanNodeGeneratorWithTag searchGeneratorWithTag = SpanNodeGeneratorWithTag(
    tag: tag,
    generator: (e, config, visitor) => SearchNode(
          value: e.attributes['value'] ?? '',
          config: config,
        ));

/// 搜索结果匹配语法
class SearchSyntax extends m.InlineSyntax {
  final String keyword;

  SearchSyntax(this.keyword) : super(keyword, caseSensitive: false);

  @override
  bool onMatch(m.InlineParser parser, Match match) {
    final value = match.input.substring(match.start, match.end);
    m.Element el = m.Element.withTag(tag);
    el.attributes['value'] = value;
    parser.addNode(el);
    return true;
  }
}
