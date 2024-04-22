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

  MessageModel({required this.role, required this.content});

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    late MessageRole role;
    switch (json['role']) {
      case 'system':
        role = MessageRole.system;
        break;
      case 'user':
        role = MessageRole.user;
        break;
      case 'assistant':
        role = MessageRole.assistant;
        break;
      default:
        throw Exception('Unknown role: ${json['role']}');
    }

    return MessageModel(
      role: role,
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role.value,
      'content': content,
    };
  }
}
