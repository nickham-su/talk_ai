import 'package:auto_updater/auto_updater.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_ai/shared/components/snackbar.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../shared/apis/app_version.dart';
import '../../../../shared/controllers/app_update_controller.dart';

class UpdateWidget extends StatelessWidget {
  const UpdateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppUpdateController>(
      builder: (AppUpdateController controller) {
        return Container(
          margin: const EdgeInsets.only(top: 24),
          height: 32,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      '应用更新',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    if (controller.needUpdate)
                      Text(
                        '有新版本${controller.latestVersion}可用!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Get.theme.colorScheme.error,
                        ),
                      ),
                  ],
                ),
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    controller.needUpdate
                        ? Get.theme.colorScheme.errorContainer
                        : Get.theme.colorScheme.secondaryContainer,
                  ),
                ),
                onPressed: () async {
                  await autoUpdater.setFeedURL(AppVersion.configUrl);
                  await Future.delayed(const Duration(seconds: 1));
                  await autoUpdater.checkForUpdates();
                },
                child: Text(controller.needUpdate ? '立即自动更新' : '检查更新',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                      color: controller.needUpdate
                          ? Get.theme.colorScheme.error
                          : Get.theme.colorScheme.secondary,
                    )),
              ),
              const SizedBox(
                width: 10,
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Get.theme.colorScheme.secondaryContainer,
                  ),
                ),
                onPressed: () async {
                  // 打开浏览器，访问github
                  try {
                    await launchUrlString(AppVersion.releasesUrl);
                  } catch (e) {
                    snackbar(
                      '提示',
                      '无法打开浏览器，请手动访问：${AppVersion.releasesUrl}',
                      duration: const Duration(seconds: 10),
                    );
                  }
                },
                child: Text('手动下载',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                      color: Get.theme.colorScheme.secondary,
                    )),
              ),
            ],
          ),
        );
      },
    );
  }
}
