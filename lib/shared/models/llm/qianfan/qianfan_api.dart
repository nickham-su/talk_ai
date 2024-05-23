import '../../message/message_model.dart';
import '../request/request.dart';
import 'signature.dart';

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
    required List<MessageModel> messages, // 聊天信息
    required double temperature, // 温度
    required String accessKey, // AKSK鉴权
    required String secretKey, // AKSK鉴权
    required String accessToken, // AccessToken鉴权
  }) async* {
    if (accessToken == '' && (accessKey == '' || secretKey == '')) {
      throw 'AK/SK 或 AccessToken 不能同时为空';
    }

    // 过滤空消息
    messages.removeWhere((m) => m.content == '');

    _request = Request();

    // 获取当前时间
    final DateTime now = DateTime.now().toUtc();
    String timestamp = '${now.toIso8601String().split('.').first}Z';

    // 解析url
    final uri = Uri.parse(url);

    // 请求头
    Map<String, dynamic> headers = {
      'Host': uri.host,
      'Content-Type': 'application/json',
      'x-bce-date': timestamp,
    };

    // 请求参数，默认为空
    Map<String, dynamic>? queryParameters;

    // 鉴权
    if (accessKey != '' && secretKey != '') {
      headers['Authorization'] = signature(
        accessKeyId: accessKey,
        secretAccessKey: secretKey,
        path: uri.path,
        method: 'POST',
        timestamp: timestamp,
        headers: headers,
      );
    } else {
      queryParameters = {
        'access_token': accessToken,
      };
    }

    // 发送请求
    final stream = _request!.stream(
      url: url,
      queryParameters: queryParameters,
      headers: headers,
      data: {
        'messages': messages.map((e) => e.toJson()).toList(),
        'temperature': temperature,
        'stream': true,
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
