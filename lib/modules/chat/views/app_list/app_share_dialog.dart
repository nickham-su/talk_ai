import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/components/buttons/cancel_button.dart';
import '../../../../shared/components/buttons/confirm_button.dart';
import '../../../../shared/components/dialog_widget/dialog_widget.dart';
import '../../../../shared/components/share/llm_share_link_dialog.dart';
import '../../controllers/chat_app_list_controller.dart';
import '../../controllers/chat_app_share_controller.dart';

class AppShareDialog extends StatelessWidget {
  const AppShareDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatAppListController = Get.find<ChatAppListController>();

    return DialogWidget(
      width: min(Get.width / 2, 400), // or whatever you need
      height: 400,
      title: '分享助理',
      child: GetBuilder<ChatAppShareController>(
        init: ChatAppShareController(),
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                  child: Container(
                color: Get.theme.scaffoldBackgroundColor.withOpacity(0.5),
                child: ListView.builder(
                  itemCount: chatAppListController.chatAppList.length,
                  itemBuilder: (context, index) {
                    final app = chatAppListController.chatAppList[index];
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.only(left: 8, right: 4),
                      title: Text(app.name),
                      value: controller.isSelect(app.chatAppId),
                      onChanged: (value) {
                        controller.toggleSelect(app.chatAppId);
                      },
                    );
                  },
                ),
              )),
              Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Text('分享包含助理头像',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        )),
                    const SizedBox(width: 4),
                    Checkbox(
                        value: controller.shareProfilePicture,
                        onChanged: (value) {
                          controller.setShareProfilePicture(value);
                        }),
                  ],
                ),
              ),
              Container(
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
          );
        },
      ),
    );
  }
}
