import 'package:TalkAI/modules/chat/views/conversation/conversation_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/components/layout/models/layout_menu_type.dart';
import '../../../shared/components/layout/views/layout.dart';
import '../controllers/chat_app_list_controller.dart';
import 'app_list/app_list.dart';

class ChatPage extends GetView<ChatAppListController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Layout(
      currentMenu: LayoutMenuType.chat,
      child: Row(
        children: [
          AppList(),
          Obx(() => Expanded(
              child: Container(
                  color: Get.theme.colorScheme.background,
                  child: controller.currentChatApp == null
                      ? const EmptyPage()
                      : const ConversationPage()))),
        ],
      ),
    );
  }
}

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '请先选择助理，再进行聊天',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Get.theme.colorScheme.secondary.withOpacity(0.5),
          ),
        )
      ],
    );
  }
}
