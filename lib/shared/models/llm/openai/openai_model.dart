import '../llm_form_data_item.dart';
import 'openai_api.dart';
import '../llm.dart';
import '../../message/message_model.dart';
import '../llm_type.dart';

class OpenaiModel extends LLM {
  @override
  final LLMType type = LLMType.openai;

  final String url; // 服务器地址
  final String apiKey; // API 密钥
  final String model; // 模型名称
  final String stop; // 停止词

  OpenaiModel({
    required super.llmId,
    required super.name,
    required super.lastUseTime,
    required super.updatedTime,
    required super.deletedTime,
    required this.url,
    required this.apiKey,
    required this.model,
    required this.stop,
  });

  factory OpenaiModel.fromJson(dynamic json) {
    return OpenaiModel(
      llmId: json['llm_id'] ?? -1,
      name: json['name'],
      lastUseTime: json['last_use_time'] ?? 0,
      url: json['url'],
      apiKey: json['api_key'] ?? '',
      model: json['model'] ?? '',
      stop: json['stop'] ?? '',
      updatedTime: json['updated_time'] ?? 0,
      deletedTime: json['deleted_time'],
    );
  }

  /// 将llmId、name、type之外的数据转换为json
  @override
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'api_key': apiKey,
      'model': model,
      'stop': stop,
    };
  }

  /// 获取初始化表单数据
  static List<LLMFormDataItem> getInitFormData() {
    return [
      LLMFormDataItem(
        label: '类型',
        key: 'type',
        value: LLMType.openai.value,
        isDisabled: true,
      ),
      LLMFormDataItem(
        label: '自定义名称',
        key: 'name',
        value: '',
        isRequired: true,
      ),
      LLMFormDataItem(
        label: 'URL',
        key: 'url',
        value: '',
        isRequired: true,
      ),
      LLMFormDataItem(
        label: 'API Key(选填)',
        key: 'api_key',
        value: '',
      ),
      LLMFormDataItem(
        label: '模型名称(选填)',
        key: 'model',
        value: '',
      ),
      LLMFormDataItem(
        label: '停止词(选填)：多个词用逗号分隔,最多4个',
        key: 'stop',
        value: '',
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
        label: 'URL',
        key: 'url',
        value: url,
        isRequired: true,
      ),
      LLMFormDataItem(
        label: 'API Key(选填)',
        key: 'api_key',
        value: apiKey,
      ),
      LLMFormDataItem(
        label: '模型名称(选填)',
        key: 'model',
        value: model,
      ),
      LLMFormDataItem(
        label: '停止词(选填)：多个词用逗号分隔,最多4个',
        key: 'stop',
        value: stop,
      ),
    ];
  }

  /// 聊天完成
  @override
  Stream<String> chatCompletions({
    required List<MessageModel> messages,
    double temperature = 0.8,
    double topP = 0.95,
  }) {
    List<String>? stopList;
    if (stop.isNotEmpty) {
      stopList = stop.split(',').map((e) {
        // 转义字符
        return e
            .replaceAll(r'\n', '\n')
            .replaceAll(r'\t', '\t')
            .replaceAll(r'\b', '\b')
            .replaceAll(r'\r', '\r')
            .replaceAll(r'\f', '\f');
      }).toList();
    }

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

    int? maxTokens;

    // 零一万物模型的默认max_tokens太小，兼容一下
    if (model.startsWith('yi-')) {
      maxTokens = 8 * 1024;
    }

    return OpenaiApi.chatCompletions(
      url: url,
      apiKey: apiKey,
      model: model,
      messages: messages,
      temperature: temperature,
      topP: topP,
      stop: stopList,
      maxTokens: maxTokens,
    );
  }

  /// 取消请求
  @override
  cancel() {
    OpenaiApi.cancel();
  }
}
