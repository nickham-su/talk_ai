import 'package:get/get.dart';
import 'package:package_info/package_info.dart';

import '../apis/app_version.dart';

class AppUpdateController extends GetxController {
  /// 是否需要更新
  bool needUpdate = false;

  /// 最新版本
  String latestVersion = '';

  @override
  void onInit() {
    Future.delayed(const Duration(seconds: 10), () {
      checkUpdate();
    });
    super.onInit();
  }

  /// 检查更新
  void checkUpdate() async {
    final remoteVersion = await AppVersion.getLatestVersion();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String buildNumber = packageInfo.buildNumber;

    if (int.parse(remoteVersion.buildNumber) > int.parse(buildNumber)) {
      needUpdate = true;
      latestVersion = remoteVersion.version;
    }
    update();
  }
}
