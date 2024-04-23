import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:talk_ai/shared/controllers/app_update_controller.dart';

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
                controller: controller,
                type: LayoutMenuType.chat,
                routePath: Routes.chat,
              ),
              getListTile(
                controller: controller,
                type: LayoutMenuType.llm,
                routePath: Routes.llm,
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
    return SizedBox(
        width: 50,
        height: 50,
        child: Tooltip(
          message: type.value,
          waitDuration: const Duration(milliseconds: 500),
          showDuration: Duration.zero,
          child: Stack(
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: IconButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      type == currentMenu
                          ? Get.theme.colorScheme.primaryContainer
                          : Colors.transparent,
                    ),
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    alignment: Alignment.center,
                    shape:
                        MaterialStateProperty.all(const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    )),
                  ),
                  icon: getIcon(type, currentMenu),
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
