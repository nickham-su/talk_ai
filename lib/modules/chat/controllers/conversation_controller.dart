import 'package:get/get.dart';

import '../models/conversation_model.dart';
import '../repositorys/conversation_repository.dart';

class ConversationController extends GetxController {
  final int conversationId;
  ConversationModel? conversation;

  ConversationController(this.conversationId);

  @override
  void onInit() {
    super.onInit();
    conversation = ConversationRepository.getConversation(conversationId);
  }

  /// 刷新会话
  void refreshConversation() {
    conversation = ConversationRepository.getConversation(conversationId);
    update(['conversation_$conversationId']);
  }
}
