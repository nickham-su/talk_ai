import 'dart:typed_data';

import 'package:TalkAI/modules/chat/controllers/message_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../shared/models/message/message_model.dart';
import '../../../controllers/chat_app_controller.dart';
import '../../../../../shared/models/message/conversation_message_model.dart';
import 'message_content.dart';
import 'message_pagination.dart';

class MessageWidget extends StatelessWidget {
  final int msgId;

  const MessageWidget({super.key, required this.msgId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(
      id: 'message_$msgId',
      tag: 'message_$msgId',
      init: MessageController(msgId),
      builder: (controller) {
        final message = controller.message;
        if (message == null) return const SizedBox();

        // 显示搜索结果
        final chatAppController = Get.find<ChatAppController>();
        Color bgColor = chatAppController.currentMessage?.msgId == msgId
            ? Get.theme.colorScheme.surfaceVariant
            : Colors.transparent;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetBuilder<ChatAppController>(
                builder: (controller) {
                  return getIcon(
                      message.role, controller.chatApp?.profilePicture);
                },
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MessageContent(
                      key: ValueKey('key_generate_${message.generateId}'),
                      message: message,
                    ),
                    Visibility(
                      visible: message.role == MessageRole.assistant &&
                          controller.generateMessages.length > 1,
                      child: MessagePagination(message: message),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 获取头像
  Widget getIcon(MessageRole role, Uint8List? iconImg) {
    late String iconSvg; // 默认图片svg
    if (role == MessageRole.user) {
      iconSvg = 'assets/icons/user.svg';
    } else if (role == MessageRole.assistant) {
      iconSvg = 'assets/icons/assistant.svg';
    } else {
      iconSvg = 'assets/icons/build.svg';
    }

    late Color iconColor; // 默认图标颜色
    if (role == MessageRole.user) {
      iconColor = Get.theme.colorScheme.tertiaryContainer;
    } else if (role == MessageRole.assistant) {
      iconColor = Get.theme.colorScheme.primaryContainer;
    } else {
      iconColor = Get.theme.colorScheme.outlineVariant;
    }

    Widget picture = role == MessageRole.assistant && iconImg != null
        ? Image.memory(iconImg, fit: BoxFit.cover)
        : SvgPicture.asset(iconSvg,
            width: 22,
            height: 22,
            theme: SvgTheme(
              currentColor: Get.theme.colorScheme.inverseSurface,
            ));

    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: role == MessageRole.assistant && iconImg != null
            ? Border.all(
                color: Get.theme.colorScheme.primary,
                width: 2,
              )
            : null,
        color: iconColor,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: picture,
      ),
    );
  }
}
