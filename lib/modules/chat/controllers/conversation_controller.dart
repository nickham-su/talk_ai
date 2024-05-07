import 'package:get/get.dart';

import '../../../shared/services/conversation_service.dart';
import '../../../shared/services/message_service.dart';
import '../models/conversation_message_model.dart';
import '../models/conversation_model.dart';
import '../repositorys/conversation_repository.dart';

class ConversationController extends GetxController {
  final int conversationId;
  ConversationModel? conversation;

  /// 会话服务
  final conversationService = Get.find<ConversationService>();

  /// 消息服务
  final messageService = Get.find<MessageService>();

  ConversationController(this.conversationId);

  @override
  void onInit() {
    super.onInit();
    conversation = conversationService.getConversation(conversationId);
  }

  /// 刷新会话
  void refreshConversation() {
    conversation = conversationService.getConversation(conversationId);
    update(['conversation_$conversationId']);
  }

  /// 获取消息列表
  List<ConversationMessageModel> get messages {
    return messageService.getMessageList(conversationId);
  }
}
