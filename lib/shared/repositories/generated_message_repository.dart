import 'package:sqlite3/sqlite3.dart';

import '../models/message/message_status.dart';
import '../models/message/generated_message.dart';
import '../utils/sqlite.dart';

class GeneratedMessageRepository {
  static String tableName = 'generated_message';

  static void initTable() {
    /// 创建表
    Sqlite.db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        generate_id INTEGER PRIMARY KEY AUTOINCREMENT,
        msg_id INTEGER NOT NULL,
        chat_app_id INTEGER NOT NULL,
        llm_id INTEGER NOT NULL,
        llm_name VARCHAR(32),
        status INTEGER NOT NULL,
        content TEXT,
        error TEXT
      )
    ''');

    /// 为msg_id添加索引
    Sqlite.db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${tableName}_msg_id ON $tableName (msg_id)
    ''');

    /// 为chat_app_id添加索引
    Sqlite.db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${tableName}_chat_app_id ON $tableName (chat_app_id)
    ''');
  }

  /// 获取生成的消息列表
  static List<GeneratedMessage> getGeneratedMessageList(int msgId) {
    final result = Sqlite.db.select('''
      SELECT * FROM $tableName WHERE msg_id = ? 
      ORDER BY generate_id ASC
    ''', [msgId]);
    return result.map((msg) => _selectResultToModel(msg)).toList();
  }

  /// 获取生成的消息
  static GeneratedMessage? getGeneratedMessage(int generateId) {
    final result = Sqlite.db.select('''
      SELECT * FROM $tableName WHERE generate_id = ?
    ''', [generateId]);
    if (result.isEmpty) {
      return null;
    }
    return _selectResultToModel(result.first);
  }

  /// 查询结果转model
  static GeneratedMessage _selectResultToModel(Row msg) {
    late MessageStatus status;
    switch (msg['status'] as int) {
      case 1:
        status = MessageStatus.unsent;
        break;
      case 2:
        status = MessageStatus.sending;
        break;
      case 3:
        status = MessageStatus.completed;
        break;
      case 4:
        status = MessageStatus.failed;
        break;
      case 5:
        status = MessageStatus.cancel;
        break;
      default:
        throw Exception('未知的消息状态: ${msg['status']}');
    }

    return GeneratedMessage(
      generateId: msg['generate_id'] as int,
      msgId: msg['msg_id'] as int,
      chatAppId: msg['chat_app_id'] as int,
      llmId: msg['llm_id'] as int,
      llmName: msg['llm_name'] as String,
      status: status,
      content: msg['content'] as String,
      error: msg['error'] as String,
    );
  }

  /// 插入生成的消息
  static GeneratedMessage insert({
    required int msgId,
    required int chatAppId,
    required int llmId,
    required String llmName,
    required MessageStatus status,
    required String content,
    String error = '',
  }) {
    Sqlite.db.execute('''
      INSERT INTO $tableName (msg_id, chat_app_id, llm_id, llm_name, status, content, error)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', [
      msgId,
      chatAppId,
      llmId,
      llmName,
      status.value,
      content,
      error,
    ]);
    return GeneratedMessage(
      generateId: Sqlite.db.lastInsertRowId,
      msgId: msgId,
      chatAppId: chatAppId,
      llmId: llmId,
      llmName: llmName,
      status: status,
      content: content,
      error: error,
    );
  }

  /// 更新生成的消息
  static void update({
    required int generateId,
    MessageStatus? status,
    String? content,
    String? error,
  }) {
    if (status == null && content == null && error == null) {
      return;
    }
    List<String> setFields = [];
    List<dynamic> args = [];
    if (status != null) {
      setFields.add('status = ?');
      args.add(status.value);
    }
    if (content != null) {
      setFields.add('content = ?');
      args.add(content);
    }
    if (error != null) {
      setFields.add('error = ?');
      args.add(error);
    }
    args.add(generateId);
    Sqlite.db.execute('''
      UPDATE $tableName 
      SET ${setFields.join(', ')} 
      WHERE generate_id = ?
    ''', args);
  }

  /// 删除生成的消息
  static void delete(int generateId) {
    Sqlite.db.execute('''
      DELETE FROM $tableName WHERE generate_id = ?
    ''', [generateId]);
  }

  /// 根据msgId删除生成的消息
  static void deleteByMsgId(int msgId) {
    Sqlite.db.execute('''
      DELETE FROM $tableName WHERE msg_id = ?
    ''', [msgId]);
  }

  /// 根据chatAppId删除生成的消息
  static void deleteByChatAppId(int chatAppId) {
    Sqlite.db.execute('''
      DELETE FROM $tableName WHERE chat_app_id = ?
    ''', [chatAppId]);
  }
}
