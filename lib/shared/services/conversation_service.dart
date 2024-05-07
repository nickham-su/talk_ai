import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../modules/chat/models/conversation_model.dart';
import '../../modules/chat/repositorys/conversation_repository.dart';
import '../utils/sqlite.dart';

class ConversationService extends GetxService {
  /// 缓存会话, key: conversationId
  late Map<int, ConversationModel> _cachedConversation;

  /// 缓存会话ID列表, key: chatAppId
  late Map<int, List<int>> _cachedConversationIds;

  @override
  void onInit() {
    _cachedConversation = {};
    _cachedConversationIds = {};
    super.onInit();
  }

  /// 清除会话缓存
  void clearConversationCache(int conversationId) {
    _cachedConversation.remove(conversationId);
  }

  /// 清除回话列表缓存
  void clearConversationIdsCache(int chatAppId) {
    _cachedConversationIds.remove(chatAppId);
  }

  /// 获取所有会话ID
  Future<List<int>> getAllConversationIds(int chatAppId) async {
    if (_cachedConversationIds.containsKey(chatAppId)) {
      return _cachedConversationIds[chatAppId]!;
    }
    final ids = await compute<Map<String, dynamic>, List<int>>(
      _threadGetConversationIds,
      {
        'dbDir': Sqlite.dbDir,
        'chatAppId': chatAppId,
      },
    );
    _cachedConversationIds[chatAppId] = ids;
    return ids;
  }

  /// 获取最后一个会话
  Future<int?> getLastConversationId(int chatAppId) async {
    final ids = await getAllConversationIds(chatAppId);
    if (ids.isEmpty) {
      return null;
    }
    return ids.last;
  }

  /// 获取会话
  ConversationModel? getConversation(int conversationId) {
    if (_cachedConversation.containsKey(conversationId)) {
      return _cachedConversation[conversationId]!;
    }
    final conversation = ConversationRepository.getConversation(conversationId);
    if (conversation != null) {
      _cachedConversation[conversationId] = conversation;
    }
    return conversation;
  }

  /// 插入会话
  ConversationModel insertConversation(int chatAppId) {
    // 会话列表会增加新成员，所以删除会话列表缓存
    clearConversationIdsCache(chatAppId);
    final conversation = ConversationRepository.insertConversation(chatAppId);
    _cachedConversation[conversation.conversationId] = conversation;
    return conversation;
  }

  /// 删除会话
  Future<void> deleteConversation({
    int? conversationId,
    int? chatAppId,
  }) async {
    if (conversationId == null && chatAppId == null) {
      return;
    }
    if (conversationId != null) {
      // 查询会话，删除会话列表缓存
      final conversation = getConversation(conversationId);
      if (conversation != null) {
        clearConversationIdsCache(conversation.chatAppId);
      }
      // 删除会话缓存
      clearConversationCache(conversationId);
    } else if (chatAppId != null) {
      // 删除会话缓存
      final ids = await getAllConversationIds(chatAppId);
      for (final id in ids) {
        clearConversationCache(id);
      }
      // 删除会话列表缓存
      clearConversationIdsCache(chatAppId);
    }
    // 从数据库删除会话
    ConversationRepository.deleteConversation(
      conversationId: conversationId,
      chatAppId: chatAppId,
    );
  }

  /// 更新会话时间
  void updateConversationTime(int conversationId) {
    final conversation = getConversation(conversationId);
    // 会话列表顺序会改变，所以删除会话列表缓存
    if (conversation != null) {
      clearConversationIdsCache(conversation.chatAppId);
    }
    // 删除会话缓存
    clearConversationCache(conversationId);
    // 更新会话时间
    ConversationRepository.updateConversationTime(conversationId);
  }
}

/// 使用线程获取会话id列表，查询和分组都在后台线程运算
List<int> _threadGetConversationIds(Map<String, dynamic> params) {
  Sqlite.openDB(params['dbDir']);
  final chatAppId = params['chatAppId'];
  if (chatAppId == null) {
    return [];
  }
  final allList = ConversationRepository.getAllConversationIds(chatAppId);
  Sqlite.dispose();
  return allList;
}
