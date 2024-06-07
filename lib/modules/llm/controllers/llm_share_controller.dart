import 'dart:convert';

import 'package:get/get.dart';

import '../../../shared/models/llm/llm.dart';
import '../../../shared/services/llm_service.dart';
import '../../../shared/utils/compress.dart';

class LLMShareController extends GetxController {
  final llmService = Get.find<LLMService>();

  /// 模型列表
  List<LLM> get llmList => llmService.getLLMList();

  /// 选中状态
  final Map<int, bool> selected = {};

  /// 是否选中
  bool isSelect(int llmId) => selected[llmId] ?? false;

  /// 切换选中状态
  void toggleSelect(int llmId) {
    selected[llmId] = !(selected[llmId] ?? false);
    update();
  }

  /// 获取分享链接
  String getShareUrl() {
    List<int> llmIds = [];
    for (var key in selected.keys) {
      if (selected[key] == true) {
        llmIds.add(key);
      }
    }

    List<LLM> llms = llmService
        .getLLMList()
        .where((element) => llmIds.contains(element.llmId))
        .toList();

    List<Map> models = llms.map((e) {
      final map = e.toJson();
      map['name'] = e.name;
      map['type'] = e.type.value;
      return map;
    }).toList();

    final jsonStr = jsonEncode({'models': models});
    final compressed = gzipCompress(jsonStr);
    return '您的好友分享了${llms.length}个模型。打开TalkAI，在[同步]页面中导入：\ntalkai://share/$compressed';
  }
}
