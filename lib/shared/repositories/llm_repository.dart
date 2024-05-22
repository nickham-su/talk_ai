import 'dart:convert';

import 'package:get/get.dart';

import '../models/llm/aliyun_qwen/aliyun_qwen_model.dart';
import '../models/llm/llm.dart';
import '../models/llm/llm_type.dart';
import '../models/llm/llms.dart';
import '../models/llm/openai/openai_model.dart';
import '../utils/sqlite.dart';

class LLMRepository {
  static String tableName = 'llm';

  /// 创建表
  static void initTable() {
    Sqlite.db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        llm_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(32) NOT NULL UNIQUE,
        type VARCHAR(32) NOT NULL,
        model_fields TEXT NOT NULL,
        last_use_time INTEGER DEFAULT 0
      );
    ''');

    /// 查询列名
    final result = Sqlite.db.select('PRAGMA table_info($tableName)');
    final columnNames = result.map((e) => e[1] as String).toList();

    /// 添加last_use_time列
    if (!columnNames.contains('last_use_time')) {
      Sqlite.db.execute('''
        ALTER TABLE $tableName
        ADD COLUMN last_use_time INTEGER DEFAULT 0;
      ''');
    }
  }

  /// 创建模型
  static int insert({
    required LLM llm,
  }) {
    try {
      Sqlite.db.execute('''
      INSERT INTO $tableName (name, type, model_fields, last_use_time)
      VALUES (?, ?, ?, ?)
    ''', [
        llm.name,
        llm.type.value,
        jsonEncode(llm.toJson()),
        DateTime.now().millisecondsSinceEpoch,
      ]);
    } catch (e) {
      throw '模型保存失败，请检查模型名称是否重复：\n${llm.name}';
    }
    return Sqlite.db.lastInsertRowId;
  }

  /// 查询所有模型
  static List<LLM> queryAll() {
    final result = Sqlite.db
        .select('SELECT * FROM $tableName ORDER BY last_use_time DESC');

    List<LLM?> list = result.map((e) {
      final type = e['type'] as String;
      Map<String, dynamic> json = jsonDecode(e['model_fields'] as String);
      json['llm_id'] = e['llm_id'] as int;
      json['name'] = e['name'] as String;
      json['last_use_time'] = (e['last_use_time'] as int?) ?? 0;
      final llmType =
          LLMType.values.firstWhereOrNull((element) => element.value == type);
      if (llmType == null) {
        return null;
      }
      return LLMs.fromJson(llmType, json);
    }).toList();

    List<LLM> llmList = [];
    for (var item in list) {
      if (item != null) {
        llmList.add(item);
      }
    }

    return llmList;
  }

  /// 更新模型
  static void update(LLM llm) {
    Sqlite.db.execute('''
      UPDATE $tableName
      SET name = ?, model_fields = ?, last_use_time = ?
      WHERE llm_id = ?
    ''', [
      llm.name,
      jsonEncode(llm.toJson()),
      DateTime.now().millisecondsSinceEpoch,
      llm.llmId,
    ]);
  }

  /// 更新最后使用时间
  static void updateLastUseTime(int llmId) {
    Sqlite.db.execute('''
      UPDATE $tableName
      SET last_use_time = ?
      WHERE llm_id = ?
    ''', [
      DateTime.now().millisecondsSinceEpoch,
      llmId,
    ]);
  }

  /// 删除模型
  static void delete(int llmId) {
    Sqlite.db.execute('''
      DELETE FROM $tableName
      WHERE llm_id = ?
    ''', [llmId]);
  }
}
