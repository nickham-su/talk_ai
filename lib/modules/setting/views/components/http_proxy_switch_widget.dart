import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/setting_controller.dart';
import 'setting_row.dart';

class HttpProxySwitchWidget extends StatelessWidget {
  const HttpProxySwitchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingController>(
      builder: (SettingController controller) {
        return SettingRow(
          title: '启用代理',
          child: SizedBox(
            height: 40,
            width: 150,
            child: SwitchListTile(
              contentPadding: const EdgeInsets.only(left: 0, right: 0),
              value: controller.isProxyEnable,
              onChanged: (bool value) async {
                controller.toggleProxyStatus();
              },
            ),
          ),
        );
      },
    );
  }
}
