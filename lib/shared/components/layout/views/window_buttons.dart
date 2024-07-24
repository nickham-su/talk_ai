import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  WindowButtonsState createState() => WindowButtonsState();
}

class WindowButtonsState extends State<WindowButtons> {
  bool isAlwaysOnTop = false;

  @override
  Widget build(BuildContext context) {
    return Row(
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
          icon: 'assets/icons/square.svg',
          onPressed: () async {
            if (await windowManager.isMaximized()) {
              windowManager.unmaximize();
            } else {
              windowManager.maximize();
            }
          },
        ),
        WindowButton(
          icon: 'assets/icons/close.svg',
          onPressed: () {
            windowManager.close();
          },
        ),
      ],
    );
  }
}

class WindowButton extends StatelessWidget {
  final String icon;
  final VoidCallback onPressed;
  bool checked;

  WindowButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.checked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 32,
      alignment: Alignment.center,
      child: IconButton(
        padding: const EdgeInsets.only(top: 3),
        style: ButtonStyle(
          backgroundColor: checked
              ? MaterialStateProperty.all(
                  Get.theme.colorScheme.primaryContainer)
              : null,
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
        ),
        onPressed: onPressed,
        icon: SvgPicture.asset(
          icon,
          width: 16,
          height: 16,
          theme: SvgTheme(
            currentColor: checked
                ? Get.theme.colorScheme.primary
                : Get.theme.colorScheme.inverseSurface,
          ),
        ),
      ),
    );
  }
}
