import 'dart:math';
import 'package:TalkAI/shared/repositories/setting_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'resizable_sidebar_controller.dart';

/// 可调节宽度的侧边栏
class ResizableSidebarWidget extends StatelessWidget {
  final String tag; // 侧边栏标识
  final double minWidth; // 最小宽度
  final Widget child; // 子组件

  const ResizableSidebarWidget({
    super.key,
    required this.tag,
    required this.minWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final initWidth = SettingRepository.getSidebarWidth(tag, 200);
    return GetBuilder<ResizableSidebarController>(
      id: tag,
      tag: tag,
      init: ResizableSidebarController(tag, initWidth),
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
                  SettingRepository.setSidebarWidth(tag, width);
                  controller.setWidth(width);
                },
                child: const MouseRegion(
                  cursor: SystemMouseCursors.resizeColumn,
                  child: SizedBox(
                    width: 5,
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
