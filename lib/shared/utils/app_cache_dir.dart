import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

String? appCacheDir;

/// 创建文件夹
Future<String> getAppCacheDir() async {
  if (appCacheDir != null) {
    return appCacheDir!;
  }

  // TODO: 2024.07.31以后，去掉文件夹迁移逻辑
  final docDir = await getApplicationDocumentsDirectory();
  final oldTalkAIDir = Directory(path.join(docDir.path, '.TalkAI'));

  final cacheDir = await getApplicationCacheDirectory();
  final newTalkAIDir = Directory(path.join(cacheDir.path, 'app_data'));

  if (oldTalkAIDir.existsSync() && !newTalkAIDir.existsSync()) {
    // 移动.TalkAI文件夹
    oldTalkAIDir.renameSync(newTalkAIDir.path);
  } else if (!oldTalkAIDir.existsSync() && !newTalkAIDir.existsSync()) {
    // 创建.TalkAI文件夹
    newTalkAIDir.createSync();
  }
  appCacheDir = newTalkAIDir.path;
  return appCacheDir!;
}

String getAppCacheDirSync() {
  return appCacheDir!;
}
