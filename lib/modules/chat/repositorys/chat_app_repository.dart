import 'dart:typed_data';

import '../models/chat_app_model.dart';
import '../../../shared/utils/sqlite.dart';
import 'chat_app_picture_repository.dart';

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
        top_p DOUBLE,
        topping_time INTEGER DEFAULT 0,
        multiple_round INTEGER DEFAULT 1,
        updated_time INTEGER DEFAULT 0,
        deleted_time INTEGER DEFAULT 0
      );
    ''');

    /// 查询列名
    final result = Sqlite.db.select('PRAGMA table_info($tableName)');
    final columnNames = result.map((e) => e[1] as String).toList();

    /// 添加topping_time列
    if (!columnNames.contains('topping_time')) {
      Sqlite.db.execute('''
        ALTER TABLE $tableName ADD COLUMN topping_time INTEGER DEFAULT 0
      ''');
    }

    /// 添加multiple_round列
    if (!columnNames.contains('multiple_round')) {
      Sqlite.db.execute('''
        ALTER TABLE $tableName ADD COLUMN multiple_round INTEGER DEFAULT 1
      ''');
    }

    /// 添加updated_time列
    if (!columnNames.contains('updated_time')) {
      Sqlite.db.execute('''
        ALTER TABLE $tableName ADD COLUMN updated_time INTEGER DEFAULT 0
      ''');
    }

    /// 添加deleted_time列
    if (!columnNames.contains('deleted_time')) {
      Sqlite.db.execute('''
        ALTER TABLE $tableName ADD COLUMN deleted_time INTEGER DEFAULT 0
      ''');
    }
  }

  /// 新建聊天App
  static ChatAppModel insert({
    required String name,
    required String prompt,
    required double temperature,
    required bool multipleRound, // 是否多轮对话
    double topP = 0.95, // 默认top_p
    int llmId = 0, // 默认模型id，0表示没有设置默认模型
    Uint8List? profilePicture,
    int? updatedTime,
    int? deletedTime,
  }) {
    // 如果存在已删除的同名助理，则先物理删除
    final result = Sqlite.db.select('''
      SELECT chat_app_id FROM $tableName
      WHERE name = ? AND deleted_time != 0
    ''', [name]);
    if (result.isNotEmpty){
      final chatAppId = result[0]['chat_app_id'] as int;
      Sqlite.db.execute('DELETE FROM $tableName WHERE chat_app_id = ?', [chatAppId]);
      ChatAppPictureRepository.delete(chatAppId);
    }

    // 插入新的助理
    final now = DateTime.now();
    Sqlite.db.execute('''
      INSERT INTO $tableName (name, prompt, last_use_time, llm_id, temperature, top_p, multiple_round, updated_time, deleted_time)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      name,
      prompt,
      now.millisecondsSinceEpoch,
      llmId,
      temperature,
      topP,
      multipleRound ? 1 : 0,
      updatedTime ?? now.millisecondsSinceEpoch,
      deletedTime ?? 0,
    ]);
    final chatAppId = Sqlite.db.lastInsertRowId;

    if (profilePicture != null) {
      ChatAppPictureRepository.insertOrUpdate(chatAppId, profilePicture);
    }

    return ChatAppModel(
      chatAppId: chatAppId,
      name: name,
      prompt: prompt,
      lastUseTime: now,
      temperature: temperature,
      topP: topP,
      toppingTime: DateTime.fromMillisecondsSinceEpoch(0),
      llmId: llmId,
      multipleRound: multipleRound,
      profilePicture: profilePicture,
      updatedTime: now,
      deletedTime: deletedTime == null || deletedTime == 0
          ? null
          : DateTime.fromMillisecondsSinceEpoch(deletedTime),
    );
  }

  /// 查询所有聊天App，置顶时间+最后使用时间降序
  static List<ChatAppModel> queryAll({bool withoutDeleted = true}) {
    final result = Sqlite.db.select(
        'SELECT * FROM $tableName ${withoutDeleted ? 'WHERE deleted_time = 0' : ''} ORDER BY topping_time DESC, last_use_time DESC');
    return result.map((e) {
      return ChatAppModel(
        chatAppId: e['chat_app_id'] as int,
        name: e['name'] as String,
        prompt: e['prompt'] as String,
        lastUseTime:
            DateTime.fromMillisecondsSinceEpoch(e['last_use_time'] as int),
        temperature: e['temperature'] as double,
        topP: e['top_p'] as double,
        toppingTime:
            DateTime.fromMillisecondsSinceEpoch(e['topping_time'] as int),
        llmId: e['llm_id'] as int,
        multipleRound: e['multiple_round'] == 1,
        updatedTime:
            DateTime.fromMillisecondsSinceEpoch(e['updated_time'] as int),
        deletedTime: e['deleted_time'] == 0
            ? null
            : DateTime.fromMillisecondsSinceEpoch(e['deleted_time'] as int),
        profilePicture:
            ChatAppPictureRepository.getPicture(e['chat_app_id'] as int),
      );
    }).toList();
  }

  /// 根据ID查询聊天App
  static ChatAppModel? queryById(int chatAppId) {
    final result = Sqlite.db.select('''
      SELECT * FROM $tableName
      WHERE chat_app_id = ?
    ''', [chatAppId]);

    if (result.isEmpty) {
      return null;
    }

    final e = result[0];
    return ChatAppModel(
      chatAppId: e['chat_app_id'] as int,
      name: e['name'] as String,
      prompt: e['prompt'] as String,
      lastUseTime:
          DateTime.fromMillisecondsSinceEpoch(e['last_use_time'] as int),
      temperature: e['temperature'] as double,
      topP: e['top_p'] as double,
      toppingTime:
          DateTime.fromMillisecondsSinceEpoch(e['topping_time'] as int),
      llmId: e['llm_id'] as int,
      multipleRound: e['multiple_round'] == 1,
      updatedTime:
          DateTime.fromMillisecondsSinceEpoch(e['updated_time'] as int),
      deletedTime: e['deleted_time'] == 0
          ? null
          : DateTime.fromMillisecondsSinceEpoch(e['deleted_time'] as int),
      profilePicture:
          ChatAppPictureRepository.getPicture(e['chat_app_id'] as int),
    );
  }

  /// 更新聊天App
  static void update({
    required int chatAppId,
    required String name,
    required String prompt,
    required double temperature,
    required int llmId,
    required bool multipleRound,
    Uint8List? profilePicture,
    int? updatedTime,
    int? deletedTime,
  }) {
    final now = DateTime.now();
    Sqlite.db.execute('''
      UPDATE $tableName
      SET name = ?, prompt = ?, last_use_time = ?, temperature = ?, llm_id = ?, multiple_round = ?, updated_time = ?, deleted_time = ?
      WHERE chat_app_id = ?
    ''', [
      name,
      prompt,
      now.millisecondsSinceEpoch,
      temperature,
      llmId,
      multipleRound ? 1 : 0,
      updatedTime ?? now.millisecondsSinceEpoch,
      deletedTime ?? 0,
      chatAppId
    ]);

    if (profilePicture != null) {
      ChatAppPictureRepository.insertOrUpdate(chatAppId, profilePicture);
    } else {
      ChatAppPictureRepository.delete(chatAppId);
    }
  }

  /// 删除聊天App
  static void delete(int chatAppId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    Sqlite.db.execute('''
      UPDATE $tableName
      SET updated_time = ?, deleted_time = ?
      WHERE chat_app_id = ?
    ''', [now, now, chatAppId]);
    ChatAppPictureRepository.delete(chatAppId);
  }

  /// 记录聊天App的最后一次使用时间
  static recordLastUseTime(int chatAppId) {
    final lastUseTime = DateTime.now();
    Sqlite.db.execute('''
      UPDATE $tableName
      SET last_use_time = ?
      WHERE chat_app_id = ?
    ''', [lastUseTime.millisecondsSinceEpoch, chatAppId]);
  }

  /// 置顶聊天App
  static void top(int chatAppId) {
    final now = DateTime.now();
    Sqlite.db.execute('''
      UPDATE $tableName
      SET topping_time = ?, last_use_time = ?
      WHERE chat_app_id = ?
    ''', [now.millisecondsSinceEpoch, now.millisecondsSinceEpoch, chatAppId]);
  }

  /// 取消置顶聊天App
  static void unTop(int chatAppId) {
    final now = DateTime.now();
    Sqlite.db.execute('''
      UPDATE $tableName
      SET topping_time = 0, last_use_time = ?
      WHERE chat_app_id = ?
    ''', [now.millisecondsSinceEpoch, chatAppId]);
  }
}
