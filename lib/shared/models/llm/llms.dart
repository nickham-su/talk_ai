import 'coze/coze_model.dart';
import 'dash_scope/dash_scope_model.dart';
import 'llm_form_data_item.dart';
import 'llm.dart';
import 'llm_type.dart';
import 'openai/openai_model.dart';
import 'qianfan/qianfan_model.dart';

class LLMs {
  /// 获取初始化表单数据
  static List<LLMFormDataItem> getInitFormData(LLMType type) {
    switch (type) {
      case LLMType.openai:
        return OpenaiModel.getInitFormData();
      case LLMType.dash_scope:
        return DashScopeModel.getInitFormData();
      case LLMType.qianfan:
        return QianFanModel.getInitFormData();
      case LLMType.coze:
        return CozeModel.getInitFormData();
    }
  }

  /// 从json中解析
  static LLM fromJson(LLMType type, dynamic json) {
    switch (type) {
      case LLMType.openai:
        return OpenaiModel.fromJson(json);
      case LLMType.dash_scope:
        return DashScopeModel.fromJson(json);
      case LLMType.qianfan:
        return QianFanModel.fromJson(json);
      case LLMType.coze:
        return CozeModel.fromJson(json);
    }
  }
}
