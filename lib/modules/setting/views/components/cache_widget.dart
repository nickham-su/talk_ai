import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/components/buttons/danger_button.dart';
import '../../../../shared/components/dialog.dart';
import '../../../../shared/components/snackbar.dart';
import '../../controllers/setting_controller.dart';
import 'setting_row.dart';

class CacheWidget extends GetView<SettingController> {
  const CacheWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingRow(
      title: '缓存',
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            Get.theme.colorScheme.secondaryContainer,
          ),
        ),
        onPressed: () {
          dialog(
            title: '清除缓存',
            middleText: '确定要清除所有缓存数据吗？',
            confirm: DangerButton(
              text: '删除',
              onPressed: () {
                controller.clearData();
                Get.back();
                // 提示清空数据成功
                snackbar('操作成功', '数据已清空');
              },
            ),
          );
        },
        child: Text('清除所有缓存数据',
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 12,
              color: Get.theme.colorScheme.secondary,
            )),
      ),
    );
  }
}
