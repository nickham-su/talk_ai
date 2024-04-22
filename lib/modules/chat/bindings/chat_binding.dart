import 'package:get/get.dart';

import '../controllers/chat_app_list_controller.dart';
import '../controllers/chat_app_setting_controller.dart';
import '../controllers/chat_app_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatAppListController>(() => ChatAppListController());
    Get.lazyPut<ChatAppController>(() => ChatAppController());
    Get.lazyPut<ChatAppSettingController>(() => ChatAppSettingController());
  }
}
