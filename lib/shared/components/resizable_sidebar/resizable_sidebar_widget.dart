import 'dart:math';
import 'package:TalkAI/shared/repositories/setting_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'resizable_sidebar_controller.dart';

/// 可调节宽度的侧边栏
class ResizableSidebarWidget extends StatelessWidget {
  final Widget child; // 子组件

  const ResizableSidebarWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    /// 最小宽度
    const minWidth = 150.0;

    /// 初始化宽度
    final initWidth = SettingRepository.getSidebarWidth(200);
    return GetBuilder<ResizableSidebarController>(
      init: ResizableSidebarController(initWidth),
      builder: (controller) {
        return Stack(
          children: [
            SizedBox(
              width: max(controller.width, minWidth),
              child: child,
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onPanUpdate: (DragUpdateDetails details) {
                  final width = controller.width + details.delta.dx;
                  SettingRepository.setSidebarWidth(width);
                  controller.setWidth(width);
                },
                onPanEnd: (DragEndDetails details) {
                  final width = max(controller.width, minWidth);
                  SettingRepository.setSidebarWidth(width);
                  controller.setWidth(width);
                },
                child: const MouseRegion(
                  cursor: SystemMouseCursors.resizeColumn,
                  child: SizedBox(
                    width: 8,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
