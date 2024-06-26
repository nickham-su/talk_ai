import 'dart:typed_data';

import 'package:get/get.dart';
import '../../../shared/components/form_widget/dropdown_widget.dart';
import '../../../shared/services/llm_service.dart';
import '../models/chat_app_model.dart';

class ChatAppSettingController extends GetxController {
  int chatAppId = 0;
  String name = '';
  String prompt = '';
  double temperature = 0.8;
  int llmId = 0;
  bool multipleRound = true;
  Uint8List? profilePicture;

  /// llm服务
  final llmService = Get.find<LLMService>();

  /// llm选项
  List<DropdownOption<int>> get llmOptions {
    List<DropdownOption<int>> options = [
      DropdownOption<int>(value: 0, label: '无'),
    ];
    options.addAll(llmService.llmList
        .map((llm) => DropdownOption<int>(value: llm.llmId, label: llm.name)));
    return options;
  }

  /// 设置表单数据
  void setFormData(ChatAppModel chatAppModel) {
    chatAppId = chatAppModel.chatAppId;
    name = chatAppModel.name;
    prompt = chatAppModel.prompt;
    temperature = chatAppModel.temperature;
    if (llmService.getLLM(chatAppModel.llmId) == null) {
      llmId = 0; // 如果模型不存在，则默认为0
    } else {
      llmId = chatAppModel.llmId;
    }
    multipleRound = chatAppModel.multipleRound;
    profilePicture = chatAppModel.profilePicture;
  }

  /// 初始化表单数据
  void initFormData() {
    chatAppId = 0;
    name = '';
    prompt = '';
    temperature = 0.8;
    llmId = 0;
    multipleRound = true;
    profilePicture = null;
  }
}
