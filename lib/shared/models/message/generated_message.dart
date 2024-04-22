import 'message_status.dart';

/// 生成消息
class GeneratedMessage {
  final int generateId; // 生成id
  final int msgId; // 消息id
  final int chatAppId; // 聊天助理id
  final int llmId; // 模型id
  String llmName; // 当role为assistant时，记录模型名称
  MessageStatus status; // 状态
  String content; // 内容
  String error; // 错误信息

  GeneratedMessage({
    required this.generateId,
    required this.msgId,
    required this.chatAppId,
    required this.llmId,
    required this.llmName,
    required this.status,
    required this.content,
    this.error = '',
  });
}
