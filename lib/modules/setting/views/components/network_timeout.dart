import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/components/form_widget/slider_widget.dart';
import '../../controllers/setting_controller.dart';

class NetworkTimeout extends StatelessWidget {
  const NetworkTimeout({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingController>(
        builder: (SettingController controller) {
      return Container(
        padding: const EdgeInsets.only(right: 12),
        child: SliderWidget(
          labelWidth: 150,
          labelText: '网络超时时间',
          labelStyle: const TextStyle(fontSize: 16),
          min: 10,
          max: 120,
          divisions: 11,
          initialValue: controller.networkTimeout.toDouble(),
          onChanged: (value) {
            controller.setNetworkTimeout(value.toInt());
          },
          format: (value) => '${value.toInt()} 秒',
        ),
      );
    });
  }
}
