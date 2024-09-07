import 'package:get/get.dart';

import '../models/message/conversation_message_model.dart';
import '../repositories/message_repository.dart';
import '../models/event_queue/event.dart';
import '../models/event_queue/event_listener.dart';
import '../models/event_queue/event_queue.dart';
import '../models/message/message_model.dart';
import '../models/message/message_status.dart';
import 'conversation_service.dart';

class MessageService extends GetxService {
  /// 缓存消息, key: msgId
  late Map<int, ConversationMessageModel> _cachedMessages;

  /// 消息id列表缓存, key: conversationId
  late Map<int, List<int>> _cachedMessageIds;

  /// 消息变更事件队列，channel: msgId
  final messageChangeEventQueue = EventQueue<ConversationMessageModel?>();

  /// 消息id列表变更事件队列，channel: conversationId
  final messageIdsChangeEventQueue = EventQueue<void>();

  @override
  void onInit() {
    _cachedMessages = {};
    _cachedMessageIds = {};
    super.onInit();
  }

  /// 清除消息缓存
  void clearMessageCache(int msgId) {
    _cachedMessages.remove(msgId);
  }

  /// 清除消息列表缓存
  void clearMessageListCache(int conversationId) {
    _cachedMessageIds.remove(conversationId);
  }

  /// 获取消息列表
  List<ConversationMessageModel> getMessageList(int conversationId) {
    if (!_cachedMessageIds.containsKey(conversationId)) {
      _cachedMessageIds[conversationId] =
          MessageRepository.getMessageIds(conversationId);
    }
    return _cachedMessageIds[conversationId]!.map((msgId) {
      if (!_cachedMessages.containsKey(msgId)) {
        final message = MessageRepository.getMessage(msgId);
        if (message != null) {
          _cachedMessages[msgId] = message;
        }
      }
      return _cachedMessages[msgId]!;
    }).toList();
  }

  /// 获取消息id列表
  List<int> getMessageIds(int conversationId) {
    if (!_cachedMessageIds.containsKey(conversationId)) {
      _cachedMessageIds[conversationId] =
          MessageRepository.getMessageIds(conversationId);
    }
    return _cachedMessageIds[conversationId]!;
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
    List<String>? filePaths,
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
      filePaths: filePaths,
    );
    _cachedMessages[message.msgId] = message;
    messageIdsChangeEventQueue.emit(conversationId, Event<void>(null));
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
    messageChangeEventQueue.emit(
      msgId,
      Event<ConversationMessageModel?>(getMessage(msgId)),
    );
  }

  /// 删除消息
  void deleteMessage({
    int? msgId,
    int? conversationId,
    int? chatAppId,
  }) async {
    if (msgId == null && conversationId == null && chatAppId == null) {
      throw ArgumentError('msgId, conversationId, chatAppId不能同时为空');
    }
    // 删除的消息id列表
    List<int> deletedMsgIds = [];
    // 改变的会话id列表
    List<int> changedConversationIds = [];

    // 清理缓存
    if (msgId != null) {
      final message = getMessage(msgId);
      if (message != null) {
        // 删除消息列表缓存
        clearMessageListCache(message.conversationId);
        changedConversationIds.add(message.conversationId);
      }
      // 删除消息缓存
      clearMessageCache(msgId);
      deletedMsgIds.add(msgId);
    } else if (conversationId != null) {
      final messages = getMessageList(conversationId);
      for (final message in messages) {
        clearMessageCache(message.msgId);
        deletedMsgIds.add(message.msgId);
      }
      // 删除消息列表缓存
      clearMessageListCache(conversationId);
      changedConversationIds.add(conversationId);
    } else if (chatAppId != null) {
      final conversationService = Get.find<ConversationService>();
      final conversationIds =
          await conversationService.getAllConversationIds(chatAppId);
      for (final conversationId in conversationIds) {
        // 删除消息列表缓存
        clearMessageListCache(conversationId);
        changedConversationIds.add(conversationId);
        // 删除消息缓存
        final messages = getMessageList(conversationId);
        for (final message in messages) {
          clearMessageCache(message.msgId);
          deletedMsgIds.add(message.msgId);
        }
      }
    }

    // 从数据库删除消息
    MessageRepository.deleteMessage(
      msgId: msgId,
      conversationId: conversationId,
      chatAppId: chatAppId,
    );

    // 发送消息变更事件
    for (final msgId in deletedMsgIds) {
      messageChangeEventQueue.emit(
        msgId,
        Event<ConversationMessageModel?>(null),
      );
    }

    // 发送消息id列表变更事件
    for (final conversationId in changedConversationIds) {
      messageIdsChangeEventQueue.emit(conversationId, Event<void>(null));
    }
  }

  /// 监听消息变更
  EventListener listenMessageChange(
    int msgId,
    Function(ConversationMessageModel?) callback,
  ) {
    return messageChangeEventQueue.addListener(msgId, (event) {
      callback(event.data);
    });
  }

  /// 监听消息id列表变更
  EventListener listenMessageIdsChange(
    int conversationId,
    Function() callback,
  ) {
    return messageIdsChangeEventQueue.addListener(conversationId, (event) {
      callback();
    });
  }
}
