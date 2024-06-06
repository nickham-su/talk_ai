import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../controllers/chat_app_controller.dart';
import 'llm_picker.dart';

/// 编辑器工具栏
class EditorToolbar extends StatelessWidget {
  const EditorToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatAppController>(
      id: 'editor_toolbar',
      builder: (controller) {
        List<Widget> tools = [
          const LLMPicker(),
          const SizedBox(width: 8),
          const AddButton(),
          const SearchButton(),
          getDivider(),
          const UpButton(),
          const BottomButton(),
        ];

        if (controller.isSending) {
          tools.add(getDivider());
          tools.add(const StopButton());
        }

        return Container(
          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 4),
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
    height: 20,
    margin: const EdgeInsets.symmetric(horizontal: 12),
    color: Get.theme.colorScheme.outlineVariant.withOpacity(0.5),
  );
}

/// 添加按钮
class AddButton extends StatelessWidget {
  const AddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        padding: const EdgeInsets.all(0),
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size(32, 32)),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        tooltip: '开始新话题',
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
          controller.addConversation();
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
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        padding: const EdgeInsets.all(0),
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size(32, 32)),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        tooltip: '搜索',
        icon: SvgPicture.asset(
          'assets/icons/search.svg',
          width: 17,
          height: 17,
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
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        padding: const EdgeInsets.all(0),
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size(32, 32)),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        tooltip: '停止',
        icon: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Container(
            width: 14,
            height: 14,
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
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        padding: const EdgeInsets.all(0),
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size(32, 32)),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        tooltip: '上一个会话',
        icon: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationZ(pi),
          child: SvgPicture.asset(
            'assets/icons/arrow/down.svg',
            width: 20,
            height: 20,
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

/// 到底部按钮
class BottomButton extends StatelessWidget {
  const BottomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        padding: const EdgeInsets.all(0),
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size(32, 32)),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
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
