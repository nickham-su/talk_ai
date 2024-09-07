import 'dart:convert';
import 'dart:io';

import '../../message/message_model.dart';
import '../request/request.dart';

/// 阿里云DashScope API
class DashScopeApi {
  static const url =
      "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation";

  /// Dio 实例
  static Request? _request;

  /// 取消请求
  static cancel() {
    _request?.cancel();
  }

  /// 聊天
  static Stream<String> chatCompletions({
    required String apiKey, // 请求密钥
    required String model, // 请求模型
    required List<MessageModel> messages, // 聊天信息
    required double temperature, // 温度
  }) async* {
    // 过滤空消息
    messages.removeWhere((m) => m.content == '');
    _request = Request();

    // 处理消息
    final msgList = messages.map((e) {
      if (e.files.isEmpty) {
        return {'role': e.role.value, 'content': e.content};
      }
      List<Map<String, dynamic>> msgs = [
        {"type": "text", "text": e.content}
      ];
      for (var f in e.files) {
        // 读文件，转为base64
        final bytes = File(f).readAsBytesSync();
        String base64String = base64Encode(bytes);
        msgs.add({
          "type": "image_url",
          "image_url": {
            "url": 'data:image/jpeg;base64,$base64String',
          }
        });
      }
      return {'role': e.role.value, 'content': msgs};
    }).toList();

    final stream = _request!.stream(
      url: url,
      data: {
        'model': model,
        'input': {
          'messages': msgList,
        },
        'parameters': {
          'incremental_output': true,
          'temperature': temperature,
        },
      },
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'X-DashScope-SSE': 'enable',
      },
    );

    await for (var data in stream) {
      ResponseModel rsp = ResponseModel.fromJson(data);
      yield rsp.output.text;
    }
  }
}

/// 响应
class ResponseModel {
  Output output;
  Usage usage;
  String requestId;

  ResponseModel(
      {required this.output, required this.usage, required this.requestId});

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      output: Output.fromJson(json['output']),
      usage: Usage.fromJson(json['usage']),
      requestId: json['request_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'output': output.toJson(),
      'usage': usage.toJson(),
      'request_id': requestId,
    };
  }
}

class Output {
  String finishReason;
  String text;

  Output({required this.finishReason, required this.text});

  factory Output.fromJson(Map<String, dynamic> json) {
    return Output(
      finishReason: json['finish_reason'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'finish_reason': finishReason,
      'text': text,
    };
  }
}

class Usage {
  int totalTokens;
  int inputTokens;
  int outputTokens;

  Usage(
      {required this.totalTokens,
      required this.inputTokens,
      required this.outputTokens});

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      totalTokens: json['total_tokens'],
      inputTokens: json['input_tokens'],
      outputTokens: json['output_tokens'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_tokens': totalTokens,
      'input_tokens': inputTokens,
      'output_tokens': outputTokens,
    };
  }
}
