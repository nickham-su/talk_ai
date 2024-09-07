import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

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
          width: 14,
          height: 14,
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
