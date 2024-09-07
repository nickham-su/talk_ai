import '../utils/sqlite.dart';

class MessageFileRepository {
  static String tableName = 'message_file';

  static void initTable() {
    /// 创建表
    Sqlite.db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        msg_file_id INTEGER PRIMARY KEY AUTOINCREMENT,
        msg_id INTEGER NOT NULL,
        file_path TEXT NOT NULL
      )
    ''');

    /// 为msg_id添加索引
    Sqlite.db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${tableName}_msg_id ON $tableName (msg_id)
    ''');
  }

  /// 获取消息文件
  static List<String> getMessageFile(int msgId) {
    final result = Sqlite.db.select(
      'SELECT file_path FROM $tableName WHERE msg_id = ?',
      [msgId],
    );
    return result.map((e) => e['file_path'] as String).toList();
  }

  /// 批量添加消息文件
  static void addMessageFiles(int msgId, List<String> filePaths) {
    final values = filePaths.map((e) => '($msgId, $e)').join(',');
    Sqlite.db.execute(
      'INSERT INTO $tableName (msg_id, file_path) VALUES $values',
    );
  }

  /// 删除消息文件
  static void deleteMessageFile(int msgId, String filePath) {
    Sqlite.db.execute(
      'DELETE FROM $tableName WHERE msg_id = ? AND file_path = ?',
      [msgId, filePath],
    );
  }
}
