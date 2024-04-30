import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/components/buttons/danger_button.dart';
import '../../../../shared/components/dialog.dart';
import '../../../../shared/components/share/llm_share_import_dialog.dart';
import '../../../../shared/components/snackbar.dart';
import '../../controllers/setting_controller.dart';

class ImportWidget extends GetView<SettingController> {
  const ImportWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      height: 32,
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '导入模型和助理',
              style: TextStyle(fontSize: 16),
            ),
          ),
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Get.theme.colorScheme.secondaryContainer,
              ),
            ),
            onPressed: () {
              Get.dialog(
                const LLMShareImportDialog(),
                barrierDismissible: true,
              );
            },
            child: Text('导入数据',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                  color: Get.theme.colorScheme.secondary,
                )),
          ),
        ],
      ),
    );
  }
}
