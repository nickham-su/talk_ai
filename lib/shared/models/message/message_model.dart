enum MessageRole {
  system('system'), // 系统消息
  user('user'), // 用户消息
  assistant('assistant'); // 机器人消息

  final String value;

  const MessageRole(this.value);
}

// 聊天信息模型
class MessageModel {
  MessageRole role;
  String content;
  List<String> files;

  MessageModel({
    required this.role,
    required this.content,
    required this.files,
  });
}
