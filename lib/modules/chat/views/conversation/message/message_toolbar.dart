import 'package:TalkAI/shared/services/llm_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../shared/models/llm/llm_model.dart';
import '../../../../../shared/models/message/message_status.dart';
import '../../../../../shared/models/message/message_model.dart';
import '../../../../../shared/services/generate_message_service.dart';
import '../../../controllers/chat_app_controller.dart';
import '../../../models/conversation_message_model.dart';

/// 工具栏
class MessageToolbar extends StatelessWidget {
  final ConversationMessageModel message;

  const MessageToolbar({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.status == MessageStatus.failed) {
      return FailedToolbar(message: message);
    }

    if (message.role == MessageRole.user &&
        message.status == MessageStatus.completed) {
      return UserMessageToolbar(message: message);
    }

    if (message.role == MessageRole.assistant &&
        (message.status == MessageStatus.completed ||
            message.status == MessageStatus.cancel)) {
      return AssistantMessageToolbar(message: message);
    }

    if (message.status == MessageStatus.sending) {
      return const SizedBox(height: 32);
    }

    return const SizedBox();
  }
}

/// 发送失败工具栏
class FailedToolbar extends StatelessWidget {
  final ConversationMessageModel message;

  const FailedToolbar({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ToolbarIcon(
          icon: 'assets/icons/refresh.svg',
          tooltip: '重试',
          onPressed: () {
            regenerateMessage(message);
          },
        ),
      ],
    );
  }
}

/// 用户已发送消息工具栏
class UserMessageToolbar extends StatelessWidget {
  final ConversationMessageModel message;

  const UserMessageToolbar({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ToolbarIcon(
          icon: 'assets/icons/edit.svg',
          tooltip: '修改后，重新发送',
          onPressed: () {
            final controller = Get.find<ChatAppController>();
            controller.quote(message.msgId);
            controller.inputController.text = message.content;
          },
        ),
        ToolbarIcon(
          icon: 'assets/icons/delete.svg',
          tooltip: '删除',
          onPressed: () {
            Get.find<ChatAppController>().removeMessage(message.msgId);
          },
        ),
      ],
    );
  }
}

/// 助手已完成消息工具栏
class AssistantMessageToolbar extends StatelessWidget {
  final ConversationMessageModel message;

  const AssistantMessageToolbar({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final service = Get.find<GenerateMessageService>();
    final genMsgList = service.getMessages(message.msgId);
    final chatAppController = Get.find<ChatAppController>();

    final isLastMessage = chatAppController.isLastMessage(
      msgId: message.msgId,
      conversationId: message.conversationId,
    );

    return Row(
      children: [
        ToolbarIcon(
          icon: 'assets/icons/refresh.svg',
          tooltip: '更换模型、再答一次',
          onPressed: () {
            regenerateMessage(message);
          },
        ),
        Visibility(
          visible: genMsgList.length > 1,
          child: ToolbarIcon(
            icon: 'assets/icons/delete.svg',
            tooltip: '删除',
            onPressed: () {
              service.removeMessage(message.generateId);
              service.saveMessage(genMsgList.last.generateId);
            },
          ),
        ),
        Visibility(
          visible: !isLastMessage,
          child: ToolbarIcon(
            icon: 'assets/icons/arrow/arrowright_fill.svg',
            tooltip: '从这里，继续对话',
            onPressed: () {
              chatAppController.quote(message.msgId);
            },
          ),
        )
      ],
    );
  }
}

/// 工具栏图标
class ToolbarIcon extends StatelessWidget {
  final String icon;
  final String tooltip;
  final void Function() onPressed;

  const ToolbarIcon(
      {super.key,
      required this.icon,
      required this.tooltip,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      hoverColor: Get.theme.colorScheme.secondaryContainer.withOpacity(0.2),
      icon: SvgPicture.asset(
        icon,
        width: 14,
        height: 14,
        theme: SvgTheme(
          currentColor: Get.theme.colorScheme.inverseSurface.withOpacity(0.5),
        ),
      ),
      onPressed: () async {
        // 延迟 100 毫秒执行，让tooltip消失，不然会标签会卡在界面上
        await Future.delayed(const Duration(milliseconds: 100));
        onPressed();
      },
    );
  }
}

/// 再次生成消息
void regenerateMessage(ConversationMessageModel message) {
  List<LLM> llmList = Get.find<LLMService>().getLLMList();
  // llmList按照最后使用时间排序
  llmList.sort((a, b) => b.lastUseTime.compareTo(a.lastUseTime));

  Get.dialog(
    AlertDialog(
      title: const Text('选择模型'),
      content: SizedBox(
        width: Get.width / 2, // or whatever you need
        height: 200, // or whatever you need
        child: ListView.builder(
          itemCount: llmList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(llmList[index].name),
              onTap: () {
                Get.find<ChatAppController>().regenerateMessage(
                  msgId: message.msgId,
                  llmId: llmList[index].llmId,
                  generateId: message.status == MessageStatus.failed ||
                          message.status == MessageStatus.cancel
                      ? message.generateId
                      : null,
                );
                Get.back();
              },
            );
          },
        ),
      ),
    ),
  );
}
