import '../models/chat_app_model.dart';
import '../../../shared/utils/sqlite.dart';

class ChatAppRepository {
  static String tableName = 'chat_app';

  /// 创建表
  static void initTable() {
    Sqlite.db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        chat_app_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(16) NOT NULL UNIQUE,
        prompt TEXT NOT NULL,
        last_use_time INTEGER NOT NULL,
        llm_id INTEGER NOT NULL,
        temperature DOUBLE,
        top_p DOUBLE
      );
      CREATE INDEX IF NOT EXISTS idx_${tableName}_last_use_time ON chat_app (last_use_time);
    ''');
  }

  /// 新建聊天App
  static ChatAppModel insert({
    required String name,
    required String prompt,
    required int llmId,
    required double temperature,
    required double topP,
  }) {
    final lastUseTime = DateTime.now();
    Sqlite.db.execute('''
      INSERT INTO $tableName (name, prompt, last_use_time, llm_id, temperature, top_p)
      VALUES (?, ?, ?, ?, ?, ?)
    ''', [
      name,
      prompt,
      lastUseTime.millisecondsSinceEpoch,
      llmId,
      temperature,
      topP
    ]);
    final chatAppId = Sqlite.db.lastInsertRowId;
    return ChatAppModel(
      chatAppId: chatAppId,
      name: name,
      prompt: prompt,
      lastUseTime: lastUseTime,
      llmId: llmId,
      temperature: temperature,
      topP: topP,
    );
  }

  /// 查询所有聊天App
  static List<ChatAppModel> queryAll() {
    final result = Sqlite.db
        .select('SELECT * FROM $tableName ORDER BY last_use_time DESC');
    return result.map((e) {
      return ChatAppModel(
        chatAppId: e[0] as int,
        name: e[1] as String,
        prompt: e[2] as String,
        lastUseTime: DateTime.fromMillisecondsSinceEpoch(e[3] as int),
        llmId: e[4] as int,
        temperature: e[5] as double,
        topP: e[6] as double,
      );
    }).toList();
  }

  /// 更新聊天App
  static void update({
    required int chatAppId,
    required String name,
    required String prompt,
    required int llmId,
    required double temperature,
    required double topP,
  }) {
    final lastUseTime = DateTime.now();
    Sqlite.db.execute('''
      UPDATE $tableName
      SET name = ?, prompt = ?, last_use_time = ?, llm_id = ?, temperature = ?, top_p = ?
      WHERE chat_app_id = ?
    ''', [
      name,
      prompt,
      lastUseTime.millisecondsSinceEpoch,
      llmId,
      temperature,
      topP,
      chatAppId
    ]);
  }

  /// 删除聊天App
  static void delete(int chatAppId) {
    Sqlite.db
        .execute('DELETE FROM $tableName WHERE chat_app_id = ?', [chatAppId]);
  }

  /// 记录聊天App的最后一次使用时间
  static recordLastUseTime(int chatAppId) {
    final lastUseTime = DateTime.now();
    Sqlite.db.execute('''
      UPDATE $tableName
      SET last_use_time = ?
      WHERE chat_app_id = ?
    ''', [
      lastUseTime.millisecondsSinceEpoch,
      chatAppId
    ]);
  }
}
