import 'package:dio/dio.dart';

/// 版本信息
class VersionInfo {
  final String version;
  final String buildNumber;

  VersionInfo(this.version, this.buildNumber);
}

/// APP版本
class AppVersion {
  /// 发布记录地址
  static const releasesUrl = 'https://github.com/nickham-su/talk_ai/releases';

  /// 更新配置地址
  static const configUrl =
      'https://github.com/nickham-su/talk_ai/releases/latest/download/appcast.xml';

  /// 获取最新版本
  static Future<VersionInfo> getLatestVersion() async {
    final response = await Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30), // 连接超时
      sendTimeout: const Duration(seconds: 30), // 发送超时
      receiveTimeout: const Duration(seconds: 30), // 接收超时
    )).get(configUrl);

    // <sparkle:shortVersionString>1.0.3</sparkle:shortVersionString>
    RegExp regex = RegExp(
        r'<sparkle:shortVersionString>\s*([\d\.]+)\s*</sparkle:shortVersionString>');
    final match = regex.firstMatch(response.data as String);
    if (match == null) {
      throw Exception('未匹配到version');
    }
    String latestVersion = match.group(1)!;

    RegExp regex2 = RegExp(r'<sparkle:version>\s*(\d+)\s*</sparkle:version>');
    final match2 = regex2.firstMatch(response.data as String);
    if (match2 == null) {
      throw Exception('未匹配到buildNumber');
    }
    String latestBuildNumber = match2.group(1)!;

    return VersionInfo(latestVersion, latestBuildNumber);
  }
}
