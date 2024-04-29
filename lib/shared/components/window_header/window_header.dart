import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

/// 处理双击缩放窗口
class WindowHeader extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;

  const WindowHeader({
    Key? key,
    this.child,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () async {
        if (await windowManager.isMaximized() == false) {
          windowManager.maximize();
        } else {
          windowManager.unmaximize();
        }
      },
      child: Container(
        color: Colors.transparent,
        width: width,
        height: height,
        child: child ??
            const SizedBox(
              width: double.infinity,
              height: double.infinity,
            ),
      ),
    );
  }
}
