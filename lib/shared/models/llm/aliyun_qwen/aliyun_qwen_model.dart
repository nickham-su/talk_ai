import 'package:TalkAI/shared/models/llm/llm_type.dart';

import 'package:TalkAI/shared/models/message/message_model.dart';

import '../llm_model.dart';
import 'aliyun_qwen_api.dart';

/// 阿里云通义千问模型
class ALiYunQwenModel extends LLM {
  @override
  final LLMType type = LLMType.aliyunQwen;

  final String apiKey; // API 密钥
  final String model; // 模型名称

  ALiYunQwenModel({
    required super.llmId,
    required super.name,
    required super.lastUseTime,
    required this.apiKey,
    required this.model,
  });

  factory ALiYunQwenModel.fromJson(dynamic json) {
    return ALiYunQwenModel(
      llmId: json['llm_id'] ?? -1,
      name: json['name'],
      lastUseTime: json['last_use_time'] ?? 0,
      apiKey: json['api_key'] ?? '',
      model: json['model'] ?? '',
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
  static List<FormDataItem> getInitFormData() {
    return [
      FormDataItem(
        label: '类型',
        key: 'type',
        value: LLMType.aliyunQwen.value,
        isDisabled: true,
      ),
      FormDataItem(
        label: '自定义名称',
        key: 'name',
        value: '',
        isRequired: true,
      ),
      FormDataItem(
        label: 'API Key',
        key: 'api_key',
        value: '',
        isRequired: true,
      ),
      FormDataItem(
        label: '模型名称',
        key: 'model',
        value: '',
        isRequired: true,
      ),
    ];
  }

  /// 获取表单数据
  @override
  List<FormDataItem> getFormData() {
    return [
      FormDataItem(
        label: '类型',
        key: 'type',
        value: type.value,
        isDisabled: true,
      ),
      FormDataItem(
        label: '自定义名称',
        key: 'name',
        value: name,
        isRequired: true,
      ),
      FormDataItem(
        label: 'API Key',
        key: 'api_key',
        value: apiKey,
        isRequired: true,
      ),
      FormDataItem(
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
    double temperature = 1,
    double topP = 0.95,
  }) {
    if (messages.isEmpty) {
      throw 'messages is empty';
    }

    return ALiYunQwenApi.chatCompletions(
      apiKey: apiKey,
      model: model,
      messages: messages,
      temperature: temperature,
    );
  }

  /// 停止聊天
  @override
  cancel() {
    ALiYunQwenApi.cancel();
  }
}
