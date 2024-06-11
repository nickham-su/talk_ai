import 'dart:async';

import 'package:get/get.dart';
import '../../../shared/models/llm/llm_form_data_item.dart';
import '../../../shared/models/llm/llm_type.dart';
import '../../../shared/models/llm/llms.dart';
import '../../../shared/services/llm_service.dart';
import '../../sync/controllers/sync_controller.dart';

class LLMController extends GetxController {
  /// 当前选中的LLM的index
  final currentId = RxInt(-1);

  /// 表单数据
  RxList<LLMFormDataItem> formData = RxList<LLMFormDataItem>([]);

  /// LLM服务
  final llmService = Get.find<LLMService>();

  /// 数据同步控制器
  final syncController = Get.find<SyncController>();

  /// 是否是编辑状态
  get isEdit => currentId.value != -1 && formData.isNotEmpty;

  /// 是否是创建状态
  get isCreate => currentId.value == -1 && formData.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
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
    formData.assignAll(LLMs.getInitFormData(type));
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
    // 同步数据
    syncController.delaySync();
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
    llmService.updateLLMByData(llm.llmId, map);
    // 同步数据
    syncController.delaySync();
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
    // 同步数据
    syncController.delaySync();
  }

  /// 删除LLM
  void deleteLLM() {
    final llm = llmService.getLLM(currentId.value);
    if (llm == null) {
      return;
    }
    llmService.deleteLLM(llm.llmId);
    formData.clear();
    // 同步数据
    syncController.delaySync();
  }
}
