import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../routes.dart';
import '../controllers/layout_controller.dart';
import '../models/layout_menu_type.dart';

class Sidebar extends StatelessWidget {
  final LayoutMenuType currentMenu;

  const Sidebar({super.key, required this.currentMenu});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LayoutController>(builder: (LayoutController controller) {
      return Column(
        children: [
          Expanded(
              child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              getListTile(
                controller,
                LayoutMenuType.chat,
                Routes.chat,
              ),
              getListTile(
                controller,
                LayoutMenuType.llm,
                Routes.llm,
              ),
              getListTile(
                controller,
                LayoutMenuType.setting,
                Routes.setting,
              ),
            ],
          )),
        ],
      );
    });
  }

  // 获取菜单项
  Widget getListTile(
      LayoutController controller, LayoutMenuType type, String routePath) {
    return Container(
        width: 50,
        height: 50,
        child: Tooltip(
          message: type.value,
          waitDuration: const Duration(milliseconds: 500),
          showDuration: Duration.zero,
          child: IconButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                type == currentMenu
                    ? Get.theme.colorScheme.primaryContainer
                    : Colors.transparent,
              ),
              padding: MaterialStateProperty.all(EdgeInsets.zero),
              alignment: Alignment.center,
              shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              )),
            ),
            icon: getIcon(type, currentMenu),
            onPressed: () {
              Get.offNamed(routePath);
            },
          ),
        ));
  }

  // 获取图标
  Widget getIcon(LayoutMenuType type, LayoutMenuType currentMenuType) {
    final iconFile;
    switch (type) {
      case LayoutMenuType.chat:
        if (currentMenuType == LayoutMenuType.chat) {
          iconFile = 'assets/icons/layout/layout_chat.svg';
        } else {
          iconFile = 'assets/icons/layout/layout_chat_gray.svg';
        }
      case LayoutMenuType.llm:
        if (currentMenuType == LayoutMenuType.llm) {
          iconFile = 'assets/icons/layout/layout_llm.svg';
        } else {
          iconFile = 'assets/icons/layout/layout_llm_gray.svg';
        }
      case LayoutMenuType.setting:
        if (currentMenuType == LayoutMenuType.setting) {
          iconFile = 'assets/icons/layout/layout_setting.svg';
        } else {
          iconFile = 'assets/icons/layout/layout_setting_gray.svg';
        }
      default:
        throw '未知的菜单类型';
    }
    return SvgPicture.asset(iconFile, width: 24, height: 24);
  }
}
