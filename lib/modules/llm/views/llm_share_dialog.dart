import 'package:TalkAI/modules/llm/controllers/llm_share_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/components/buttons/cancel_button.dart';
import '../../../shared/components/buttons/confirm_button.dart';
import '../../../shared/services/llm_service.dart';
import '../../../shared/components/share/llm_share_link_dialog.dart';

class LLMShareDialog extends StatelessWidget {
  const LLMShareDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LLMShareController>(
      init: LLMShareController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Get.theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Get.theme.colorScheme.outlineVariant,
                ),
              ),
              width: 400,
              height: 500,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 48,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Get.theme.colorScheme.outlineVariant
                              .withOpacity(0.5),
                        ),
                      ),
                    ),
                    child: const Text(
                      '分享模型',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: ListView.builder(
                        itemCount: controller.llmList.length,
                        itemBuilder: (context, index) {
                          final llm = controller.llmList[index];
                          return CheckboxListTile(
                            title: Text(llm.name),
                            value: controller.isSelect(llm.llmId),
                            onChanged: (value) {
                              controller.toggleSelect(llm.llmId);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConfirmButton(
                          text: '分享',
                          onPressed: () async {
                            final url = controller.getShareUrl();
                            Get.back();
                            await Future.delayed(const Duration(milliseconds: 200));
                            Get.dialog(
                              LLMShareLinkDialog(url: url),
                              barrierDismissible: true,
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        CancelButton(
                          text: '取消',
                          onPressed: () {
                            Get.back();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
