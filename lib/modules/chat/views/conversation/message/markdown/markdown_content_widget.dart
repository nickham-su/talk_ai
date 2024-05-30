import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as m;

import '../../../../controllers/chat_app_controller.dart';
import 'image/custom_image_syntax.dart';
import 'pre_wrapper_widget.dart';
import 'custom_search_node.dart';
import 'image/img_builder.dart';

/// Markdown组件
class MarkdownContentWidget extends StatelessWidget {
  final String content;

  const MarkdownContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatAppController>(
      builder: (ChatAppController controller) {
        // 搜索结果规则
        List<m.InlineSyntax> inlineSyntaxList = [CustomImageSyntax()];
        if (controller.searchKeyword.isNotEmpty) {
          inlineSyntaxList.add(SearchSyntax(controller.searchKeyword));
        }

        /// Markdown配置
        MarkdownConfig markdownConfig = Get.isDarkMode
            ? MarkdownConfig.darkConfig.copy(configs: [
                PreConfig.darkConfig.copy(wrapper: preWrapper),
                const ImgConfig(builder: imgBuilder),
                CodeConfig(
                  // 处理行内代码块，拖选时背景色显示不正常的问题
                  style: TextStyle(
                      backgroundColor: Color(0xffaaaaaa).withOpacity(0.4)),
                ),
              ])
            : MarkdownConfig.defaultConfig.copy(configs: [
                const PreConfig().copy(wrapper: preWrapper),
                const ImgConfig(builder: imgBuilder),
                CodeConfig(
                  style: TextStyle(
                      backgroundColor: Color(0xffdae5f1).withOpacity(0.4)),
                ),
              ]);

        return MarkdownBlock(
          data: content,
          config: markdownConfig,
          selectable: true,
          generator: MarkdownGenerator(
            inlineSyntaxList: inlineSyntaxList,
            generators: [searchGeneratorWithTag],
          ),
        );
      },
    );
  }
}
