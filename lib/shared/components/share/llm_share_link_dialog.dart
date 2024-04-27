import 'package:TalkAI/modules/llm/controllers/llm_share_controller.dart';
import 'package:TalkAI/shared/components/snackbar.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../buttons/cancel_button.dart';
import '../buttons/confirm_button.dart';
import '../../services/llm_service.dart';
import '../form_widget/text_widget.dart';

class LLMShareLinkDialog extends StatelessWidget {
  final String url;

  const LLMShareLinkDialog({Key? key, required this.url}) : super(key: key);

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
              width: 500,
              height: 300,
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
                      '分享',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            labelText: '复制发送给好友',
                            initialValue: url,
                            maxLines: 6,
                            onChanged: (val) {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 24),
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
              ),
            ),
          ),
        );
      },
    );
  }
}
