import 'package:get/get.dart';

import '../../modules/chat/models/conversation_message_model.dart';
import '../../modules/chat/repositorys/message_repository.dart';
import '../models/message/message_model.dart';
import '../models/message/message_status.dart';

class MessageService extends GetxService {
  /// 缓存消息, key: msgId
  late Map<int, ConversationMessageModel> _cachedMessages;

  /// 消息列表缓存, key: conversationId
  late Map<int, List<ConversationMessageModel>> _cachedMessageList;

  @override
  void onInit() {
    _cachedMessages = {};
    _cachedMessageList = {};
    super.onInit();
  }

  /// 清除消息缓存
  void clearMessageCache(int msgId) {
    _cachedMessages.remove(msgId);
  }

  /// 清除消息列表缓存
  void clearMessageListCache(int conversationId) {
    _cachedMessageList.remove(conversationId);
  }

  /// 获取消息列表
  List<ConversationMessageModel> getMessageList(int conversationId) {
    if (_cachedMessageList.containsKey(conversationId)) {
      return _cachedMessageList[conversationId]!;
    }
    final messages = MessageRepository.getMessageList(conversationId);
    _cachedMessageList[conversationId] = messages;
    for (final message in messages) {
      _cachedMessages[message.msgId] = message;
    }
    return messages;
  }

  /// 获取消息
  ConversationMessageModel? getMessage(int msgId) {
    if (_cachedMessages.containsKey(msgId)) {
      return _cachedMessages[msgId]!;
    }
    final message = MessageRepository.getMessage(msgId);
    if (message != null) {
      _cachedMessages[msgId] = message;
    }
    return message;
  }

  /// 获取最后一条消息
  ConversationMessageModel? getLastMessage(int conversationId) {
    final messages = getMessageList(conversationId);
    if (messages.isEmpty) {
      return null;
    }
    return messages.last;
  }

  /// 搜索消息
  ConversationMessageModel? search({
    required int chatAppId,
    required String keyword,
    required int startMsgId,
    required bool isDesc,
  }) {
    final message = MessageRepository.search(
      chatAppId: chatAppId,
      keyword: keyword,
      startMsgId: startMsgId,
      isDesc: isDesc,
    );
    if (message != null) {
      _cachedMessages[message.msgId] = message;
    }
    return message;
  }

  /// 插入消息
  ConversationMessageModel insertMessage({
    required int chatAppId,
    required int conversationId,
    required MessageRole role,
    required String content,
    required MessageStatus status,
    int llmId = 0,
    String llmName = '',
    int generateId = 0,
  }) {
    // 删除消息列表缓存
    clearMessageListCache(conversationId);
    // 插入消息
    final message = MessageRepository.insertMessage(
      chatAppId: chatAppId,
      conversationId: conversationId,
      role: role,
      content: content,
      status: status,
      llmId: llmId,
      llmName: llmName,
      generateId: generateId,
    );
    _cachedMessages[message.msgId] = message;
    return message;
  }

  /// 更新消息
  void updateMessage({
    required int msgId,
    String? content,
    MessageStatus? status,
    int? llmId,
    String? llmName,
    int? generateId,
  }) {
    if (content == null &&
        status == null &&
        llmId == null &&
        llmName == null &&
        generateId == null) {
      return;
    }
    // 删除消息缓存
    clearMessageCache(msgId);
    // 更新消息
    MessageRepository.updateMessage(
      msgId: msgId,
      content: content,
      status: status,
      llmId: llmId,
      llmName: llmName,
      generateId: generateId,
    );
  }

  /// 删除消息
  void deleteMessage({
    int? msgId,
    int? conversationId,
    int? chatAppId,
  }) {
    if (msgId == null && conversationId == null && chatAppId == null) {
      throw ArgumentError('msgId, conversationId, chatAppId不能同时为空');
    }
    if (msgId != null) {
      // 删除消息缓存
      clearMessageCache(msgId);
    } else if (conversationId != null) {
      final messages = getMessageList(conversationId);
      for (final message in messages) {
        _cachedMessages.remove(message.msgId);
      }
      // 删除消息列表缓存
      clearMessageListCache(conversationId);
    } else if (chatAppId != null) {
      // 删除全部缓存，重新获取
      _cachedMessages.clear();
      _cachedMessageList.clear();
    }
    // 从数据库删除消息
    MessageRepository.deleteMessage(
      msgId: msgId,
      conversationId: conversationId,
      chatAppId: chatAppId,
    );
  }
}
