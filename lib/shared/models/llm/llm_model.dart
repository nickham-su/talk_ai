import '../message/message_model.dart';
import 'llm_type.dart';

abstract class LLM {
  /// 模型ID
  int llmId;

  /// 模型名称
  final String name;

  /// 最后使用时间
  int lastUseTime;

  /// 模型类型
  abstract final LLMType type;

  LLM({required this.name, required this.llmId, required this.lastUseTime});

  /// 聊天
  Stream<String> chatCompletions({
    required List<MessageModel> messages,
    double temperature = 1,
    double topP = 0.95,
  });

  /// 取消请求
  cancel();

  /// 将llmId、name、type之外的数据转换为json
  Map<String, dynamic> toJson();

  /// 获取表单数据
  List<FormDataItem> getFormData();
}

class FormDataItem {
  String label;
  String key;
  String value;
  bool? isRequired;
  bool? isDisabled;

  FormDataItem({
    required this.label,
    required this.key,
    required this.value,
    this.isRequired,
    this.isDisabled,
  });
}
