import 'dart:async';

import 'package:get/get.dart';

import '../../../shared/components/snackbar.dart';
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

  /// 保存LLM
  void saveLLM() {
    if (currentId.value == -1) {
      createLLM(); // 新建
    } else {
      editLLM(); // 编辑
    }
  }

  /// 创建LLM
  void createLLM() {
    LLMType? type;
    String? name;
    for (var item in formData) {
      if (item.key == 'type') {
        type = LLMType.values.firstWhere((e) => e.value == item.value);
      } else if (item.key == 'name') {
        name = item.value;
      }
    }
    if (type == null || name == null) {
      return;
    }

    late LLM llm;
    switch (type) {
      case LLMType.openai:
        llm = OpenaiModel.fromFormData(formData);
        break;
      default:
        return;
    }
    // 添加LLM
    final id = llmService.addLLM(llm);
    // 选中新建的LLM
    currentId.value = id;
  }

  /// 编辑LLM
  void editLLM() {
    final llm = llmService.getLLM(currentId.value);
    if (llm == null) {
      return;
    }
    late LLM newLLM;
    switch (llm.type) {
      case LLMType.openai:
        newLLM = OpenaiModel.fromFormData(formData);
        break;
      default:
        return;
    }
    newLLM.llmId = llm.llmId;
    llmService.updateLLM(newLLM);
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
