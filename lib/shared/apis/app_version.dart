import 'package:dio/dio.dart';

import 'new_dio.dart';

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
  static Future<VersionInfo> getLatestVersionForMacos() async {
    final response = await newDio().get(configUrl);

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

  /// 获取最新版本
  static Future<VersionInfo> getLatestVersionForWindows() async {
    final response = await newDio().get(configUrl);

    // sparkle:version="1.0.0+1"
    RegExp regex = RegExp(r'sparkle:version="([\d\.]+)\+(\d+)"');
    final match = regex.firstMatch(response.data as String);
    if (match == null) {
      throw Exception('未匹配到version');
    }
    String latestVersion = match.group(1)!;
    String latestBuildNumber = match.group(2)!;

    return VersionInfo(latestVersion, latestBuildNumber);
  }
}
