import 'dart:convert';

import 'package:dio/dio.dart';
import '../../../repositories/setting_repository.dart';
import '../../message/message_model.dart';

/// 阿里云通义千问API
class ALiYunQwenApi {
  static const url =
      "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation";

  /// Dio 实例
  static Dio? _dio;

  /// 取消请求
  static cancel() {
    _dio?.close(force: true);
    _dio = null;
  }

  /// 聊天
  static Stream<String> chatCompletions({
    required String apiKey, // 请求密钥
    required String model, // 请求模型
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
      'model': model,
      'input': {
        'messages': messages.map((e) => e.toJson()).toList(),
      },
      'parameters': {
        'incremental_output': true,
        'temperature': temperature,
      },
    };

    Response<ResponseBody> response = await _dio!.post<ResponseBody>(
      url,
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'X-DashScope-SSE': 'enable',
        },
        responseType: ResponseType.stream, // 设置为流式响应
      ),
    );

    await for (var data in response.data!.stream) {
      final resStr = utf8.decode(data);
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
        yield rsp.output.text;
      }
    }
  }
}

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
