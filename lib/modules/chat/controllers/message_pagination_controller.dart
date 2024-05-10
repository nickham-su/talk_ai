import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/components/snackbar.dart';
import '../../../shared/models/message/generated_message.dart';
import '../../../shared/services/generate_message_service.dart';
import '../../../shared/services/message_service.dart';
import 'chat_app_controller.dart';

class MessagePaginationController extends GetxController {
  final int msgId;

  /// 生成消息服务
  final generateService = Get.find<GenerateMessageService>();

  /// 消息服务
  final messageService = Get.find<MessageService>();

  /// 消息生成列表
  List<GeneratedMessage> get messages => generateService.getMessages(msgId);

  /// 序号
  List<int> get indexList => List.generate(messages.length, (i) => i);

  MessagePaginationController(this.msgId);

  /// 选择消息
  void selectMessage(int index) async {
    // 判断消息是否是最后一条消息
    final message = messages[index];
    final chatAppController = Get.find<ChatAppController>();
    final isLastMessage = chatAppController.isLastMessage(msgId: message.msgId);

    // 保存消息
    final generateId = message.generateId;
    final generatedMessage = generateService.getMessage(generateId);
    if (generatedMessage == null) {
      snackbar('提示', '操作失败');
      return;
    }
    messageService.updateMessage(
      msgId: generatedMessage.msgId,
      content: generatedMessage.content,
      status: generatedMessage.status,
      llmId: generatedMessage.llmId,
      llmName: generatedMessage.llmName,
      generateId: generatedMessage.generateId,
    );

    // 如果是最后一条消息，滚动到底部
    if (isLastMessage) {
      await WidgetsBinding.instance.endOfFrame;
      chatAppController.scrollToBottom(animate: true);
    }
  }
}
