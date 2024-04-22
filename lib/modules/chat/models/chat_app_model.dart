/// 聊天助理
class ChatAppModel {
  final int chatAppId; // 聊天助理id
  final String name; // 名称
  final String prompt; // 提示词
  final int llmId; // 模型id
  final double temperature; // 温度
  final double topP; // top_p
  final DateTime lastUseTime; // 最后使用时间

  ChatAppModel({
    required this.chatAppId,
    required this.name,
    required this.prompt,
    required this.llmId,
    required this.temperature,
    required this.topP,
    required this.lastUseTime,
  });
}
