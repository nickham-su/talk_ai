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

  /// 记录检测更新时间
  static setCheckUpdateTime() {
    final box = Hive.box(_boxName);
    box.put('check_update_time', DateTime.now().millisecondsSinceEpoch);
  }

  /// 获取检测更新时间，单位：毫秒
  static int getCheckUpdateTime() {
    final box = Hive.box(_boxName);
    return box.get('check_update_time', defaultValue: 0);
  }

  /// 设置侧边栏宽度
  static setSidebarWidth(double width) {
    final box = Hive.box(_boxName);
    box.put('sidebar_width', width);
  }

  /// 获取侧边栏宽度
  static double getSidebarWidth(double defaultValue) {
    final box = Hive.box(_boxName);
    return box.get('sidebar_width', defaultValue: defaultValue);
  }

  /// 设置窗口大小
  static setWindowSize(Size size) {
    final box = Hive.box(_boxName);
    box.put('window_size', {
      'width': size.width,
      'height': size.height,
    });
  }

  /// 获取窗口大小
  static Future<Size?> getWindowSize() async {
    final box = await Hive.openBox(_boxName);
    final size = box.get('window_size');
    if (size != null) {
      return Size(size['width'], size['height']);
    }
    return null;
  }
}
