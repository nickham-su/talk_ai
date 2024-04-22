import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/components/snackbar.dart';
import '../../../shared/models/message/generated_message.dart';
import '../../../shared/services/generate_message_service.dart';
import 'chat_app_controller.dart';

class MessagePaginationController extends GetxController {
  final int msgId;

  // 生成消息服务
  final GenerateMessageService service = Get.find<GenerateMessageService>();

  // 消息生成列表
  List<GeneratedMessage> get messages => service.getMessages(msgId);

  // 序号
  List<int> get indexList => List.generate(messages.length, (i) => i);

  MessagePaginationController(this.msgId);

  /// 选择消息
  void selectMessage(int index) async {
    if (service.isGenerating) {
      //显示提示信息
      snackbar('提示', '消息生成中，请稍后');
      return;
    }
    // 判断消息是否是最后一条消息
    final message = messages[index];
    final chatAppController = Get.find<ChatAppController>();
    final isLastMessage = chatAppController.isLastMessage(message.msgId);

    // 保存消息
    final generateId = message.generateId;
    service.saveMessage(generateId);

    // 如果是最后一条消息，滚动到底部
    if (isLastMessage) {
      await WidgetsBinding.instance.endOfFrame;
      chatAppController.scrollToBottom(animate: true);
    }
  }
}
