import 'package:sqlite3/sqlite3.dart';

import '../models/message/message_status.dart';
import '../models/message/message_model.dart';
import '../models/message/conversation_message_model.dart';
import '../utils/sqlite.dart';

class MessageRepository {
  static String tableName = 'message';

  static void initTable() {
    /// 创建表
    Sqlite.db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        msg_id INTEGER PRIMARY KEY AUTOINCREMENT,
        chat_app_id INTEGER NOT NULL,
        conversation_id INTEGER NOT NULL,
        role VARCHAR(16) NOT NULL,
        content TEXT,
        created_time INTEGER,
        status INTEGER NOT NULL,
        llm_id INTEGER DEFAULT 0,
        llm_name VARCHAR(32),
        generate_id INTEGER DEFAULT 0
      )
    ''');

    /// 为conversation_id添加索引
    Sqlite.db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${tableName}_conversation_id ON $tableName (conversation_id)
    ''');

    /// 为chat_app_id,msg_id添加组合索引
    Sqlite.db.execute('''
      CREATE INDEX IF NOT EXISTS idx_${tableName}_chat_app_id_msg_id ON $tableName (chat_app_id, msg_id)
    ''');

    /// 查询列名
    final result = Sqlite.db.select('PRAGMA table_info($tableName)');
    final columnNames = result.map((e) => e[1] as String).toList();

    /// 添加llm_id列
    if (!columnNames.contains('llm_id')) {
      Sqlite.db.execute('''
        ALTER TABLE $tableName ADD COLUMN llm_id INTEGER DEFAULT 0
      ''');
    }

    /// 添加llm_name列
    if (!columnNames.contains('llm_name')) {
      Sqlite.db.execute('''
        ALTER TABLE $tableName ADD COLUMN llm_name VARCHAR(32)
      ''');
    }

    /// 添加generate_id列
    if (!columnNames.contains('generate_id')) {
      Sqlite.db.execute('''
        ALTER TABLE $tableName ADD COLUMN generate_id INTEGER DEFAULT 0
      ''');
    }
  }

  /// 获取历史消息列表
  static List<int> getMessageIds(int conversationId) {
    final result = Sqlite.db.select('''
      SELECT msg_id FROM $tableName WHERE conversation_id = ? 
      ORDER BY msg_id ASC
    ''', [conversationId]);
    return result.map((msg) => msg['msg_id'] as int).toList();
  }

  /// 获取消息
  static ConversationMessageModel? getMessage(int msgId) {
    final result = Sqlite.db.select('''
      SELECT * FROM $tableName WHERE msg_id = ? LIMIT 1
    ''', [msgId]);
    if (result.isEmpty) {
      return null;
    }
    return _selectResultToModel(result.first);
  }

  /// 搜索消息
  static ConversationMessageModel? search({
    required int chatAppId,
    required String keyword,
    required int startMsgId,
    required bool isDesc,
  }) {
    final sql = '''
      SELECT * FROM $tableName 
      WHERE chat_app_id = ? AND content LIKE ? AND msg_id ${isDesc ? '<' : '>'} ? AND role != ?
      ORDER BY msg_id ${isDesc ? 'DESC' : 'ASC'}
      LIMIT 1
    ''';
    final result = Sqlite.db.select(sql, [
      chatAppId,
      '%$keyword%',
      startMsgId,
      MessageRole.system.value,
    ]);
    if (result.isEmpty) {
      return null;
    }
    return _selectResultToModel(result.first);
  }

  /// 查询结果转model
  static ConversationMessageModel _selectResultToModel(Row msg) {
    late MessageRole role;
    switch (msg['role'] as String) {
      case 'user':
        role = MessageRole.user;
        break;
      case 'assistant':
        role = MessageRole.assistant;
        break;
      case 'system':
        role = MessageRole.system;
        break;
      default:
        throw ArgumentError('未知的role: ${msg['role']}');
    }

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
      default:
        throw ArgumentError('未知的status: ${msg['status']}');
    }

    return ConversationMessageModel(
      msgId: msg['msg_id'] as int,
      chatAppId: msg['chat_app_id'] as int,
      conversationId: msg['conversation_id'] as int,
      role: role,
      content: msg['content'] as String,
      createdTime: DateTime.fromMillisecondsSinceEpoch(msg[5] as int),
      status: status,
      llmId: (msg['llm_id'] as int?) ?? 0,
      llmName: (msg['llm_name'] as String?) ?? '',
      generateId: msg['generate_id'] as int,
    );
  }

  /// 插入消息
  static ConversationMessageModel insertMessage({
    required int chatAppId,
    required int conversationId,
    required MessageRole role,
    required String content,
    required MessageStatus status,
    int llmId = 0,
    String llmName = '',
    int generateId = 0,
  }) {
    Sqlite.db.execute('''
      INSERT INTO $tableName (chat_app_id, conversation_id, role, content, created_time, status, llm_name, generate_id, llm_id)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      chatAppId,
      conversationId,
      role.value,
      content,
      DateTime.now().millisecondsSinceEpoch,
      status.value,
      llmName,
      generateId,
      llmId,
    ]);
    return getMessage(Sqlite.db.lastInsertRowId)!;
  }

  /// 更新消息
  static void updateMessage({
    required int msgId,
    String? content,
    MessageStatus? status,
    int? llmId,
    String? llmName,
    int? generateId,
  }) {
    if (content == null &&
        status == null &&
        llmId == null &&
        llmName == null &&
        generateId == null) {
      return;
    }

    List<String> setFields = [];
    List<dynamic> args = [];
    if (content != null) {
      setFields.add('content = ?');
      args.add(content);
    }
    if (status != null) {
      setFields.add('status = ?');
      args.add(status.value);
    }
    if (llmId != null) {
      setFields.add('llm_id = ?');
      args.add(llmId);
    }
    if (llmName != null) {
      setFields.add('llm_name = ?');
      args.add(llmName);
    }
    if (generateId != null) {
      setFields.add('generate_id = ?');
      args.add(generateId);
    }
    args.add(msgId);

    Sqlite.db.execute('''
      UPDATE $tableName
      SET ${setFields.join(', ')}
      WHERE msg_id = ?
    ''', args);
  }

  /// 删除消息
  static void deleteMessage({
    int? msgId,
    int? conversationId,
    int? chatAppId,
  }) {
    if (msgId == null && conversationId == null && chatAppId == null) {
      throw ArgumentError('msgId, conversationId, chatAppId不能同时为空');
    }
    if (msgId != null) {
      Sqlite.db.execute('''
        DELETE FROM $tableName
        WHERE msg_id = ?
      ''', [msgId]);
      return;
    }
    if (conversationId != null) {
      Sqlite.db.execute('''
        DELETE FROM $tableName
        WHERE conversation_id = ?
      ''', [conversationId]);
      return;
    }
    if (chatAppId != null) {
      Sqlite.db.execute('''
        DELETE FROM $tableName
        WHERE chat_app_id = ?
      ''', [chatAppId]);
      return;
    }
  }
}
