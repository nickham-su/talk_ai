import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/components/buttons/cancel_button.dart';
import '../../../../shared/components/buttons/confirm_button.dart';
import '../../../../shared/components/share/llm_share_link_dialog.dart';
import '../../controllers/chat_app_list_controller.dart';
import '../../controllers/chat_app_share_controller.dart';

class AppShareDialog extends StatelessWidget {
  const AppShareDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatAppListController = Get.find<ChatAppListController>();
    return GetBuilder<ChatAppShareController>(
      init: ChatAppShareController(),
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
                      '分享助理',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: ListView.builder(
                        itemCount: chatAppListController.chatAppList.length,
                        itemBuilder: (context, index) {
                          final app = chatAppListController.chatAppList[index];
                          return CheckboxListTile(
                            title: Text(app.name),
                            value: controller.isSelect(app.chatAppId),
                            onChanged: (value) {
                              controller.toggleSelect(app.chatAppId);
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
                            await Future.delayed(
                                const Duration(milliseconds: 200));
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
