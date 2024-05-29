import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

String? appCacheDir;

/// 创建文件夹
Future<String> getAppCacheDir() async {
  if (appCacheDir != null) {
    return appCacheDir!;
  }
  final dir = await getApplicationDocumentsDirectory();
  final oldTalkAIDir = Directory(path.join(dir.path, 'TalkAI'));
  final newTalkAIDir = Directory(path.join(dir.path, '.TalkAI'));
  if (oldTalkAIDir.existsSync() && !newTalkAIDir.existsSync()) {
    // 将TalkAI文件夹重命名为.TalkAI
    oldTalkAIDir.renameSync(newTalkAIDir.path);
  } else if (!oldTalkAIDir.existsSync() && !newTalkAIDir.existsSync()) {
    // 创建.TalkAI文件夹
    newTalkAIDir.createSync();
  }
  appCacheDir = newTalkAIDir.path;
  return appCacheDir!;
}
