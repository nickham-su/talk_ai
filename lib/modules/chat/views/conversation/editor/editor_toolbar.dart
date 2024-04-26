import 'dart:math';

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
          getDivider(),
          const UpButton(),
          const DownButton(),
          const BottomButton(),
        ];

        if (controller.isSending) {
          tools.add(getDivider());
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

/// 分割线
Widget getDivider() {
  return Container(
    width: 1,
    height: 24,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    color: Get.theme.colorScheme.inverseSurface.withOpacity(0.3),
  );
}

/// 添加按钮
class AddButton extends StatelessWidget {
  const AddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
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
      padding: const EdgeInsets.symmetric(horizontal: 2),
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
      padding: const EdgeInsets.symmetric(horizontal: 2),
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

/// 上一个会话按钮
class UpButton extends StatelessWidget {
  const UpButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: IconButton(
        visualDensity: VisualDensity.compact,
        tooltip: '上一个会话',
        icon: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationZ(pi),
          child: SvgPicture.asset(
            'assets/icons/arrow/down.svg',
            width: 18,
            height: 18,
            theme: SvgTheme(
              currentColor: Get.theme.colorScheme.inverseSurface,
            ),
          ),
        ),
        onPressed: () {
          final controller = Get.find<ChatAppController>();
          controller.scrollToPreviousConversation();
          controller.inputFocusNode.requestFocus();
        },
      ),
    );
  }
}

/// 下一个会话按钮
class DownButton extends StatelessWidget {
  const DownButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: IconButton(
        visualDensity: VisualDensity.compact,
        tooltip: '下一个会话',
        icon: SvgPicture.asset(
          'assets/icons/arrow/down.svg',
          width: 18,
          height: 18,
          theme: SvgTheme(
            currentColor: Get.theme.colorScheme.inverseSurface,
          ),
        ),
        onPressed: () {
          final controller = Get.find<ChatAppController>();
          controller.scrollToNextConversation();
          controller.inputFocusNode.requestFocus();
        },
      ),
    );
  }
}

/// 到底部按钮
class BottomButton extends StatelessWidget {
  const BottomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: IconButton(
        visualDensity: VisualDensity.compact,
        tooltip: '到底部',
        icon: SvgPicture.asset(
          'assets/icons/arrow/bottom.svg',
          width: 18,
          height: 18,
          theme: SvgTheme(
            currentColor: Get.theme.colorScheme.inverseSurface,
          ),
        ),
        onPressed: () {
          final controller = Get.find<ChatAppController>();
          controller.scrollToBottom();
          controller.inputFocusNode.requestFocus();
        },
      ),
    );
  }
}
