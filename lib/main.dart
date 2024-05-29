import 'dart:io';

import 'package:TalkAI/routes.dart';
import 'package:TalkAI/shared/components/layout/controllers/layout_controller.dart';
import 'package:TalkAI/shared/repositories/create_tables.dart';
import 'package:TalkAI/shared/controllers/app_update_controller.dart';
import 'package:TalkAI/shared/services/generate_message_service.dart';
import 'package:TalkAI/shared/services/llm_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:window_manager/window_manager.dart';

import 'modules/chat/controllers/chat_app_controller.dart';
import 'shared/repositories/setting_repository.dart';
import 'shared/services/conversation_service.dart';
import 'shared/services/message_service.dart';
import 'shared/utils/app_cache_dir.dart';
import 'shared/utils/sqlite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  /// 创建TalkAI文件夹
  final appCacheDir = await getAppCacheDir();

  /// 初始化Hive，窗口位置存在Hive中，所以要先初始化Hive
  Hive.init(appCacheDir);

  /// 初始化窗口位置
  await initWindowPosition();

  /// 创建数据库
  Sqlite.openDB(appCacheDir);
  initDBTables();

  /// 注册全局控制器、服务
  Get.put(LayoutController(), permanent: true);
  Get.put(AppUpdateController(), permanent: true);
  Get.put(GenerateMessageService(), permanent: true);
  Get.put(MessageService(), permanent: true);
  Get.put(ConversationService(), permanent: true);
  final llmService = LLMService();
  Get.put(llmService, permanent: true);
  final initialRoute =
      llmService.getLLMList().isEmpty ? Routes.llm : Routes.chat;

  /// 初始化主题
  final fontFamilyFallback = ['PingFang SC', 'Microsoft YaHei', 'sans-serif'];
  var lightTheme = ThemeData.light().copyWith(
    textTheme: ThemeData.light()
        .textTheme
        .apply(fontFamilyFallback: fontFamilyFallback),
  );
  var darkTheme = ThemeData.dark().copyWith(
    textTheme: ThemeData.dark()
        .textTheme
        .apply(fontFamilyFallback: fontFamilyFallback),
  );

  /// 设置快捷键
  Map<ShortcutActivator, Intent>? shortcuts;
  if (Platform.isMacOS) {
    shortcuts = {
      LogicalKeySet(LogicalKeyboardKey.keyW, LogicalKeyboardKey.meta):
          const VoidCallbackIntent(closeWindowCallback),
      LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.meta):
          const VoidCallbackIntent(searchCallback),
    };
  }

  /// 运行APP
  runApp(FocusableActionDetector(
    shortcuts: shortcuts,
    child: GetMaterialApp(
      initialRoute: initialRoute,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: await SettingRepository.getThemeMode(),
      getPages: Routes.routes,
    ),
  ));
}

/// 关闭窗口快捷键回调
void closeWindowCallback() {
  // 延迟隐藏窗口；让快捷键弹起后再隐藏，不然下次使用快捷键有bug
  Future.delayed(const Duration(milliseconds: 400), () {
    windowManager.hide();
  });
}

/// 搜索快捷键回调
void searchCallback() {
  try {
    Get.find<ChatAppController>().toggleSearch();
  } catch (e) {}
}

/// 初始化窗口位置
Future initWindowPosition() async {
  final size =
      (await SettingRepository.getWindowSize()) ?? const Size(1000, 720);

  WindowOptions windowOptions = WindowOptions(
    center: true,
    size: size,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions);

  /// 监听窗口事件
  windowManager.addListener(MyWindowListener());
}

class MyWindowListener with WindowListener {
  @override
  void onWindowResized() async {
    /// 监听窗口大小变化，保存窗口大小
    final size = await windowManager.getSize();
    SettingRepository.setWindowSize(size);
    super.onWindowResized();
  }

  @override
  void onWindowClose() {
    /// 监听窗口关闭，退出程序
    SystemNavigator.pop();
    super.onWindowClose();
  }
}
