import '../../message/message_model.dart';
import '../request/request.dart';

class QianFanApi {
  /// Dio 实例
  static Request? _request;

  /// 取消请求
  static cancel() {
    _request?.cancel();
  }

  /// 聊天
  static Stream<String> chatCompletions({
    required String url,
    required String accessToken, // 请求密钥
    required List<MessageModel> messages, // 聊天信息
    required double temperature, // 温度
  }) async* {
    // 过滤空消息
    messages.removeWhere((m) => m.content == '');

    _request = Request();

    final stream = _request!.stream(
      url: url,
      queryParameters: {
        'access_token': accessToken,
      },
      data: {
        'messages': messages.map((e) => e.toJson()).toList(),
        'temperature': temperature,
        'stream': true,
      },
      headers: {
        'Content-Type': 'application/json',
        'x-bce-date': DateTime.now().toUtc().toIso8601String(),
      },
    );

    await for (var data in stream) {
      ResponseModel rsp = ResponseModel.fromJson(data);
      yield rsp.result;
    }
  }
}

/// 响应
class ResponseModel {
  String id;
  String object;
  bool isEnd;
  String result;
  Usage usage;

  ResponseModel({
    required this.id,
    required this.object,
    required this.isEnd,
    required this.result,
    required this.usage,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      id: json['id'],
      object: json['object'],
      isEnd: json['is_end'],
      result: json['result'],
      usage: Usage.fromJson(json['usage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object': object,
      'is_end': isEnd,
      'result': result,
      'usage': usage.toJson(),
    };
  }
}

class Usage {
  int promptTokens;
  int completionTokens;
  int totalTokens;

  Usage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      promptTokens: json['prompt_tokens'],
      completionTokens: json['completion_tokens'],
      totalTokens: json['total_tokens'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt_tokens': promptTokens,
      'completion_tokens': completionTokens,
      'total_tokens': totalTokens,
    };
  }
}
