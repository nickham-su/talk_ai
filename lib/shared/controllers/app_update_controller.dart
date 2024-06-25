import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:package_info/package_info.dart';

import '../repositories/setting_repository.dart';
import '../apis/app_version.dart';

class AppUpdateController extends GetxController {
  /// 是否需要更新
  bool needUpdate = false;

  /// 最新版本
  String latestVersion = '';

  @override
  void onInit() {
    // 启动后延迟10秒检查更新
    Future.delayed(const Duration(seconds: 10), () {
      checkUpdate();
    });
    // 启动定时器检查更新
    Timer.periodic(const Duration(minutes: 1), (timer) {
      checkUpdate();
    });
    super.onInit();
  }

  /// 检查更新
  void checkUpdate() async {
    const interval = 1000 * 60 * 60 * 24; // 间隔时间24小时
    final lastCheckTs = SettingRepository.getCheckUpdateTime();
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastCheckTs < interval) {
      return;
    }
    SettingRepository.setCheckUpdateTime();

    late VersionInfo remoteVersion;
    if (Platform.isWindows) {
      remoteVersion = await AppVersion.getLatestVersionForWindows();
    } else if (Platform.isMacOS) {
      remoteVersion = await AppVersion.getLatestVersionForMacos();
    } else {
      return;
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String buildNumber = packageInfo.buildNumber;

    if (int.parse(remoteVersion.buildNumber) > int.parse(buildNumber)) {
      needUpdate = true;
      latestVersion = remoteVersion.version;
    }
    update();
  }
}
