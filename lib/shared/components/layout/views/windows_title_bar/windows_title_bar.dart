import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import 'window_button.dart';

class WindowsTitleBar extends StatefulWidget {
  const WindowsTitleBar({super.key});

  @override
  WindowsTitleBarState createState() => WindowsTitleBarState();
}

class WindowsTitleBarState extends State<WindowsTitleBar> {
  /// 窗口置顶
  bool isAlwaysOnTop = false;

  /// 窗口最大化
  bool isMaximized = false;

  @override
  Widget build(BuildContext context) {
    Offset? windowStartPosition;
    Offset? mouseStartPosition;
    return GestureDetector(
      onDoubleTap: () {
        toggleMaximized();
      },
      onPanStart: (details) async {
        windowStartPosition = await windowManager.getPosition();
        mouseStartPosition = windowStartPosition! + details.localPosition;
      },
      onPanUpdate: (details) async {
        Offset windowPosition = await windowManager.getPosition();
        if (windowStartPosition == null || mouseStartPosition == null) {
          return;
        }
        Offset mousePosition = windowPosition + details.localPosition;
        Offset windowCurrentPosition =
            mousePosition - mouseStartPosition! + windowStartPosition!;
        windowManager.setPosition(windowCurrentPosition);
      },
      onPanEnd: (details) {
        windowStartPosition = null;
        mouseStartPosition = null;
      },
      child: Container(
          height: 32,
          color: Get.theme.colorScheme.secondaryContainer.withOpacity(0.3),
          padding: const EdgeInsets.only(left: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Image.asset('assets/images/app_logo.png'),
                  ),
                  const Text(
                    'Talk AI',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  WindowButton(
                    icon: 'assets/icons/pin.svg',
                    onPressed: () {
                      isAlwaysOnTop = !isAlwaysOnTop;
                      windowManager.setAlwaysOnTop(isAlwaysOnTop);
                      setState(() {});
                    },
                    checked: isAlwaysOnTop,
                  ),
                  WindowButton(
                    icon: 'assets/icons/minus.svg',
                    onPressed: () {
                      windowManager.minimize();
                    },
                  ),
                  WindowButton(
                    icon: isMaximized
                        ? 'assets/icons/window.svg'
                        : 'assets/icons/square.svg',
                    onPressed: () {
                      toggleMaximized();
                    },
                  ),
                  WindowButton(
                    icon: 'assets/icons/close.svg',
                    onPressed: () {
                      windowManager.close();
                    },
                  ),
                ],
              ),
            ],
          )),
    );
  }

  /// 切换窗口最大化
  void toggleMaximized() async {
    if (await windowManager.isMaximized()) {
      windowManager.unmaximize();
      isMaximized = false;
    } else {
      windowManager.maximize();
      isMaximized = true;
    }
    setState(() {});
  }
}
