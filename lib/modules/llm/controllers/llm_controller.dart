import 'dart:async';

import 'package:get/get.dart';

import '../../../shared/models/llm/llm_model.dart';
import '../../../shared/models/llm/llm_type.dart';
import '../../../shared/models/llm/openai/openai_model.dart';
import '../../../shared/services/llm_service.dart';

class LLMController extends GetxController {
  /// 当前选中的LLM的index
  final currentId = RxInt(-1);

  /// 表单数据
  RxList<FormDataItem> formData = RxList<FormDataItem>([]);

  /// LLM服务
  final llmService = Get.find<LLMService>();

  /// 是否是编辑状态
  get isEdit => currentId.value != -1 && formData.isNotEmpty;

  /// 是否是创建状态
  get isCreate => currentId.value == -1 && formData.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    if (llmService.getLLMList().isEmpty) {
      Future.delayed(Duration.zero, () {
        addLLM(LLMType.openai);
      });
    }
  }

  /// 改变index
  void changeIndex(int id) {
    currentId.value = id;
    formData.clear();
    Timer(const Duration(milliseconds: 16), () {
      final llm = llmService.getLLM(id);
      if (llm != null) {
        formData.assignAll(llm.getFormData());
      }
    });
  }

  /// 创建LLM
  void addLLM(LLMType type) {
    currentId.value = -1;
    formData.clear();
    switch (type) {
      case LLMType.openai:
        Timer(const Duration(milliseconds: 16), () {
          formData.assignAll(OpenaiModel.getInitFormData());
        });
        break;
    }
  }

  /// 创建LLM
  void createLLM() {
    Map<String, String> data = {};
    for (var item in formData) {
      data[item.key] = item.value;
    }

    // 添加LLM
    final id = llmService.addLLM(data);
    if (id == null) {
      return;
    }
    // 选中新建的LLM
    currentId.value = id;
  }

  /// 编辑LLM
  void editLLM() {
    final llm = llmService.getLLM(currentId.value);
    if (llm == null) {
      return;
    }
    Map<String, String> map = {};
    for (var item in formData) {
      map[item.key] = item.value;
    }
    llmService.updateLLM(llm.llmId, map);
  }

  /// 复制LLM
  void copyLLM() {
    Map<String, String> data = {};
    for (var item in formData) {
      data[item.key] = item.value;
      if (item.key == 'name') {
        data[item.key] = '${item.value}-副本';
      }
    }

    // 添加LLM
    final id = llmService.addLLM(data);
    if (id == null) {
      return;
    }
    // 选中新建的LLM
    changeIndex(id);
  }

  /// 删除LLM
  void deleteLLM() {
    final llm = llmService.getLLM(currentId.value);
    if (llm == null) {
      return;
    }
    llmService.deleteLLM(llm);
    formData.clear();
  }
}
