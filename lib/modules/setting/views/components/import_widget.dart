import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/components/share/llm_share_import_dialog.dart';
import '../../controllers/setting_controller.dart';
import 'setting_row.dart';

class ImportWidget extends GetView<SettingController> {
  const ImportWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingRow(
      title: '导入模型和助理',
      child: SizedBox(
        height: 32,
        child: TextButton(
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
      ),
    );
  }
}
