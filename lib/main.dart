import 'dart:io';

import 'package:auto_updater/auto_updater.dart';
import 'package:flutter/foundation.dart';
import 'package:talk_ai/routes.dart';
import 'package:talk_ai/shared/components/layout/controllers/layout_controller.dart';
import 'package:talk_ai/shared/repositories/create_tables.dart';
import 'package:talk_ai/shared/services/generate_message_service.dart';
import 'package:talk_ai/shared/services/llm_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'modules/setting/repositorys/setting_repository.dart';
import 'shared/utils/sqlite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kReleaseMode) {
    const feedURL =
        'https://github.com/nickham-su/talk_ai/releases/latest/download/appcast.xml';
    await autoUpdater.setFeedURL(feedURL);
    await autoUpdater.checkForUpdates();
  }

  final dir = await getApplicationDocumentsDirectory();

  // 创建talk_ai文件夹
  final talkAIDir = path.join(dir.path, 'talk_ai');
  final talkAIDirFile = Directory(talkAIDir);
  if (!talkAIDirFile.existsSync()) {
    talkAIDirFile.createSync();
  }
  print('talkAIDir:$talkAIDir');

  Hive.init(talkAIDir);
  Sqlite.openDB(talkAIDir);
  initDBTables();

  // 注册全局控制器、服务
  Get.put(LayoutController(), permanent: true);
  Get.put(GenerateMessageService(), permanent: true);
  final llmService = LLMService();
  Get.put(llmService, permanent: true);

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

  runApp(GetMaterialApp(
    initialRoute: llmService.getLLMList().isEmpty ? Routes.llm : Routes.chat,
    theme: lightTheme,
    darkTheme: darkTheme,
    themeMode: await SettingRepository.getThemeMode(),
    getPages: Routes.routes,
  ));
}
