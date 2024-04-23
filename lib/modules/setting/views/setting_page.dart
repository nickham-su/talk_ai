import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:TalkAI/modules/setting/views/components/update_widget.dart';

import '../../../shared/components/layout/models/layout_menu_type.dart';
import '../../../shared/components/layout/views/layout.dart';
import 'components/cache_widget.dart';
import 'components/network_timeout.dart';
import 'components/theme_widget.dart';

class SettingPage extends StatelessWidget {
  // 最大宽度
  final maxWidth = 700.0;

  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    double parentWidth = MediaQuery.of(context).size.width;
    return Layout(
      currentMenu: LayoutMenuType.setting,
      child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 40),
          color: Get.theme.colorScheme.background,
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              width: parentWidth > maxWidth ? maxWidth : parentWidth,
              height: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: const Text(
                      '设置',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const ThemeWidget(),
                  const NetworkTimeout(),
                  const CacheWidget(),
                  const UpdateWidget(),
                ],
              ))),
    );
  }
}
