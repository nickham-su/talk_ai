import '../message/message_model.dart';
import 'llm_form_data_item.dart';
import 'llm_type.dart';

abstract class LLM {
  /// 模型ID
  int llmId;

  /// 模型名称
  String name;

  /// 最后使用时间
  late DateTime lastUseTime;

  /// 更新时间
  late DateTime updatedTime;

  /// 模型类型
  abstract final LLMType type;

  LLM({
    required this.name,
    required this.llmId,
    required int lastUseTime,
    required int updatedTime,
  }) {
    this.lastUseTime = DateTime.fromMillisecondsSinceEpoch(lastUseTime);
    this.updatedTime = DateTime.fromMillisecondsSinceEpoch(updatedTime);
  }

  /// 聊天
  Stream<String> chatCompletions({
    required List<MessageModel> messages,
    double temperature = 0.8,
    double topP = 0.95,
  });

  /// 取消请求
  cancel();

  /// 将llmId、name、type之外的数据转换为json
  Map<String, dynamic> toJson();

  /// 获取表单数据
  List<LLMFormDataItem> getFormData();
}
