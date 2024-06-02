import 'dart:convert';
import 'dart:typed_data';

import '../../../shared/utils/sqlite.dart';

class ChatAppPictureRepository {
  /// 表名
  static String tableName = 'chat_app_picture';

  /// 图片缓存
  static Map<int, Uint8List> pictureCache = {};

  /// 创建表
  static void initTable() {
    Sqlite.db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        chat_app_id INTEGER PRIMARY KEY,
        picture BLOB NOT NULL
      )
    ''');
  }

  /// 新建助理图片
  static void insertOrUpdate(int chatAppId, Uint8List picture) {
    Sqlite.db.execute('''
      INSERT OR REPLACE INTO $tableName (chat_app_id, picture)
      VALUES (?, ?)
    ''', [chatAppId, picture]);
    pictureCache[chatAppId] = picture;
  }

  /// 删除助理图片
  static void delete(int chatAppId) {
    Sqlite.db.execute('''
      DELETE FROM $tableName
      WHERE chat_app_id = ?
    ''', [chatAppId]);

    pictureCache.remove(chatAppId);
  }

  /// 获取助理图片
  static Uint8List? getPicture(int chatAppId) {
    if (pictureCache.containsKey(chatAppId)) return pictureCache[chatAppId];

    final result = Sqlite.db.select('''
      SELECT picture
      FROM $tableName
      WHERE chat_app_id = ?
    ''', [chatAppId]);
    if (result.isEmpty) return null;

    final picture = result.first['picture'] as Uint8List;
    pictureCache[chatAppId] = picture;
    return picture;
  }
}
