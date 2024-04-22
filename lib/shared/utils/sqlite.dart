import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';
import 'dart:io';

/// 数据库基类
class Sqlite {
  static String dbFile = 'chat_box.db';
  static late String dbDir;
  static late Database db;

  /// 初始化数据库
  static void openDB(String dir) {
    dbDir = dir;
    final filePath = path.join(dir, dbFile);
    db = sqlite3.open(filePath);
  }

  static dispose() {
    db.dispose();
  }

  /// 清空数据库
  static resetDB() {
    // 断开数据库连接
    db.dispose();
    // 删除数据库文件
    final filePath = path.join(dbDir, dbFile);
    File file = File(filePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    // 重新连接数据库
    openDB(dbDir);
  }
}
