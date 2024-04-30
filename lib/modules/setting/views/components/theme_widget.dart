import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/repositories/setting_repository.dart';

class ThemeWidget extends StatelessWidget {
  const ThemeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Get.isDarkMode;

    return Container(
      padding: const EdgeInsets.only(right: 4),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.only(left: 0, right: 0),
        value: isDarkMode,
        onChanged: (bool value) async {
          SettingRepository.setThemeMode(
              isDarkMode ? ThemeMode.light : ThemeMode.dark);
          Get.changeThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
          await Future.delayed(const Duration(milliseconds: 200));
          Get.forceAppUpdate();
        },
        title: const Text(
          '深色主题',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
