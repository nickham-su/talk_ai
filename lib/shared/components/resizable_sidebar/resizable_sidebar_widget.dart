import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'resizable_sidebar_controller.dart';

/// 可调节宽度的侧边栏
class ResizableSidebarWidget extends StatelessWidget {
  final String tag; // 标签
  final Widget child; // 子组件
  final bool resizeWidth; // 是否可调整宽度
  final double minWidth; // 最小宽度
  final double maxWidth; // 最大宽度
  final double initWidth; // 初始宽度
  final Function(double)? onWidthChanged; // 宽度变化回调
  final bool resizeHeight; // 是否可调整高度
  final double minHeight; // 最小高度
  final double maxHeight; // 最大高度
  final double initHeight; // 初始高度
  final Function(double)? onHeightChanged; // 高度变化回调

  const ResizableSidebarWidget({
    super.key,
    required this.tag,
    required this.child,
    this.resizeWidth = false,
    this.minWidth = 0,
    this.maxWidth = double.infinity,
    this.initWidth = 200,
    this.onWidthChanged,
    this.resizeHeight = false,
    this.minHeight = 0,
    this.maxHeight = double.infinity,
    this.initHeight = 200,
    this.onHeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ResizableSidebarController>(
      id: tag,
      tag: tag,
      init: ResizableSidebarController(tag, initWidth, initHeight),
      builder: (controller) {
        return Stack(
          children: [
            SizedBox(
              width: resizeWidth
                  ? min(maxWidth, max(controller.width, minWidth))
                  : null,
              height: resizeHeight
                  ? min(maxHeight, max(controller.height, minHeight))
                  : null,
              child: child,
            ),
            if (resizeWidth)
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onPanUpdate: (DragUpdateDetails details) {
                    final width = controller.width + details.delta.dx;
                    controller.setWidth(width);
                  },
                  onPanEnd: (DragEndDetails details) {
                    double width = max(controller.width, minWidth);
                    width = min(maxWidth, width);
                    controller.setWidth(width);
                    onWidthChanged?.call(width);
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
            if (resizeHeight)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onPanUpdate: (DragUpdateDetails details) {
                    final height = controller.height - details.delta.dy;
                    controller.setHeight(height);
                  },
                  onPanEnd: (DragEndDetails details) {
                    double height = max(controller.height, minHeight);
                    height = min(maxHeight, height);
                    controller.setHeight(height);
                    onHeightChanged?.call(height);
                  },
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.resizeRow,
                    child: SizedBox(
                      width: double.infinity,
                      height: 8,
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
