import 'dart:typed_data';

/// 聊天助理
class ChatAppModel {
  final int chatAppId; // 聊天助理id
  final String name; // 名称
  final String prompt; // 提示词
  final double temperature; // 温度
  final double topP; // top_p
  final DateTime lastUseTime; // 最后使用时间
  final DateTime toppingTime; // 置顶时间
  final int llmId; // 默认模型id
  final bool multipleRound; // 是否多轮对话
  final DateTime updatedTime; // 更新时间
  final Uint8List? profilePicture; // 头像

  ChatAppModel({
    required this.chatAppId,
    required this.name,
    required this.prompt,
    required this.temperature,
    required this.topP,
    required this.lastUseTime,
    required this.toppingTime,
    required this.llmId,
    required this.multipleRound,
    required this.updatedTime,
    required this.profilePicture,
  });
}
