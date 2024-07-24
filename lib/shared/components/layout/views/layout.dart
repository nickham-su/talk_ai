import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../repositories/setting_repository.dart';
import '../../resizable_sidebar/resizable_sidebar_widget.dart';
import '../controllers/layout_controller.dart';
import '../models/layout_menu_type.dart';
import 'sidebar.dart';
import 'topbar.dart';
import 'windows_title_bar/windows_title_bar.dart';

class Layout extends StatelessWidget {
  final Widget child;
  final LayoutMenuType currentMenu;
  final Widget? secondMenu;

  const Layout(
      {required this.child,
      super.key,
      required this.currentMenu,
      this.secondMenu});

  @override
  Widget build(BuildContext context) {
    bool isMacOS = Platform.isMacOS;
    return GetBuilder(builder: (LayoutController controller) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(children: [
            Column(
              children: [
                if (!isMacOS) const WindowsTitleBar(),
                Expanded(
                  child: Row(
                    children: [
                      Sidebar(currentMenu: currentMenu),
                      getSecondMenu(),
                      Expanded(
                          child: Container(
                        color: Get.theme.colorScheme.secondaryContainer
                            .withOpacity(0.3),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Get.theme.colorScheme.outlineVariant
                                    .withOpacity(0.5),
                              ),
                              top: BorderSide(
                                color: Get.theme.colorScheme.outlineVariant
                                    .withOpacity(0.5),
                              ),
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(isMacOS ? 0 : 8),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(isMacOS ? 0 : 8),
                            ),
                            child: child,
                          ),
                        ),
                      ))
                    ],
                  ),
                ),
              ],
            ),
            if (isMacOS)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: TopBar(),
              ),
          ]),
        ),
      );
    });
  }

  Widget getSecondMenu() {
    if (secondMenu != null) {
      return ResizableSidebarWidget(
        tag: 'second_menu',
        resizeWidth: true,
        minWidth: 120,
        initWidth: SettingRepository.getSidebarWidth(200),
        onWidthChanged: (double width) {
          SettingRepository.setSidebarWidth(width);
        },
        child: Container(
          padding: const EdgeInsets.only(right: 8),
          color: Get.theme.colorScheme.secondaryContainer.withOpacity(0.3),
          child: secondMenu!,
        ),
      );
    }
    return Container(
      width: 3,
      color: Get.theme.colorScheme.secondaryContainer.withOpacity(0.3),
    );
  }
}
