import 'package:TalkAI/shared/models/message/message_model.dart';

import 'message_status.dart';

/// 会话消息模型
class ConversationMessageModel {
  final int msgId; // 消息id
  final int chatAppId; // 聊天助理id
  final int conversationId; // 会话id
  final MessageRole role; // 角色
  final DateTime createdTime; // 创建时间
  String content; // 内容
  MessageStatus status; // 状态
  final int llmId; // 当role为assistant时，记录模型id，0表示没有记录
  final String llmName; // 当role为assistant时，记录模型名称
  final int generateId; // 生成id
  final List<String> files; // 文件路径

  ConversationMessageModel({
    required this.msgId,
    required this.chatAppId,
    required this.conversationId,
    required this.role,
    required this.createdTime,
    required this.content,
    required this.status,
    required this.llmId,
    required this.llmName,
    required this.generateId,
    required this.files,
  });

  @override
  toString() {
    return 'ConversationMessageModel{msgId: $msgId, chatAppId: $chatAppId, conversationId: $conversationId, role: $role, createdTime: $createdTime, status: $status, llmId $llmId, llmName $llmName ,content: ${content.length > 20 ? '${content.substring(0, 20)}...' : content}';
  }
}
