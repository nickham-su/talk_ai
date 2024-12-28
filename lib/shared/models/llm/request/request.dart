import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../apis/new_dio.dart';
import '../../../repositories/setting_repository.dart';

/// 网路请求
class Request {
  Dio? _dio;

  /// 取消请求
  cancel() {
    try {
      if (_dio == null) return;
      _dio?.close(force: true);
      _dio = null;
    } catch (e) {}
  }

  /// 聊天
  Stream<Map<String, dynamic>> stream({
    required String url,
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async* {
    _dio = newDio();

    Response<ResponseBody> response = await _dio!.post<ResponseBody>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: Options(
        headers: headers,
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
      // 删除空数据
      resStr = resStr.replaceAll(RegExp(r'(data:\s+)+data:', dotAll: true), 'data:');

      // 匹配所有 data: 开头的字符串
      final regex = RegExp(r'data:(.*)(?=\n|$|data:)');
      final matchArr = regex.allMatches(resStr);
      if (matchArr.isEmpty) {
        // 数据不完整
        uncompletedData = data;
        continue;
      }

      // 数据块中的json数据集合
      List<Map<String, dynamic>> jsonList = [];
      try {
        for (var match in matchArr) {
          final data = match.group(1)!;
          // 去掉 data: 开头的字符串, 保留 json 字符串
          final regex = RegExp(r'^data:');
          final jsonStr = data.replaceFirst(regex, '').trim();
          // 处理[DONE]
          if (jsonStr == '[DONE]') {
            break;
          }
          // 解析 json 字符串
          jsonList.add(json.decode(jsonStr));
        }
      } catch (e) {
        // 如果解析失败，说明数据不完整
        uncompletedData = data;
        continue;
      }

      // 成功解析数据，清空未完成数据
      uncompletedData = null;

      // 返回数据
      for (var jsonData in jsonList) {
        yield jsonData;
      }
    }
  }
}
