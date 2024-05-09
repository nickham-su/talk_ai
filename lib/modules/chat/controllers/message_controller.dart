import 'package:TalkAI/shared/models/message/message_status.dart';
import 'package:get/get.dart';

import '../../../shared/models/event_queue/event_listener.dart';
import '../../../shared/models/message/generated_message.dart';
import '../../../shared/services/generate_message_service.dart';
import '../../../shared/services/message_service.dart';
import '../models/conversation_message_model.dart';
import '../repositorys/message_repository.dart';

class MessageController extends GetxController {
  /// 生成消息服务
  final generateService = Get.find<GenerateMessageService>();

  /// 消息服务
  final messageService = Get.find<MessageService>();

  /// 消息ID
  final int msgId;

  /// 消息对象
  ConversationMessageModel? message;

  /// 监听消息更新ID
  late EventListener updateMessageListener;

  /// 监听生成列表更新ID
  late EventListener updateGenerateListListener;

  List<GeneratedMessage> get generateMessages =>
      generateService.getMessages(msgId);

  MessageController(this.msgId);

  @override
  void onInit() {
    super.onInit();
    // 监听消息更新
    updateMessageListener =
        messageService.listenMessageChange(msgId, (message) {
      refreshMessage();
    });

    // 监听生成列表更新
    updateGenerateListListener =
        generateService.listenUpdateGenerateList(msgId, (messages) {
      refreshMessage();
    });
    // 刷新消息
    refreshMessage(init: true);
  }

  @override
  void dispose() {
    // 移除监听
    updateMessageListener.cancel();
    updateGenerateListListener.cancel();
    super.dispose();
  }

  /// 已监听的生成id
  int listenGenerateId = 0;

  /// 刷新消息
  void refreshMessage({bool init = false}) {
    final newMessage = messageService.getMessage(msgId);
    if (newMessage == null) {
      return;
    }

    // 如果generateId改变，则添加监听
    if (generateService.isGenerating &&
        newMessage.generateId == generateService.currentGenerateId &&
        newMessage.generateId != listenGenerateId) {
      listenGenerateId = newMessage.generateId;
      generateService.listenGenerate(listenGenerateId, (event) {
        switch (event.type) {
          case GenerateEventType.generate:
            refreshMessage();
            break;
          default:
            listenGenerateId = 0;
            refreshMessage();
            break;
        }
      });
    }

    message = newMessage;
    if (!init) {
      update(['message_$msgId']);
    }
  }
}
