import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:markdown_widget/widget/inlines/data_url_image.dart';

import '../../../../../../shared/repositories/setting_repository.dart';
import '../../../../controllers/chat_app_controller.dart';
import 'code_wrapper_widget.dart';
import 'custom_markdown_node.dart';
import 'image/img_builder.dart';
import 'image/network_image_widget.dart';

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
                PreConfig.darkConfig.copy(wrapper: codeWrapper),
                const ImgConfig(builder: imgBuilder),
              ])
            : MarkdownConfig.defaultConfig.copy(configs: [
                const PreConfig().copy(wrapper: codeWrapper),
                const ImgConfig(builder: imgBuilder),
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

/// 代码块包装器
Widget codeWrapper(Widget child, String text) {
  return CodeWrapperWidget(child, text);
}
