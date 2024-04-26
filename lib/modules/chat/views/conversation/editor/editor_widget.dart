import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controllers/chat_app_controller.dart';
import 'editor_toolbar.dart';

class EditorWidget extends StatelessWidget {
  const EditorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatAppController>(
      builder: (controller) {
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EditorToolbar(),
              RawKeyboardListener(
                focusNode: FocusNode(),
                onKey: (RawKeyEvent event) {
                  if (event is RawKeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter &&
                      !event.isAltPressed &&
                      !event.isControlPressed &&
                      !event.isMetaPressed &&
                      !event.isShiftPressed) {
                    controller.sendMessage();
                  }

                  // 判断是macos系统，同时按下了command键和enter键时，输入换行
                  // 其他组合键都会自动加上换行，只有command+enter不会
                  if (event is RawKeyUpEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter &&
                      event.isMetaPressed &&
                      Platform.isMacOS) {
                    controller.inputController.text += '\n';
                  }
                },
                child: TextField(
                  controller: controller.inputController,
                  focusNode: controller.inputFocusNode,
                  maxLines: 6,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    border: InputBorder.none,
                    hintText: '请输入问题。回车键发送，Alt/Opt+Enter换行。',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
