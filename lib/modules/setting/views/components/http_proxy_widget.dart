import 'package:TalkAI/shared/repositories/setting_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/components/buttons/danger_button.dart';
import '../../../../shared/components/dialog.dart';
import '../../../../shared/components/share/llm_share_import_dialog.dart';
import '../../../../shared/components/snackbar.dart';
import '../../controllers/setting_controller.dart';
import 'setting_row.dart';

class HttpProxyWidget extends GetView<SettingController> {
  const HttpProxyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final inputController = TextEditingController();
    inputController.text = SettingRepository.getProxy();

    return SettingRow(
      title: 'HTTP代理',
      child: Container(
        width: 250,
        height: 36,
        child: TextField(
          textAlign: TextAlign.center,
          controller: inputController,
          onChanged: (value) {
            SettingRepository.setProxy(value);
          },
          style: const TextStyle(
            height: 1,
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
          decoration: InputDecoration(
            hintText: '例如：127.0.0.1:7890',
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                width: 1.5,
                color: Get.theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(top: 16),
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: Text(
              'HTTP代理',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Container(
            width: 200,
            padding: const EdgeInsets.only(bottom: 8, right: 8),
            child: TextField(
              controller: inputController,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
              decoration: InputDecoration(
                hintText: '127.0.0.1:7890',
                contentPadding: EdgeInsets.only(left: 8),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1.5,
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
