import 'package:get/get.dart';

import '../models/llm/llm.dart';
import '../models/llm/llm_type.dart';
import '../models/llm/llms.dart';
import '../repositories/llm_repository.dart';

class LLMService extends GetxService {
  /// LLM列表
  final llmList = RxList<LLM>([]);

  @override
  void onInit() {
    super.onInit();
    refreshLLMList();
  }

  /// 刷新LLM列表
  void refreshLLMList() {
    List<LLM> llms = LLMRepository.queryAll();
    llmList.assignAll(llms);
  }

  /// 添加模型,并返回模型ID
  int? addLLM(Map<dynamic, dynamic> data) {
    final type = data['type'];
    final name = data['name'];
    if (type == null || name == null) {
      return null;
    }

    final llmType =
        LLMType.values.firstWhere((element) => element.value == type);

    final id = LLMRepository.insert(llm: LLMs.fromJson(llmType, data));
    refreshLLMList();
    return id;
  }

  /// 更新模型
  /// [updatedTime] 指定更新时间，用于数据同步
  void updateLLMByData(int llmId, Map<dynamic, dynamic> data,
      {int? updatedTime}) {
    final type = data['type'];
    final llmType =
        LLMType.values.firstWhere((element) => element.value == type);
    final llm = LLMs.fromJson(llmType, data);
    llm.llmId = llmId;
    LLMRepository.update(llm, updatedTime: updatedTime);
    refreshLLMList();
  }

  /// 更新模型
  void updateLLM(LLM llm) {
    LLMRepository.update(llm);
    refreshLLMList();
  }

  /// 更新最后使用时间
  void updateLastUseTime(int llmId) {
    LLMRepository.updateLastUseTime(llmId);
    refreshLLMList();
  }

  /// 删除模型
  void deleteLLM(int llmId) {
    LLMRepository.delete(llmId);
    llmList.removeWhere((element) => element.llmId == llmId);
  }

  /// 获取模型
  LLM? getLLM(int llmId) {
    return llmList.firstWhereOrNull((element) => element.llmId == llmId);
  }

  /// 获取模型列表
  List<LLM> getLLMList() {
    return llmList.value;
  }
}
