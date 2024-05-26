import 'dart:convert';

import '../../message/message_model.dart';
import '../request/request.dart';

class CozeApi {
  /// Dio 实例
  static Request? _request;

  /// 取消请求
  static cancel() {
    _request?.cancel();
  }

  /// 聊天
  static Stream<String> chatCompletions({
    required String url, // 请求地址
    required String apiKey, // 请求密钥
    required String botId, // botId
    required List<MessageModel> messages, // 聊天信息
  }) async* {
    // 过滤空消息
    messages.removeWhere((m) => m.content == '');

    // 将system角色的消息，合并到第一条user角色的消息中
    final systemContent =
        messages.first.role == MessageRole.system ? messages.first.content : '';
    messages.removeWhere((element) => element.role == MessageRole.system);
    if (messages.isNotEmpty &&
        systemContent.isNotEmpty &&
        messages.first.role == MessageRole.user) {
      messages.first.content = '$systemContent\n${messages.first.content}';
    }

    List<Map<String, String>> history = [];
    String query = '';
    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      if (i == messages.length - 1) {
        // 最后一条消息，是用户输入的消息
        query = msg.content;
      } else {
        // 前面的消息，是历史消息
        if (msg.role == MessageRole.user) {
          history.add({
            'role': 'user',
            'content_type': 'text',
            'content': msg.content,
          });
        } else if (msg.role == MessageRole.assistant) {
          history.add({
            'role': 'assistant',
            'content_type': 'text',
            "type": "answer",
            'content': msg.content,
          });
        }
      }
    }

    _request = Request();

    final stream = _request!.stream(
      url: url,
      data: {
        'bot_id': botId,
        'user': 'user',
        'query': query,
        'chat_history': history,
        'stream': true,
      },
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
    );

    await for (var data in stream) {
      ResponseModel rsp = ResponseModel.fromJson(data);
      if (rsp.message == null) continue;
      if (rsp.message!.type == 'answer') {
        yield rsp.message!.content;
      } else if (rsp.message!.type == 'function_call') {
        yield '正在调用插件...\n> ${rsp.message!.content}\n\n';
      }
    }
  }
}

class ResponseModel {
  String event; // 事件
  MessageContent? message; // 消息内容
  bool? isFinish; // 是否结束
  int? index; // 索引
  String? conversationId; // 会话Id

  ResponseModel(
      {required this.event,
      required this.message,
      required this.isFinish,
      required this.index,
      required this.conversationId});

  factory ResponseModel.fromJson(Map<String, dynamic> map) {
    final message = map['message'] as Map<String, dynamic>?;
    return ResponseModel(
      event: map['event'] as String,
      message: message != null ? MessageContent.fromJson(message) : null,
      isFinish: map['is_finish'] as bool?,
      index: map['index'] as int?,
      conversationId: map['conversation_id'] as String?,
    );
  }
}

class MessageContent {
  String role;
  String type;
  String content;
  String contentType;

  MessageContent(
      {required this.role,
      required this.type,
      required this.content,
      required this.contentType});

  factory MessageContent.fromJson(Map<String, dynamic> map) {
    return MessageContent(
      role: map['role'] as String,
      type: map['type'] as String,
      content: map['content'] as String,
      contentType: map['content_type'] as String,
    );
  }
}
