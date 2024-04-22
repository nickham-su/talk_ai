import 'package:auto_updater/auto_updater.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/setting_controller.dart';

class UpdateWidget extends GetView<SettingController> {
  const UpdateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      height: 32,
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '应用更新',
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () async {
              const feedURL =
                  'https://github.com/nickham-su/talk_ai/releases/latest/download/appcast.xml';
              await autoUpdater.setFeedURL(feedURL);
              await autoUpdater.checkForUpdates();
            },
            child: const Text('检查更新',
                style: TextStyle(
                  fontSize: 14,
                )),
          ),
        ],
      ),
    );
  }
}
