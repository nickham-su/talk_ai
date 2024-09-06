import 'package:sqlite3/common.dart';

import '../models/conversation_model.dart';
import '../../../shared/utils/sqlite.dart';
import '../../../shared/repositories/message_repository.dart';

class ConversationRepository {
  static String tableName = 'conversation';

  /// 创建表
  static void initTable() {
    /// 创建表
    Sqlite.db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        conversation_id INTEGER PRIMARY KEY AUTOINCREMENT,
        chat_app_id INTEGER,
        created_time INTEGER,
        updated_time INTEGER
      )
    ''');

    /// 为chat_app_id、updated_time添加组合索引
    Sqlite.db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${tableName}_chat_app_id_updated_time
      ON $tableName (chat_app_id, updated_time)
    ''');
  }

  /// 获取所有会话ID，最多2000个
  static List<int> getAllConversationIds(int chatAppId) {
    final result = Sqlite.db.select('''
        SELECT conversation_id FROM $tableName
        WHERE chat_app_id = ?
        ORDER BY updated_time DESC
        LIMIT 2000
      ''', [chatAppId]);
    return result.map((e) => e[0] as int).toList().reversed.toList();
  }

  /// 获取会话
  static ConversationModel? getConversation(int conversationId) {
    final result = Sqlite.db.select('''
      SELECT *
      FROM $tableName
      WHERE conversation_id = ?
    ''', [conversationId]);
    if (result.isEmpty) {
      return null;
    }
    final conversation = result[0];
    return ConversationModel(
      conversationId: conversation[0] as int,
      chatAppId: conversation[1] as int,
      createdTime: DateTime.fromMillisecondsSinceEpoch(conversation[2] as int),
      updatedTime: DateTime.fromMillisecondsSinceEpoch(conversation[3] as int),
    );
  }

  /// 插入会话
  static ConversationModel insertConversation(int chatAppId) {
    final createdTime = DateTime.now().millisecondsSinceEpoch;
    Sqlite.db.execute('''
      INSERT INTO $tableName (chat_app_id, created_time, updated_time)
      VALUES (?, ?, ?)
    ''', [chatAppId, createdTime, createdTime]);
    return getConversation(Sqlite.db.lastInsertRowId)!;
  }

  /// 删除会话
  static void deleteConversation({
    int? conversationId,
    int? chatAppId,
  }) {
    if (conversationId == null && chatAppId == null) {
      throw ArgumentError('conversationId和chatAppId不能同时为空');
    }
    if (conversationId != null) {
      Sqlite.db.execute('''
        DELETE FROM $tableName
        WHERE conversation_id = ?
      ''', [conversationId]);
    } else {
      Sqlite.db.execute('''
        DELETE FROM $tableName
        WHERE chat_app_id = ?
      ''', [chatAppId]);
    }
  }

  /// 更新会话updated_time
  static void updateConversationTime(int conversationId) {
    final updatedTime = DateTime.now().millisecondsSinceEpoch;
    Sqlite.db.execute('''
      UPDATE $tableName
      SET updated_time = ?
      WHERE conversation_id = ?
    ''', [updatedTime, conversationId]);
  }
}
