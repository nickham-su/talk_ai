import 'package:get/get.dart';

import '../models/chat_app_model.dart';

class ChatAppSettingController extends GetxController {
  int chatAppId = 0;
  String name = '';
  String prompt = '';
  int llmId = 0;
  double temperature = 0.8;
  double topP = 0.95;

  void setFormData(ChatAppModel chatAppModel) {
    chatAppId = chatAppModel.chatAppId;
    name = chatAppModel.name;
    prompt = chatAppModel.prompt;
    llmId = chatAppModel.llmId;
    temperature = chatAppModel.temperature;
    topP = chatAppModel.topP;
  }

  void initFormData() {
    chatAppId = 0;
    name = '';
    prompt = '';
    llmId = 0;
    temperature = 0.8;
    topP = 0.95;
  }
}
