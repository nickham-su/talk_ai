import 'dart:math';

import 'package:TalkAI/modules/llm/controllers/llm_share_controller.dart';
import 'package:TalkAI/shared/components/snackbar.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../buttons/cancel_button.dart';
import '../buttons/confirm_button.dart';
import '../dialog_widget/dialog_widget.dart';
import '../form_widget/text_widget.dart';

class LLMShareLinkDialog extends StatelessWidget {
  final String url;

  const LLMShareLinkDialog({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogWidget(
      width: min(Get.width / 2, 500), // or whatever you need
      height: 300,
      title: '分享',
      child: GetBuilder<LLMShareController>(
        init: LLMShareController(),
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                child: TextWidget(
                  labelText: '复制发送给好友',
                  initialValue: url,
                  maxLines: 100,
                  onChanged: (val) {},
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConfirmButton(
                      text: '复制',
                      onPressed: () {
                        FlutterClipboard.copy(url);
                        snackbar('复制成功', '发送给好友吧');
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
