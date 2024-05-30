import 'dart:async';
import 'dart:math';

import 'package:TalkAI/modules/chat/controllers/chat_app_controller.dart';
import 'package:TalkAI/shared/components/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../../shared/models/llm/llm.dart';
import '../../../../../shared/repositories/setting_repository.dart';
import '../../../../../shared/services/llm_service.dart';

/// 模型选择器
class LLMPicker extends StatelessWidget {
  const LLMPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LLMPickerController>(
      init: LLMPickerController(),
      autoRemove: false,
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              backgroundColor:
                  Get.theme.colorScheme.secondaryContainer.withOpacity(0.5),
            ),
            onPressed: () {
              controller.selectLLM();
            },
            child: Text(
              controller.currentLLM?.name ?? '选择模型',
              style: const TextStyle(
                fontSize: 14,
                height: 1,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        );
      },
    );
  }
}

class LLMPickerController extends GetxController {
  /// LLM服务
  final llmService = Get.find<LLMService>();

  /// 选中的模型ID
  int currentLLMId = -1;

  /// 选中的模型
  LLM? get currentLLM => llmService.getLLM(currentLLMId);

  @override
  void onInit() {
    final llmList = llmService.getLLMList();
    if (llmList.isNotEmpty) {
      currentLLMId = llmList.first.llmId;
    }
    super.onInit();
  }

  /// 设置模型
  void setLLM(int llmId) {
    currentLLMId = llmId;
    update();
  }

  /// 更换模型
  Future<int> selectLLM() async {
    final completer = Completer<int>();
    List<LLM> llmList = Get.find<LLMService>().getLLMList();

    if (llmList.isEmpty) {
      snackbar('提示', '请先添加模型');
      completer.completeError('请先添加模型');
      return completer.future;
    }

    Get.dialog(
      AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('选择模型'),
            IconButton(
              onPressed: () {
                completer.completeError('cancel');
                Get.back();
              },
              icon: SvgPicture.asset(
                'assets/icons/close.svg',
                width: 24,
                height: 24,
                theme: SvgTheme(
                  currentColor: Get.theme.colorScheme.inverseSurface,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: min(Get.width / 2, 500), // or whatever you need
          height: 250, // or whatever you need
          child: ListView.builder(
            itemCount: llmList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(llmList[index].name),
                onTap: () {
                  try {
                    if (!completer.isCompleted) {
                      final llmId = llmList[index].llmId;
                      setLLM(llmId);
                      completer.complete(llmId);
                    }
                  } finally {
                    Get.back();
                    Get.find<ChatAppController>().inputFocusNode.requestFocus();
                  }
                },
              );
            },
          ),
        ),
      ),
      barrierDismissible: false,
    );
    return completer.future;
  }
}
