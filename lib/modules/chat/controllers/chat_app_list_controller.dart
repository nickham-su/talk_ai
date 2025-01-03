import 'dart:typed_data';

import 'package:TalkAI/modules/chat/controllers/editor_controller.dart';
import 'package:TalkAI/modules/chat/repositorys/chat_app_repository.dart';
import 'package:TalkAI/shared/models/message/message_model.dart';
import 'package:get/get.dart';

import '../../../routes.dart';
import '../../../shared/components/snackbar.dart';
import '../../../shared/repositories/generated_message_repository.dart';
import '../../../shared/services/conversation_service.dart';
import '../../../shared/services/llm_service.dart';
import '../../../shared/services/message_service.dart';
import '../../sync/controllers/sync_controller.dart';
import '../models/chat_app_model.dart';
import '../views/app_list/chat_app_setting_dialog.dart';
import 'chat_app_controller.dart';

class ChatAppListController extends GetxController {
  /// 会话服务
  final conversationService = Get.find<ConversationService>();

  /// 消息服务
  final messageService = Get.find<MessageService>();

  /// 数据同步控制器
  final syncController = Get.find<SyncController>();

  /// 聊天App列表
  final chatAppList = RxList<ChatAppModel>([]);

  /// 当前选中的聊天App的index
  final currentChatAppId = RxInt(-1);

  ChatAppModel? get currentChatApp => chatAppList.firstWhereOrNull(
      (element) => element.chatAppId == currentChatAppId.value);

  /// 会话控制器
  final chatAppController = Get.find<ChatAppController>();

  /// 筛选文本
  final filterText = ''.obs;

  /// 筛选后的聊天App列表，不区分大小写
  List<ChatAppModel> get filteredChatAppList {
    final filter = filterText.value.trim().toLowerCase();
    if (filter.isEmpty) return chatAppList;

    final nameSet = chatAppList
        .where((element) => element.name.toLowerCase().contains(filter))
        .toSet();
    final promptSet = chatAppList
        .where((element) => element.prompt.toLowerCase().contains(filter))
        .toSet();
    return nameSet.union(promptSet).toList();
  }

  @override
  void onInit() async {
    super.onInit();
    refreshChatApps();
    if (chatAppList.isNotEmpty) {
      /// 获取最后一次使用的聊天App
      ChatAppModel? lastUseChatApp;
      for (final chatApp in chatAppList) {
        if (lastUseChatApp == null ||
            chatApp.lastUseTime.isAfter(lastUseChatApp.lastUseTime)) {
          lastUseChatApp = chatApp;
        }
      }
      selectChatApp(lastUseChatApp!.chatAppId);
    }
  }

  /// 改变列表选项
  void selectChatApp(int chatAppId) {
    currentChatAppId.value = chatAppId;
    chatAppController.setChatApp(currentChatApp);
    Get.find<EditorController>().focus();
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
        barrierDismissible: false,
      );
    }
  }

  /// 添加聊天App
  void addChatApp({
    required String name,
    required String prompt,
    required double temperature,
    required int llmId,
    required bool multipleRound, // 是否多轮对话
    Uint8List? profilePicture,
  }) {
    final app = ChatAppRepository.insert(
      name: name,
      prompt: prompt,
      temperature: temperature,
      llmId: llmId,
      multipleRound: multipleRound,
      profilePicture: profilePicture,
    );
    refreshChatApps();
    selectChatApp(app.chatAppId);
    // 同步数据
    syncController.delaySync();
  }

  /// 更新聊天App
  void updateChatApp({
    required int chatAppId,
    required String name,
    required String prompt,
    required double temperature,
    required int llmId,
    required bool multipleRound,
    Uint8List? profilePicture,
  }) async {
    ChatAppRepository.update(
      chatAppId: chatAppId,
      name: name,
      prompt: prompt,
      temperature: temperature,
      llmId: llmId,
      multipleRound: multipleRound,
      profilePicture: profilePicture,
    );
    refreshChatApps();
    // 如果最后一个会话只有一条系统消息，则更新助理设定
    final conversationService = Get.find<ConversationService>();
    final messageService = Get.find<MessageService>();
    final lastConversationId =
        await conversationService.getLastConversationId(chatAppId);
    if (lastConversationId != null) {
      final lastMessage = messageService.getLastMessage(lastConversationId);
      if (lastMessage != null && lastMessage.role == MessageRole.system) {
        messageService.updateMessage(
          msgId: lastMessage.msgId,
          content: prompt,
        );
      }
    }

    selectChatApp(chatAppId);
    // 同步数据
    syncController.delaySync();
  }

  /// 删除聊天App
  void deleteChatApp(int id) async {
    ChatAppRepository.delete(id);
    await conversationService.deleteConversation(chatAppId: id);
    messageService.deleteMessage(chatAppId: id);
    GeneratedMessageRepository.deleteByChatAppId(id);
    refreshChatApps();
    selectChatApp(-1);
    // 同步数据
    syncController.delaySync();
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
