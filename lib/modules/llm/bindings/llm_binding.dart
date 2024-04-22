import 'package:get/get.dart';

import '../controllers/llm_controller.dart';

class LLMBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LLMController>(() => LLMController());
  }
}
