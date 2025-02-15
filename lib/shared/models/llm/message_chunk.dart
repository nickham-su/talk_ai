/// 流式消息块
class MessageChunk {
  final String content;
  final String reasoningContent;

  MessageChunk({
    required this.content,
    required this.reasoningContent,
  });
}
