import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as m;

import '../../../../controllers/chat_app_controller.dart';
import 'code_wrapper_widget.dart';
import 'custom_markdown_node.dart';

/// Markdown组件
class MarkdownContentWidget extends StatelessWidget {
  final String content;
  final bool selectable;

  const MarkdownContentWidget(
      {super.key, required this.content, this.selectable = true});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatAppController>(
      builder: (ChatAppController controller) {
        // 搜索结果规则
        List<m.InlineSyntax> inlineSyntaxList = [];
        if (controller.searchKeyword.isNotEmpty) {
          inlineSyntaxList.add(SearchSyntax(controller.searchKeyword));
        }

        /// Markdown配置
        MarkdownConfig markdownConfig = Get.isDarkMode
            ? MarkdownConfig.darkConfig.copy(
                configs: [PreConfig.darkConfig.copy(wrapper: codeWrapper)])
            : MarkdownConfig.defaultConfig
                .copy(configs: [const PreConfig().copy(wrapper: codeWrapper)]);

        return MarkdownBlock(
          data: content,
          config: markdownConfig,
          selectable: selectable,
          generator: MarkdownGenerator(
            inlineSyntaxList: inlineSyntaxList,
            generators: [searchGeneratorWithTag],
          ),
        );
      },
    );
  }
}

/// 代码块包装器
Widget codeWrapper(Widget child, String text) {
  return CodeWrapperWidget(child, text);
}
