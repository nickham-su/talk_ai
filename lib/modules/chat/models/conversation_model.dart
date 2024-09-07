import '../../../shared/models/message/conversation_message_model.dart';

/// 会话消息模型
class ConversationModel {
  final int conversationId; // 会话id
  final int chatAppId; // 聊天助理id
  final DateTime createdTime; // 创建时间
  final DateTime updatedTime; // 更新时间

  ConversationModel({
    required this.conversationId,
    required this.chatAppId,
    required this.createdTime,
    required this.updatedTime,
  });
}
