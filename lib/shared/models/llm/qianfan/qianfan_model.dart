import '../../message/message_model.dart';
import '../llm.dart';
import '../llm_form_data_item.dart';
import '../llm_type.dart';
import 'qianfan_api.dart';

class QianFanModel extends LLM {
  @override
  final LLMType type = LLMType.qianfan;

  final String url;
  final String apiKey;
  final String secretKey;

  QianFanModel({
    required super.llmId,
    required super.name,
    required super.lastUseTime,
    required this.url,
    required this.apiKey,
    required this.secretKey,
  });

  factory QianFanModel.fromJson(dynamic json) {
    return QianFanModel(
      llmId: json['llm_id'] ?? -1,
      name: json['name'],
      lastUseTime: json['last_use_time'] ?? 0,
      url: json['url'] ?? '',
      apiKey: json['api_key'] ?? '',
      secretKey: json['secret_key'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'api_key': apiKey,
      'secret_key': secretKey,
    };
  }

  /// 获取初始化表单数据
  static List<LLMFormDataItem> getInitFormData() {
    return [
      LLMFormDataItem(
        label: '类型',
        key: 'type',
        value: LLMType.qianfan.value,
        isDisabled: true,
      ),
      LLMFormDataItem(
        label: '自定义名称',
        key: 'name',
        value: '',
        isRequired: true,
      ),
      LLMFormDataItem(
        label: '请求地址（从模型的API文档中获得）',
        key: 'url',
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
        label: 'Secret Key',
        key: 'secret_key',
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
        label: '请求地址',
        key: 'url',
        value: url,
        isRequired: true,
      ),
      LLMFormDataItem(
        label: 'API Key',
        key: 'api_key',
        value: apiKey,
        isRequired: true,
      ),
      LLMFormDataItem(
        label: 'Secret Key',
        key: 'secret_key',
        value: secretKey,
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

    // 将system角色的消息，合并到第一条user角色的消息中
    final systemContent =
        messages.first.role == MessageRole.system ? messages.first.content : '';
    messages.removeWhere((element) => element.role == MessageRole.system);
    if (messages.isNotEmpty &&
        systemContent.isNotEmpty &&
        messages.first.role == MessageRole.user) {
      messages.first.content = '$systemContent\n${messages.first.content}';
    }

    return QianFanApi.chatCompletions(
      url: url,
      apiKey: apiKey,
      secretKey: secretKey,
      messages: messages,
      temperature: temperature / 2, // 千帆平台的取值范围是0-1
    );
  }

  /// 停止聊天
  @override
  cancel() {
    QianFanApi.cancel();
  }
}
