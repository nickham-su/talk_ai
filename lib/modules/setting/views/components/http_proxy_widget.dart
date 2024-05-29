import 'package:TalkAI/shared/repositories/setting_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/components/buttons/danger_button.dart';
import '../../../../shared/components/dialog.dart';
import '../../../../shared/components/share/llm_share_import_dialog.dart';
import '../../../../shared/components/snackbar.dart';
import '../../controllers/setting_controller.dart';
import 'setting_row.dart';

class HttpProxyWidget extends StatelessWidget {
  const HttpProxyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingController>(builder: (controller) {
      final inputController = TextEditingController();
      inputController.text = controller.proxyAddress;
      return SettingRow(
        title: 'HTTP代理地址',
        child: SizedBox(
          width: 250,
          height: 36,
          child: TextField(
            enabled: controller.isProxyEnable,
            textAlign: TextAlign.center,
            controller: inputController,
            onChanged: (value) {
              controller.setProxyAddress(value);
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
    });
  }
}
