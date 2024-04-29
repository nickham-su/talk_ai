import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/layout_controller.dart';
import '../models/layout_menu_type.dart';
import 'sidebar.dart';
import 'topbar.dart';

class Layout extends StatelessWidget {
  final Widget child;
  final LayoutMenuType currentMenu;

  const Layout({required this.child, super.key, required this.currentMenu});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(builder: (LayoutController controller) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(children: [
            Row(
              children: [
                Container(
                  width: 64,
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.secondaryContainer
                        .withOpacity(0.3),
                  ),
                  child: Sidebar(currentMenu: currentMenu),
                ),
                // Expanded(child: Column(children: [TopBar(), Expanded(child: child)]))
                Expanded(child: child)
              ],
            ),
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
}
