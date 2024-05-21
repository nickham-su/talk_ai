import 'package:get/get.dart';

import '../models/chat_app_model.dart';

class ChatAppSettingController extends GetxController {
  int chatAppId = 0;
  String name = '';
  String prompt = '';
  double temperature = 1;

  void setFormData(ChatAppModel chatAppModel) {
    chatAppId = chatAppModel.chatAppId;
    name = chatAppModel.name;
    prompt = chatAppModel.prompt;
    temperature = chatAppModel.temperature;
  }

  void initFormData() {
    chatAppId = 0;
    name = '';
    prompt = '';
    temperature = 1;
  }
}
