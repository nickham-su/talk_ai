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
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:window_manager/window_manager.dart';

import 'modules/setting/repositorys/setting_repository.dart';
import 'shared/utils/sqlite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  /// 创建TalkAI文件夹
  final dir = await getApplicationDocumentsDirectory();
  final talkAIDir = path.join(dir.path, 'TalkAI');
  final talkAIDirFile = Directory(talkAIDir);
  if (!talkAIDirFile.existsSync()) {
    talkAIDirFile.createSync();
  }
  print('talkAIDir:$talkAIDir');

  /// 初始化Hive、Sqlite
  Hive.init(talkAIDir);
  Sqlite.openDB(talkAIDir);
  initDBTables();

  /// 注册全局控制器、服务
  Get.put(LayoutController(), permanent: true);
  Get.put(GenerateMessageService(), permanent: true);
  Get.put(AppUpdateController(), permanent: true);
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

  /// 运行APP
  runApp(FocusableActionDetector(
    shortcuts: {
      LogicalKeySet(LogicalKeyboardKey.keyW, LogicalKeyboardKey.meta):
          const VoidCallbackIntent(callbackCommandW),
    },
    child: GetMaterialApp(
      initialRoute: initialRoute,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: await SettingRepository.getThemeMode(),
      getPages: Routes.routes,
    ),
  ));
}

/// 快捷键command+W回调
void callbackCommandW() {
  // 延迟隐藏窗口；让快捷键弹起后再隐藏，不然下次使用快捷键有bug
  Future.delayed(const Duration(milliseconds: 400), () {
    // 仅macOS下支持
    if (Platform.isMacOS) {
      windowManager.hide();
    }
  });
}
