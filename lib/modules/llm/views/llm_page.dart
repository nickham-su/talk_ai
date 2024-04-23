import 'package:TalkAI/modules/llm/views/llm_setting.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/components/layout/models/layout_menu_type.dart';
import '../../../shared/components/layout/views/layout.dart';
import '../controllers/llm_controller.dart';
import 'llm_list.dart';

class LLMPage extends GetView<LLMController> {
  const LLMPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Layout(
      currentMenu: LayoutMenuType.llm,
      child: Row(
        children: [
          const LLMList(),
          Obx(() => Expanded(
                child: Container(
                  color: Get.theme.colorScheme.background,
                  child: controller.isCreate || controller.isEdit
                      ? LLMSetting()
                      : const EmptyPage(),
                ),
              )),
        ],
      ),
    );
  }
}

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '点击+新建模型',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Get.theme.colorScheme.secondary.withOpacity(0.5),
          ),
        ),
        SizedBox(height: 8),
        Text(
          '选择模型进行设置',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Get.theme.colorScheme.secondary.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
