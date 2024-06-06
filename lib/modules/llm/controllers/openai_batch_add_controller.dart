import 'package:TalkAI/shared/models/llm/llm_type.dart';
import 'package:TalkAI/shared/models/llm/openai/openai_model.dart';
import 'package:get/get.dart';

import '../apis/openai_models.dart';
import '../../../shared/models/llm/llm.dart';
import '../../../shared/services/llm_service.dart';

class OpenaiBatchAddController extends GetxController {
  /// URL
  String url = '';

  /// API Key
  String apiKey = '';

  /// 可用模型名称
  List<String> models = [];

  /// 自定义前缀
  String prefix = '';

  /// 自定义后缀
  String suffix = '';

  /// 模型服务
  final llmService = Get.find<LLMService>();

  /// 当前供应商已存在的模型Map, key为model
  final Map<String, OpenaiModel> existLLMs = {};

  /// 所有存在的自定义模型名称
  final Set<String> existCustomNames = {};

  /// 获取已存在的模型
  LLM? getExistLLM(String model) => existLLMs[model];

  /// 是否存在自定义名称
  bool isExistCustomName(String name) => existCustomNames.contains(name);

  /// 选中状态
  final Map<String, bool> selected = {};

  /// 是否选中
  bool isSelect(String model) => selected[model] ?? false;

  /// 切换选中状态
  void toggleSelect(String model) {
    selected[model] = !(selected[model] ?? false);
    update();
  }

  /// 获取完整模型名
  String getFullName(String model) {
    return '$prefix$model$suffix';
  }

  /// 获取可用模型名称列表
  getModels() async {
    // 获取模型列表
    models = await OpenaiModelsApi.getModels(
      url: url,
      apiKey: apiKey,
    );

    // 清空数据
    existLLMs.clear();
    existCustomNames.clear();
    selected.clear();

    // 更新已存在的模型
    llmService.getLLMList().forEach((llm) {
      // 存在的模型名称
      existCustomNames.add(llm.name);
      // 存在的openai模型
      if (llm.type == LLMType.openai) {
        final m = llm as OpenaiModel;
        if (m.url == url && m.apiKey == apiKey) {
          existLLMs[m.model] = m;
        }
      }
    });

    // 将已存在的模型选中
    final existModelSet = existLLMs.keys.toSet();
    final newModelSet = models.toSet();
    for (var model in existModelSet.intersection(newModelSet)) {
      selected[model] = true;
    }
  }

  /// 设置前缀
  setPrefix(String value) {
    prefix = value;
    update();
  }

  /// 设置后缀
  setSuffix(String value) {
    suffix = value;
    update();
  }

  /// 保存
  save() {
    Set<String> selectedModelSet =
        models.where((model) => selected[model] ?? false).toSet();

    // 检测名称冲突
    List<String> conflictNames = [];
    for (var model in selectedModelSet) {
      final fullName = getFullName(model);
      OpenaiModel? existLLm = existLLMs[model];
      if (existCustomNames.contains(fullName) &&
          (existLLm == null || existLLm.name != fullName)) {
        conflictNames.add(fullName);
      }
    }
    if (conflictNames.isNotEmpty) {
      throw '模型名称已存在：${conflictNames.join(', ')}';
    }

    // 处理已存在的模型
    for (var model in existLLMs.keys) {
      if (!selectedModelSet.contains(model)) {
        // 删除已存在的模型但取消选中的模型
        llmService.deleteLLM(existLLMs[model]!.llmId);
      } else {
        // 更新模型名称
        final fullName = getFullName(model);
        final existLLm = existLLMs[model]!;
        if (existLLm.name != fullName) {
          existLLm.name = fullName;
          llmService.updateLLM(existLLm);
        }
      }
    }

    // 添加新模型
    for (var model in selectedModelSet.difference(existLLMs.keys.toSet())) {
      final fullName = getFullName(model);
      llmService.addLLM({
        'name': fullName,
        'type': LLMType.openai.value,
        'url': url,
        'api_key': apiKey,
        'model': model,
      });
    }
  }
}
