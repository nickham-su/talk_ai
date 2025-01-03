import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:TalkAI/shared/controllers/app_update_controller.dart';

import '../../../../routes.dart';
import '../controllers/layout_controller.dart';
import '../models/layout_menu_type.dart';

class Sidebar extends StatelessWidget {
  final LayoutMenuType currentMenu;

  const Sidebar({super.key, required this.currentMenu});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LayoutController>(builder: (LayoutController controller) {
      return Container(
        padding: const EdgeInsets.only(left: 4, right: 1),
        color: Get.theme.colorScheme.secondaryContainer.withOpacity(0.3),
        width: 48,
        child: Column(
          children: [
            SizedBox(height: Platform.isMacOS ? 60 : 28),
            Expanded(
                child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                getListTile(
                  controller: controller,
                  type: LayoutMenuType.chat,
                  routePath: Routes.chat,
                ),
                getListTile(
                  controller: controller,
                  type: LayoutMenuType.llm,
                  routePath: Routes.llm,
                ),
                getListTile(
                  controller: controller,
                  type: LayoutMenuType.sync,
                  routePath: Routes.sync,
                ),
                GetBuilder<AppUpdateController>(
                  builder: (AppUpdateController appUpdateController) {
                    return getListTile(
                      controller: controller,
                      type: LayoutMenuType.setting,
                      routePath: Routes.setting,
                      showBadge: appUpdateController.needUpdate,
                    );
                  },
                ),
              ],
            )),
          ],
        ),
      );
    });
  }

  // 获取菜单项
  Widget getListTile({
    required LayoutController controller,
    required LayoutMenuType type,
    required String routePath,
    bool showBadge = false,
  }) {
    return Container(
        child: Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: IconButton(
            hoverColor:
                Get.theme.colorScheme.secondaryContainer.withOpacity(0.4),
            style: ButtonStyle(
              padding: MaterialStateProperty.all(EdgeInsets.zero),
              alignment: Alignment.center,
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              )),
            ),
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getIcon(type, currentMenu),
                Text(
                  type.value,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 10,
                    color: type == currentMenu
                        ? Get.theme.colorScheme.primary
                        : Get.theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Get.offNamed(routePath);
            },
          ),
        ),
        if (showBadge)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              constraints: const BoxConstraints(
                minWidth: 8,
                minHeight: 8,
              ),
            ),
          ),
      ],
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
      case LayoutMenuType.sync:
        if (currentMenuType == LayoutMenuType.sync) {
          iconFile = 'assets/icons/layout/layout_sync.svg';
        } else {
          iconFile = 'assets/icons/layout/layout_sync_gray.svg';
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
    return SvgPicture.asset(iconFile, width: 22, height: 22);
  }
}
