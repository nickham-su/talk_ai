import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../repositories/setting_repository.dart';

Dio newDio({
  int? timeout,
  bool? enableProxy,
  String? proxyAddress,
}) {
  final _timeout = timeout ?? SettingRepository.getNetworkTimeout();
  final _enableProxy = enableProxy ?? SettingRepository.getProxyEnable();
  final _proxyAddress = proxyAddress ?? SettingRepository.getProxyAddress();

  final dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: _timeout), // 连接超时
    sendTimeout: Duration(seconds: _timeout), // 发送超时
    receiveTimeout: Duration(seconds: _timeout), // 接收超时
  ));

  if (_enableProxy) {
    dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () => HttpClient()
          ..findProxy = (uri) {
            return 'PROXY $_proxyAddress';
          }
          ..badCertificateCallback = (cert, host, port) {
            return true;
          });
  }
  return dio;
}
