import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../shared/components/buttons/danger_button.dart';
import '../../../../shared/components/dialog.dart';
import '../../../../shared/components/snackbar.dart';
import '../../controllers/chat_app_controller.dart';
import '../../controllers/conversation_controller.dart';
import 'message/message_widget.dart';

class ConversationWidget extends StatelessWidget {
  final int conversationId;
  final chatAppController = Get.find<ChatAppController>();

  ConversationWidget({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConversationController>(
      id: 'conversation_$conversationId',
      tag: 'conversation_$conversationId',
      init: ConversationController(conversationId),
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                style: BorderStyle.solid,
                color: Get.theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 36 ,left: 24,right: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '话题#$conversationId - ${getTimeString(controller.conversation?.updatedTime)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Get.theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: '删除会话',
                      icon: SvgPicture.asset(
                        'assets/icons/delete.svg',
                        width: 14,
                        height: 14,
                        theme: SvgTheme(
                          currentColor: Get.theme.colorScheme.inverseSurface
                              .withOpacity(0.35),
                        ),
                      ),
                      onPressed: () {
                        removeConversation(conversationId);
                      },
                    ),
                  ],
                ),
              ),
              ...(controller.conversation?.messages ?? []).map((e) {
                late Key key;
                if (chatAppController.currentMessage != null &&
                    chatAppController.currentMessage!.msgId == e.msgId &&
                    chatAppController.currentMessageKey != null) {
                  key = chatAppController.currentMessageKey!;
                } else {
                  key = ValueKey('key_message_${e.msgId}');
                }

                return MessageWidget(
                  key: key,
                  msgId: e.msgId,
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  getTimeString(DateTime? time) {
    if (time == null) {
      return '';
    }

    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    if (time.day == DateTime.now().day) {
      // 如果是今天，显示时间，且时分不足两位数补0
      return timeStr;
    } else if (time.day == DateTime.now().day - 1) {
      return '昨天 $timeStr';
    } else if (time.day == DateTime.now().day - 2) {
      return '前天 $timeStr';
    } else if (time.year == DateTime.now().year) {
      return '${time.month}月${time.day}日 $timeStr';
    } else {
      return '${time.year}年${time.month}月${time.day}日 $timeStr';
    }
  }

  /// 删除会话
  removeConversation(int conversationId) {
    final chatAppController = Get.find<ChatAppController>();
    final countConversation = chatAppController.topConversationIds.length +
        chatAppController.bottomConversationIds.length;
    if (countConversation <= 1) {
      snackbar('提示', '至少保留一个会话');
      return;
    }
    dialog(
      title: '删除会话',
      middleText: '确定要删除当前会话吗？',
      confirm: DangerButton(
        text: '删除',
        onPressed: () {
          chatAppController.removeConversation(conversationId);
          Get.back();
        },
      ),
    );
  }
}
