import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingRepository {
  static const _boxName = 'setting';

  /// 获取主题模式
  static Future<ThemeMode> getThemeMode() async {
    final box = await Hive.openBox(_boxName);
    final themeMode = box.get('theme_mode', defaultValue: 'dark');
    if (themeMode == 'dark') {
      return ThemeMode.dark;
    } else {
      return ThemeMode.light;
    }
  }

  /// 设置主题模式
  static setThemeMode(ThemeMode mode) {
    final box = Hive.box(_boxName);
    box.put('theme_mode', mode == ThemeMode.dark ? 'dark' : 'light');
  }

  /// 获取网络请求超时时间
  static int getNetworkTimeout() {
    final box = Hive.box(_boxName);
    return box.get('network_timeout', defaultValue: 30);
  }

  /// 设置网络请求超时时间
  static setNetworkTimeout(int timeout) {
    final box = Hive.box(_boxName);
    box.put('network_timeout', timeout);
  }
}
