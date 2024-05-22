import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../repositories/setting_repository.dart';
import '../../message/message_model.dart';

class QianFanApi {
  /// Dio 实例
  static Dio? _dio;

  /// 取消请求
  static cancel() {
    _dio?.close(force: true);
    _dio = null;
  }

  /// 聊天
  static Stream<String> chatCompletions({
    required String url,
    required String accessToken, // 请求密钥
    required List<MessageModel> messages, // 聊天信息
    required double temperature, // 温度
  }) async* {
    int timeout = SettingRepository.getNetworkTimeout();

    _dio = Dio(
      BaseOptions(
        connectTimeout: Duration(seconds: timeout), // 连接超时
        sendTimeout: Duration(seconds: timeout), // 发送超时
        receiveTimeout: Duration(seconds: timeout), // 接收超时
      ),
    );

    // 过滤空消息
    messages.removeWhere((m) => m.content == '');

    Map<String, dynamic> data = {
      'messages': messages.map((e) => e.toJson()).toList(),
      'temperature': temperature,
      'stream': true,
    };

    Response<ResponseBody> response = await _dio!.post<ResponseBody>(
      url,
      data: data,
      queryParameters: {
        'access_token': accessToken,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'x-bce-date': DateTime.now().toUtc().toIso8601String(),
        },
        responseType: ResponseType.stream, // 设置为流式响应
      ),
    );

    // 未完成的数据
    Uint8List? uncompletedData;

    await for (var data in response.data!.stream) {
      if (uncompletedData != null) {
        // 如果有未完成的数据，拼接数据
        final Uint8List temp = Uint8List(uncompletedData.length + data.length);
        temp.setAll(0, uncompletedData);
        temp.setAll(uncompletedData.length, data);
        data = temp;
      }
      late String resStr;
      try {
        resStr = utf8.decode(data);
      } catch (e) {
        // 如果解析失败，说明数据不完整
        uncompletedData = data;
        continue;
      }

      // 匹配所有 data: 开头的字符串
      final regex = RegExp(r'data:(.*)[\n$]');
      final matchArr = regex.allMatches(resStr);
      if (matchArr.isEmpty) {
        continue;
      }
      for (var match in matchArr) {
        final data = match.group(1)!;
        // 去掉 data: 开头的字符串, 保留 json 字符串
        final regex = RegExp(r'^data:');
        final jsonStr = data.replaceFirst(regex, '').trim();

        // 解析 json 字符串
        final Map<String, dynamic> resJson = json.decode(jsonStr);
        ResponseModel rsp = ResponseModel.fromJson(resJson);
        yield rsp.result;
      }
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
