import 'package:TalkAI/modules/chat/controllers/message_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../shared/models/message/message_model.dart';
import '../../../controllers/chat_app_controller.dart';
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
        late String iconFile; // icon文件
        late Color iconColor; // icon颜色
        if (controller.message?.role == MessageRole.user) {
          iconFile = 'assets/icons/user.svg';
          iconColor = Get.theme.colorScheme.tertiaryContainer;
        } else if (controller.message?.role == MessageRole.assistant) {
          iconFile = 'assets/icons/assistant.svg';
          iconColor = Get.theme.colorScheme.primaryContainer;
        } else {
          iconFile = 'assets/icons/build.svg';
          iconColor = Get.theme.colorScheme.outlineVariant;
        }

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
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(iconFile,
                    width: 20,
                    height: 20,
                    theme: SvgTheme(
                      currentColor: Get.theme.colorScheme.inverseSurface,
                    )),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MessageContent(
                      key: ValueKey(
                          'key_generate_${controller.message!.generateId}'),
                      message: controller.message!,
                    ),
                    Visibility(
                      visible:
                          controller.message!.role == MessageRole.assistant &&
                              controller.generateMessages.length > 1,
                      child: MessagePagination(message: controller.message!),
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
}
