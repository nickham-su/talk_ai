import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../shared/components/resizable_sidebar/resizable_sidebar_widget.dart';
import '../../../../../shared/components/snackbar.dart';
import '../../../../../shared/repositories/setting_repository.dart';
import '../../../controllers/chat_app_controller.dart';
import '../../../controllers/editor_controller.dart';
import 'editor_images.dart';
import 'editor_toolbar.dart';

class EditorWidget extends StatelessWidget {
  const EditorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditorController>(
      init: EditorController(),
      builder: (controller) {
        return ResizableSidebarWidget(
          tag: 'editor',
          resizeHeight: true,
          minHeight: 100,
          maxHeight: 600,
          initHeight: SettingRepository.getInputHeight(200),
          onHeightChanged: (double height) {
            SettingRepository.setInputHeight(height);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EditorToolbar(),
              const EditorImages(),
              Expanded(
                child: RawKeyboardListener(
                  focusNode: FocusNode(),
                  onKey: (RawKeyEvent event) async {
                    if (event is RawKeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.enter &&
                        !event.isAltPressed &&
                        !event.isControlPressed &&
                        !event.isMetaPressed &&
                        !event.isShiftPressed) {
                      final completeContent = await controller.onEnterKey();
                      if (completeContent != null) {
                        // 发送消息
                        try {
                          Get.find<ChatAppController>()
                              .sendMessage(completeContent);
                          controller
                            ..clearContent()
                            ..clearFiles();
                        } catch (e) {
                          snackbar('提示', e.toString());
                        }
                      }
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
                    maxLines: 100,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.only(left: 16, top: 8, bottom: 8),
                      border: InputBorder.none,
                      hintText: '请输入问题。Enter发送，Opt/Alt+Enter换行。',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
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
