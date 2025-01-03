import 'package:TalkAI/shared/models/llm/llm_type.dart';

import 'package:TalkAI/shared/models/message/message_model.dart';

import '../llm_form_data_item.dart';
import '../llm.dart';
import 'dash_scope_api.dart';

/// 阿里云DashScope模型
class DashScopeModel extends LLM {
  @override
  final LLMType type = LLMType.dash_scope;

  final String apiKey; // API 密钥
  final String model; // 模型名称

  DashScopeModel({
    required super.llmId,
    required super.name,
    required super.lastUseTime,
    required super.updatedTime,
    required super.deletedTime,
    required this.apiKey,
    required this.model,
  });

  factory DashScopeModel.fromJson(dynamic json) {
    return DashScopeModel(
      llmId: json['llm_id'] ?? -1,
      name: json['name'],
      lastUseTime: json['last_use_time'] ?? 0,
      apiKey: json['api_key'] ?? '',
      model: json['model'] ?? '',
      updatedTime: json['updated_time'] ?? 0,
      deletedTime: json['deleted_time'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'api_key': apiKey,
      'model': model,
    };
  }

  /// 获取初始化表单数据
  static List<LLMFormDataItem> getInitFormData() {
    return [
      LLMFormDataItem(
        label: '类型',
        key: 'type',
        value: LLMType.dash_scope.value,
        isDisabled: true,
      ),
      LLMFormDataItem(
        label: '自定义名称',
        key: 'name',
        value: '',
        isRequired: true,
      ),
      LLMFormDataItem(
        label: 'API Key',
        key: 'api_key',
        value: '',
        isRequired: true,
      ),
      LLMFormDataItem(
        label: '模型名称',
        key: 'model',
        value: '',
        isRequired: true,
      ),
    ];
  }

  /// 获取表单数据
  @override
  List<LLMFormDataItem> getFormData() {
    return [
      LLMFormDataItem(
        label: '类型',
        key: 'type',
        value: type.value,
        isDisabled: true,
      ),
      LLMFormDataItem(
        label: '自定义名称',
        key: 'name',
        value: name,
        isRequired: true,
      ),
      LLMFormDataItem(
        label: 'API Key',
        key: 'api_key',
        value: apiKey,
        isRequired: true,
      ),
      LLMFormDataItem(
        label: '模型名称',
        key: 'model',
        value: model,
        isRequired: true,
      ),
    ];
  }

  /// 聊天
  @override
  Stream<String> chatCompletions({
    required List<MessageModel> messages,
    double temperature = 0.8,
    double topP = 0.95,
  }) {
    if (messages.isEmpty) {
      throw 'messages is empty';
    }

    return DashScopeApi.chatCompletions(
      apiKey: apiKey,
      model: model,
      messages: messages,
      temperature: temperature,
    );
  }

  /// 停止聊天
  @override
  cancel() {
    DashScopeApi.cancel();
  }
}
