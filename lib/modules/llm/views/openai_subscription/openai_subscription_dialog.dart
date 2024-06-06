import 'dart:math';

import 'package:TalkAI/shared/components/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/components/buttons/cancel_button.dart';
import '../../../../shared/components/buttons/confirm_button.dart';
import '../../../../shared/components/dialog_widget/dialog_widget.dart';
import '../../../../shared/components/form_widget/text_widget.dart';
import '../../controllers/openai_subscription_controller.dart';
import 'openai_subscription_picker.dart';

class OpenaiSubscriptionDialog extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  OpenaiSubscriptionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogWidget(
      width: 600,
      height: 270,
      title: '批量添加OpenAI模型',
      child: GetBuilder<OpenaiSubscriptionController>(
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '第1步：填写URl和API Key，获取可用模型',
                style: TextStyle(
                  height: 1,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        labelText: 'URL',
                        hintText: '如：https://api.openai.com，不需要携带"/v1/models"',
                        initialValue: controller.url,
                        isRequired: true,
                        onChanged: (value) {
                          controller.url = value;
                        },
                      ),
                      TextWidget(
                        labelText: 'API Key',
                        hintText: '请输入API Key',
                        initialValue: controller.apiKey,
                        isRequired: true,
                        onChanged: (value) {
                          controller.apiKey = value;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConfirmButton(
                      text: '下一步',
                      onPressed: () async {
                        if (_formKey.currentState!.validate() == false) {
                          return;
                        }
                        try {
                          await controller.getModels();
                          Get.back();
                          Get.dialog(
                            const OpenaiSubscriptionPicker(),
                            barrierDismissible: false,
                          );
                        } catch (e) {
                          snackbar('获取模型出错：', e.toString());
                        }
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
          );
        },
      ),
    );
  }
}
