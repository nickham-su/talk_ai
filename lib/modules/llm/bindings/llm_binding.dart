import 'package:get/get.dart';

import '../controllers/llm_controller.dart';
import '../controllers/openai_subscription_controller.dart';

class LLMBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LLMController>(() => LLMController());
    Get.lazyPut<OpenaiSubscriptionController>(() => OpenaiSubscriptionController());
  }
}
