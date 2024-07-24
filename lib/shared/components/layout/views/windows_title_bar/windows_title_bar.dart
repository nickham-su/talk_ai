import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import 'window_buttons.dart';

class WindowsTitleBar extends StatelessWidget {
  const WindowsTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    Offset? windowStartPosition;
    Offset? mouseStartPosition;
    return GestureDetector(
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
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Talk AI',
                style: TextStyle(fontSize: 14),
              ),
              WindowButtons()
            ],
          )),
    );
  }
}
