import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../controllers/chat_app_controller.dart';

/// 编辑器工具栏
class EditorToolbar extends StatelessWidget {
  const EditorToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatAppController>(
      id: 'editor_toolbar',
      builder: (controller) {
        List<Widget> tools = [
          const AddButton(),
          const SearchButton(),
        ];
        
        if (controller.isSending) {
          tools.add(const StopButton());
        }

        return Container(
          padding: const EdgeInsets.only(left: 4, top: 8),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Get.theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: tools,
          ),
        );
      },
    );
  }
}

/// 添加按钮
class AddButton extends StatelessWidget {
  const AddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 4),
      child: IconButton(
        visualDensity: VisualDensity.compact,
        tooltip: '开始新会话',
        icon: SvgPicture.asset(
          'assets/icons/add.svg',
          width: 22,
          height: 22,
          theme: SvgTheme(
            currentColor: Get.theme.colorScheme.inverseSurface,
          ),
        ),
        onPressed: () {
          final controller = Get.find<ChatAppController>();
          controller.createConversation();
          // 滚动到底部
          controller.scrollToBottom();
          // 聚焦输入框
          controller.inputFocusNode.requestFocus();
        },
      ),
    );
  }
}

/// 搜索按钮
class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 4),
      child: IconButton(
        visualDensity: VisualDensity.compact,
        tooltip: '搜索',
        icon: SvgPicture.asset(
          'assets/icons/search.svg',
          width: 18,
          height: 18,
          theme: SvgTheme(
            currentColor: Get.theme.colorScheme.inverseSurface,
          ),
        ),
        onPressed: () {
          final controller = Get.find<ChatAppController>();
          controller.toggleSearch();
        },
      ),
    );
  }
}

/// 停止按钮
class StopButton extends StatelessWidget {
  const StopButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 4),
      child: IconButton(
        visualDensity: VisualDensity.compact,
        tooltip: '停止',
        icon: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Container(
            width: 16,
            height: 16,
            color: Colors.red,
          ),
        ),
        onPressed: () {
          Future.delayed(const Duration(milliseconds: 100)).then((value) {
            final controller = Get.find<ChatAppController>();
            // 停止接收
            controller.stopReceive();
            // 聚焦输入框
            controller.inputFocusNode.requestFocus();
          });
        },
      ),
    );
  }
}
