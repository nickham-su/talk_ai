import 'package:talk_ai/modules/chat/views/conversation/search/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controllers/chat_app_controller.dart';
import 'editor_quote_message.dart';
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
              const EditorQuoteMessage(),
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
