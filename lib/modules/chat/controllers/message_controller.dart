import 'package:talk_ai/shared/models/message/message_status.dart';
import 'package:get/get.dart';

import '../../../shared/models/message/generated_message.dart';
import '../../../shared/services/generate_message_service.dart';
import '../models/conversation_message_model.dart';
import '../repositorys/message_repository.dart';

class MessageController extends GetxController {
  /// 生成消息服务
  final service = Get.find<GenerateMessageService>();

  /// 消息ID
  final int msgId;

  /// 消息对象
  ConversationMessageModel? message;

  /// 监听消息更新ID
  int updateMessageListenerId = 0;

  /// 监听生成列表更新ID
  int updateGenerateListListenerId = 0;

  List<GeneratedMessage> get generateMessages => service.getMessages(msgId);

  MessageController(this.msgId);

  @override
  void onInit() {
    super.onInit();
    // 监听消息更新
    updateMessageListenerId = service.listenUpdateMessage(msgId, () {
      refreshMessage();
    });
    // 监听生成列表更新
    updateGenerateListListenerId =
        service.listenUpdateGenerateList(msgId, (messages) {
      refreshMessage();
    });
    // 刷新消息
    refreshMessage(init: true);
  }

  @override
  void dispose() {
    // 移除监听
    service.removeListenUpdateMessage(msgId, updateMessageListenerId);
    service.removeListenUpdateGenerateList(msgId, updateGenerateListListenerId);
    super.dispose();
  }

  /// 已监听的生成id
  int listenGenerateId = 0;

  /// 刷新消息
  void refreshMessage({bool init = false}) {
    final newMessage = MessageRepository.getMessage(msgId);

    // 如果generateId改变，则添加监听
    if (service.isGenerating &&
        newMessage.generateId == service.currentGenerateId &&
        newMessage.generateId != listenGenerateId) {
      listenGenerateId = newMessage.generateId;
      service.listenGenerate(
        generateId: newMessage.generateId,
        onGenerate: (content) {
          refreshMessage();
        },
        onDone: () {
          listenGenerateId = 0;
          refreshMessage();
        },
        onError: (e) {
          listenGenerateId = 0;
          refreshMessage();
        },
      );
    }

    message = newMessage;
    if (!init) {
      update(['message_$msgId']);
    }
  }
}
