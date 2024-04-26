import 'package:TalkAI/modules/chat/repositorys/chat_app_repository.dart';
import 'package:TalkAI/shared/models/message/message_model.dart';
import 'package:get/get.dart';

import '../../../routes.dart';
import '../../../shared/components/snackbar.dart';
import '../../../shared/repositories/generated_message_repository.dart';
import '../../../shared/services/llm_service.dart';
import '../models/chat_app_model.dart';
import '../repositorys/conversation_repository.dart';
import '../repositorys/message_repository.dart';
import '../views/app_list/chat_app_setting_dialog.dart';
import 'chat_app_controller.dart';

class ChatAppListController extends GetxController {
  /// 聊天App列表
  final chatAppList = RxList<ChatAppModel>([]);

  /// 当前选中的聊天App的index
  final currentChatAppId = RxInt(-1);

  ChatAppModel? get currentChatApp => chatAppList.firstWhereOrNull(
      (element) => element.chatAppId == currentChatAppId.value);

  /// 会话控制器
  final chatAppController = Get.find<ChatAppController>();

  @override
  void onInit() async {
    super.onInit();
    refreshChatApps();
    if (chatAppList.isNotEmpty) {
      selectChatApp(chatAppList.first.chatAppId);
    }
  }

  /// 改变列表选项
  void selectChatApp(int chatAppId) {
    currentChatAppId.value = chatAppId;
    chatAppController.setChatApp(currentChatApp);
  }

  /// 刷新聊天App列表
  void refreshChatApps() {
    chatAppList.clear();
    List<ChatAppModel> chatApps = ChatAppRepository.queryAll();
    chatAppList.assignAll(chatApps);
  }

  /// 显示聊天App设置对话框
  void showChatAppSettingDialog() {
    if (Get.find<LLMService>().getLLMList().isEmpty) {
      snackbar('提示', '请先添加一个模型，再使用助理。');
      Get.offNamed(Routes.llm);
    } else {
      Get.dialog(
        ChatAppSettingDialog(),
        barrierDismissible: true,
      );
    }
  }

  /// 添加聊天App
  void addChatApp({
    required String name,
    required String prompt,
    required int llmId,
    required double temperature,
    required double topP,
  }) {
    final app = ChatAppRepository.insert(
      name: name,
      prompt: prompt,
      llmId: llmId,
      temperature: temperature,
      topP: topP,
    );
    refreshChatApps();
    selectChatApp(app.chatAppId);
  }

  /// 更新聊天App
  void updateChatApp({
    required int chatAppId,
    required String name,
    required String prompt,
    required int llmId,
    required double temperature,
    required double topP,
  }) {
    ChatAppRepository.update(
      chatAppId: chatAppId,
      name: name,
      prompt: prompt,
      llmId: llmId,
      temperature: temperature,
      topP: topP,
    );
    refreshChatApps();
    // 如果最后一个会话只有一条系统消息，则更新助理设定
    final conversation = ConversationRepository.getLastConversation(chatAppId);
    if (conversation != null &&
        conversation.messages.length == 1 &&
        conversation.messages.first.role == MessageRole.system) {
      MessageRepository.updateMessage(
        msgId: conversation.messages.first.msgId,
        content: prompt,
      );
    }

    selectChatApp(chatAppId);
  }

  /// 删除聊天App
  void deleteChatApp(int id) {
    ChatAppRepository.delete(id);
    ConversationRepository.deleteConversation(chatAppId: id);
    MessageRepository.deleteMessage(chatAppId: id);
    GeneratedMessageRepository.deleteByChatAppId(id);
    refreshChatApps();
    selectChatApp(-1);
  }

  /// 获取聊天App
  ChatAppModel? getChatApp(int chatAppId) {
    return chatAppList
        .firstWhereOrNull((element) => element.chatAppId == chatAppId);
  }

  /// 记录聊天App的最后一次使用时间
  void recordLastUseTime(int chatAppId) {
    ChatAppRepository.recordLastUseTime(chatAppId);
    refreshChatApps();
  }

  /// 切换置顶状态
  void toggleTop(int chatAppId) {
    final chatApp = getChatApp(chatAppId);
    if (chatApp == null) return;
    if (chatApp.toppingTime.millisecondsSinceEpoch == 0) {
      ChatAppRepository.top(chatAppId);
    } else {
      ChatAppRepository.unTop(chatAppId);
    }
    refreshChatApps();
  }
}
