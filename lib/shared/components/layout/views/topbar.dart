import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _isHovering ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (event) async {
        if (await windowManager.isFullScreen()) return;
        setState(() => _isHovering = true);
      },
      onExit: (event) => setState(() => _isHovering = false),
      child: GestureDetector(
        onDoubleTap: () async {
          if (await windowManager.isMaximized() == false) {
            windowManager.maximize();
          } else {
            windowManager.unmaximize();
          }
          setState(() => _isHovering = false);
        },
        child: AnimatedContainer(
          height: 26,
          color: _isHovering
              ? Get.theme.colorScheme.inverseSurface.withOpacity(0.1)
              : Colors.transparent,
          duration: const Duration(milliseconds: 200),
        ),
      ),
    );
  }
}
