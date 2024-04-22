import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/layout_controller.dart';
import '../models/layout_menu_type.dart';
import 'sidebar.dart';

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
        color: Get.theme.colorScheme.secondaryContainer.withOpacity(0.2),
        child: Row(
          children: [
            Container(
              width: 50,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color:
                        Get.theme.colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
              ),
              child: Sidebar(currentMenu: currentMenu),
            ),
            // Expanded(child: Column(children: [TopBar(), Expanded(child: child)]))
            Expanded(child: child)
          ],
        ),
      ));
    });
  }
}
