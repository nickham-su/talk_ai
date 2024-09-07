import 'dart:convert';

import '../../message/message_model.dart';
import '../request/request.dart';

class OpenaiApi {
  static const completionPath = '/v1/chat/completions';

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
    required String model, // 请求模型
    required List<MessageModel> messages, // 聊天信息
    required double temperature, // 温度
    required double topP, // top-p
    List<String>? stop, // 停止词
    int? maxTokens, // 最大令牌数
  }) async* {
    // 拼接请求地址
    url = Uri.parse(url).resolve(completionPath).toString();

    // 过滤空消息
    messages.removeWhere((m) => m.content == '');

    _request = Request();

    Map<String, dynamic> data = {
      'model': model,
      'messages': messages.map((e) => e.toJson()).toList(),
      'temperature': temperature,
      'top_p': topP,
      'stream': true,
    };
    if (stop != null) {
      data['stop'] = stop;
    }
    if (maxTokens != null) {
      data['max_tokens'] = maxTokens;
    }

    final stream = _request!.stream(
      url: url,
      data: data,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
    );

    await for (var data in stream) {
      final rsp = ChatCompletionsResponse.fromJson(data);
      for (var choice in rsp.choices) {
        yield choice.delta?.content ?? '';
      }
    }
  }
}

/// 聊天响应模型
class ChatCompletionsResponse {
  /// 构造函数
  ChatCompletionsResponse({
    this.id,
    this.object,
    this.created,
    required this.choices,
  });

  /// ID字符串，例如："chatcmpl-123"
  final String? id;

  /// 对象字符串，例如："chat.completion"
  final String? object;

  /// 创建时间戳
  final int? created;

  /// 选择列表
  final List<ChoiceModel> choices;

  factory ChatCompletionsResponse.fromJson(Map<String, dynamic> json) {
    return ChatCompletionsResponse(
      id: json['id'],
      object: json['object'],
      created: json['created'],
      choices: List<ChoiceModel>.from(
          json['choices'].map((x) => ChoiceModel.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object': object,
      'created': created,
      'choices': List<dynamic>.from(choices.map((x) => x.toJson())),
    };
  }
}

/// 选择模型
class ChoiceModel {
  /// 构造函数
  ChoiceModel({
    this.index,
    this.finishReason,
    this.delta,
  });

  /// 索引号，例如：0
  final int? index;

  /// 完成原因字符串，例如："stop"
  final String? finishReason;

  /// 消息模型
  final Delta? delta;

  factory ChoiceModel.fromJson(Map<String, dynamic> json) {
    return ChoiceModel(
      index: json['index'],
      finishReason: json['finish_reason'],
      delta: json['delta'] != null && json['delta'] is Map<String, dynamic>
          ? Delta.fromJson(json['delta'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'delta': delta?.toJson(),
      'finish_reason': finishReason,
    };
  }
}

/// 消息块
class Delta {
  /// 构造函数
  Delta({this.content});

  /// 内容字符串
  final String? content;

  factory Delta.fromJson(Map<String, dynamic> json) {
    return Delta(
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }
}
