import 'dart:math';

import 'package:TalkAI/modules/llm/controllers/llm_share_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/components/buttons/cancel_button.dart';
import '../../../shared/components/buttons/confirm_button.dart';
import '../../../shared/components/dialog_widget/dialog_widget.dart';
import '../../../shared/components/share/llm_share_link_dialog.dart';

class LLMShareDialog extends StatelessWidget {
  const LLMShareDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogWidget(
      width: min(Get.width / 2, 400), // or whatever you need
      height: 400,
      title: '分享模型',
      child: GetBuilder<LLMShareController>(
        init: LLMShareController(),
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                  child: ListView.builder(
                itemCount: controller.llmList.length,
                itemBuilder: (context, index) {
                  final llm = controller.llmList[index];
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                    title: Text(llm.name),
                    value: controller.isSelect(llm.llmId),
                    onChanged: (value) {
                      controller.toggleSelect(llm.llmId);
                    },
                  );
                },
              )),
              Container(
                margin: EdgeInsets.only(top: 24),
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
              )
            ],
          );
        },
      ),
    );
  }
}
