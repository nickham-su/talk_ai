import 'package:TalkAI/shared/models/message/message_status.dart';
import 'package:get/get.dart';

import '../../../shared/models/event_queue/event_listener.dart';
import '../../../shared/models/message/message_model.dart';
import '../../../shared/services/conversation_service.dart';
import '../../../shared/services/message_service.dart';
import '../models/conversation_message_model.dart';
import '../models/conversation_model.dart';
import '../repositorys/conversation_repository.dart';

class ConversationController extends GetxController {
  /// 会话id
  final int conversationId;

  /// 会话对象
  ConversationModel? conversation;

  /// 会话服务
  final conversationService = Get.find<ConversationService>();

  /// 消息服务
  final messageService = Get.find<MessageService>();

  /// 消息列表更新监听器
  late EventListener updateMessageListListener;

  ConversationController(this.conversationId);

  @override
  void onInit() {
    conversation = conversationService.getConversation(conversationId);
    // 监听消息列表更新
    updateMessageListListener =
        messageService.listenMessageIdsChange(conversationId, () {
      refreshConversation();
    });
    super.onInit();
  }

  @override
  void onClose() {
    // 移除监听
    updateMessageListListener.cancel();
    super.onClose();
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
