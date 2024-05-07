import 'package:get/get.dart';

import '../../../shared/services/conversation_service.dart';
import '../models/conversation_model.dart';
import '../repositorys/conversation_repository.dart';

class ConversationController extends GetxController {
  final int conversationId;
  ConversationModel? conversation;

  final conversationService = Get.find<ConversationService>();

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
}
