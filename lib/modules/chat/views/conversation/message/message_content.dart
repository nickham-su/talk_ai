import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../shared/models/message/message_status.dart';
import '../../../../../shared/models/message/message_model.dart';
import '../../../../../shared/services/generate_message_service.dart';
import '../../../models/conversation_message_model.dart';
import 'components/animated_ball.dart';
import 'components/constrained_widget.dart';
import 'markdown/markdown_content_widget.dart';
import 'message_toolbar.dart';

class MessageContent extends StatelessWidget {
  final ConversationMessageModel message;

  const MessageContent({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    late String roleName; // 角色名称
    if (message.role == MessageRole.user) {
      roleName = '我';
    } else if (message.role == MessageRole.assistant) {
      roleName = '助手  ${message.llmName}';
    } else {
      roleName = '助理设定';
    }

    // 查询失败原因
    final generateList =
        Get.find<GenerateMessageService>().getMessages(message.msgId);
    final String? error = generateList
        .firstWhereOrNull((e) => e.generateId == message.generateId)
        ?.error;
    final errorText =
        error != null && error.isNotEmpty ? '发送失败：\n$error' : '发送失败';

    // 消息内容
    final content =
        message.role == MessageRole.system && message.content.isEmpty
            ? '我是您的助理，请问有什么可以帮您？'
            : message.content;

    return GetBuilder<MessageContentController>(
      init: MessageContentController(),
      builder: (controller) {
        late Widget contentWidget;
        if (message.role == MessageRole.system) {
          contentWidget = ConstrainedWidget(
            child: getTextContent(
              content,
              fontSize: 14,
              color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
            ),
          );
        } else if (controller.showMarkdown) {
          contentWidget = MarkdownContentWidget(content: content);
        } else {
          contentWidget = getTextContent(content);
        }

        return Container(
          padding: const EdgeInsets.only(left: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    roleName,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Get.theme.textTheme.bodyMedium?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                  message.role == MessageRole.assistant
                      ? getMarkdownToggle(
                          isMarkdown: controller.showMarkdown,
                          onMarkdown: controller.setMarkdown,
                          onOriginal: controller.setOriginal,
                        )
                      : SizedBox(),
                ],
              ),
              contentWidget,
              Visibility(
                visible: message.status == MessageStatus.unsent,
                child: Container(
                  padding: const EdgeInsets.only(top: 8),
                  child: const AnimatedBall(),
                ),
              ),
              Visibility(
                visible: message.status == MessageStatus.failed,
                child: Container(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: SelectableText(
                    errorText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Get.theme.colorScheme.error,
                    ),
                  ),
                ),
              ),
              MessageToolbar(message: message),
            ],
          ),
        );
      },
    );
  }

  getTextContent(String content, {double? fontSize, Color? color}) {
    return Container(
      padding: const EdgeInsets.only(top: 4),
      child: SelectionArea(
        child: Text(
          content,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w300,
            color: color ?? Get.theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  getMarkdownToggle({
    required bool isMarkdown,
    required void Function() onMarkdown,
    required void Function() onOriginal,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 32),
              padding:
                  const EdgeInsets.only(left: 8, right: 4, top: 0, bottom: 0),
              backgroundColor: isMarkdown
                  ? Get.theme.colorScheme.secondaryContainer
                  : Get.theme.colorScheme.secondaryContainer.withOpacity(0.5),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            onPressed: onMarkdown,
            child: Text(
              'Markdown',
              style: TextStyle(
                color: isMarkdown
                    ? Get.theme.colorScheme.primary
                    : Get.theme.colorScheme.primary.withOpacity(0.5),
                fontSize: 11,
                height: 1,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 32),
              padding:
                  const EdgeInsets.only(left: 4, right: 8, top: 0, bottom: 0),
              backgroundColor: isMarkdown
                  ? Get.theme.colorScheme.secondaryContainer.withOpacity(0.5)
                  : Get.theme.colorScheme.secondaryContainer,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
            onPressed: onOriginal,
            child: Text(
              '原文',
              style: TextStyle(
                color: isMarkdown
                    ? Get.theme.colorScheme.primary.withOpacity(0.5)
                    : Get.theme.colorScheme.primary,
                fontSize: 11,
                height: 1,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageContentController extends GetxController {
  bool showMarkdown = true;

  void setMarkdown() {
    showMarkdown = true;
    update();
  }

  void setOriginal() {
    showMarkdown = false;
    update();
  }
}
