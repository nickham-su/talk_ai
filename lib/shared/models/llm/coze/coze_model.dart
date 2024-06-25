import 'package:TalkAI/shared/models/llm/coze/coze_api.dart';

import '../../message/message_model.dart';
import '../llm.dart';
import '../llm_form_data_item.dart';
import '../llm_type.dart';

class CozeModel extends LLM {
  @override
  final LLMType type = LLMType.coze;

  final String host; // 网址
  final String apiKey; // API 密钥
  final String botId; // botId

  CozeModel({
    required super.llmId,
    required super.name,
    required super.lastUseTime,
    required super.updatedTime,
    required this.host,
    required this.apiKey,
    required this.botId,
  });

  factory CozeModel.fromJson(dynamic json) {
    return CozeModel(
      llmId: json['llm_id'] ?? -1,
      name: json['name'],
      lastUseTime: json['last_use_time'] ?? 0,
      host: json['host'] ?? '',
      apiKey: json['api_key'] ?? '',
      botId: json['bot_id'] ?? '',
      updatedTime: json['updated_time'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'api_key': apiKey,
      'bot_id': botId,
    };
  }

  /// 获取初始化表单数据
  static List<LLMFormDataItem> getInitFormData() {
    return [
      LLMFormDataItem(
        label: '类型',
        key: 'type',
        value: LLMType.coze.value,
        isDisabled: true,
      ),
      LLMFormDataItem(
        label: '自定义名称',
        key: 'name',
        value: '',
        isRequired: true,
      ),
      LLMFormDataItem(
        label: '网址',
        key: 'host',
        value: 'coze.cn',
        options: ['coze.cn', 'coze.com'],
        isRequired: true,
      ),
      LLMFormDataItem(
        label: 'API Key',
        key: 'api_key',
        value: '',
        isRequired: true,
      ),
      LLMFormDataItem(
        label: 'Bot ID',
        key: 'bot_id',
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
        label: '网址',
        key: 'host',
        value: host,
        isRequired: true,
      ),
      LLMFormDataItem(
        label: 'API Key',
        key: 'api_key',
        value: apiKey,
        isRequired: true,
      ),
      LLMFormDataItem(
        label: 'Bot ID',
        key: 'bot_id',
        value: botId,
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

    return CozeApi.chatCompletions(
      url: host == 'coze.cn'
          ? 'https://api.coze.cn/open_api/v2/chat'
          : 'https://api.coze.com/open_api/v2/chat',
      apiKey: apiKey,
      botId: botId,
      messages: messages,
    );
  }

  /// 停止聊天
  @override
  cancel() {
    CozeApi.cancel();
  }
}
