import 'package:dio/dio.dart';

import '../../../apis/new_dio.dart';
import '../../message/message_model.dart';
import '../request/request.dart';

class QianFanApi {
  /// 获取token地址
  static const tokenUrl = 'https://aip.baidubce.com/oauth/2.0/token';

  /// AccessToken
  static AccessToken? _token;

  /// token过期时间
  static DateTime? _expireTime;

  /// Dio 实例
  static Request? _request;

  /// 取消请求
  static cancel() {
    _request?.cancel();
  }

  /// 获取AccessToken
  static _getAccessToken({
    required String apiKey,
    required String secretKey,
  }) async {
    Response response = await newDio().post(
      tokenUrl,
      queryParameters: {
        'grant_type': 'client_credentials',
        'client_id': apiKey,
        'client_secret': secretKey,
      },
    );
    _token = AccessToken.fromJson(response.data);
    _expireTime = DateTime.now().add(Duration(seconds: _token!.expiresIn));
  }

  /// 聊天
  static Stream<String> chatCompletions({
    required String url,
    required List<MessageModel> messages, // 聊天信息
    required double temperature, // 温度
    required String apiKey,
    required String secretKey,
  }) async* {
    if (_token == null ||
        _expireTime == null ||
        _expireTime!.isBefore(DateTime.now())) {
      await _getAccessToken(apiKey: apiKey, secretKey: secretKey);
    }

    // 过滤空消息
    messages.removeWhere((m) => m.content == '');

    _request = Request();

    // 获取当前时间
    final DateTime now = DateTime.now().toUtc();
    String timestamp = '${now.toIso8601String().split('.').first}Z';

    // 发送请求
    final stream = _request!.stream(
      url: url,
      queryParameters: {
        'access_token': _token!.accessToken,
      },
      headers: {
        'Content-Type': 'application/json',
        'x-bce-date': timestamp,
      },
      data: {
        'messages': messages
            .map((e) => {'role': e.role.value, 'content': e.content})
            .toList(),
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

/// AccessToken响应
class AccessToken {
  String refreshToken;
  int expiresIn;
  String sessionKey;
  String accessToken;
  String scope;
  String sessionSecret;

  AccessToken({
    required this.refreshToken,
    required this.expiresIn,
    required this.sessionKey,
    required this.accessToken,
    required this.scope,
    required this.sessionSecret,
  });

  factory AccessToken.fromJson(Map<String, dynamic> json) {
    return AccessToken(
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int,
      sessionKey: json['session_key'] as String,
      accessToken: json['access_token'] as String,
      scope: json['scope'] as String,
      sessionSecret: json['session_secret'] as String,
    );
  }
}
