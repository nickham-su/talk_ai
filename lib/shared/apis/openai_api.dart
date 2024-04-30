import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import '../repositories/setting_repository.dart';
import '../models/llm/openai/chat_completions_response.dart';
import '../models/message/message_model.dart';

class OpenaiApi {
  static const completionPath = '/v1/chat/completions';

  /// Dio 实例
  static Dio? _dio;

  /// 取消请求
  static cancel() {
    _dio?.close(force: true);
    _dio = null;
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
  }) async* {
    url = Uri.parse(url).resolve(completionPath).toString();

    int timeout = SettingRepository.getNetworkTimeout();

    _dio = Dio(
      BaseOptions(
        connectTimeout: Duration(seconds: timeout), // 连接超时
        sendTimeout: Duration(seconds: timeout), // 发送超时
        receiveTimeout: Duration(seconds: timeout), // 接收超时
      ),
    );

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

    Response<ResponseBody> response = await _dio!.post<ResponseBody>(
      url,
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
        responseType: ResponseType.stream, // 设置为流式响应
      ),
    );

    // 上次未完成的数据，数据可能会被截断
    String uncompletedData = '';

    await for (var data in response.data!.stream) {
      final resStr = utf8.decode(data);

      // 匹配所有 data: 开头的字符串
      final regex = RegExp(r'data:(.*)[\n$]');
      final matchArr = regex.allMatches(uncompletedData + resStr);
      if (matchArr.isEmpty) {
        continue;
      }
      for (var match in matchArr) {
        final data = match.group(1)!;
        // 去掉 data: 开头的字符串, 保留 json 字符串
        final regex = RegExp(r'^data:');
        final jsonStr = data.replaceFirst(regex, '').trim();

        // 解析 json 字符串
        try {
          final Map<String, dynamic> resJson = json.decode(jsonStr);
          ChatCompletionsResponse rsp =
              ChatCompletionsResponse.fromJson(resJson);
          for (var choice in rsp.choices) {
            if (choice.finishReason == 'stop' || choice.delta.content == null) {
              return;
            }
            yield choice.delta.content!;
          }
          uncompletedData = '';
        } catch (e) {
          uncompletedData = data;
        }
      }
    }
  }
}
