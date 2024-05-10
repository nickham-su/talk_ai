import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DangerButton extends StatelessWidget {
  final String text;
  final Size? minimumSize;
  final void Function()? onPressed;

  const DangerButton({
    super.key,
    required this.text,
    this.minimumSize,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Get.theme.colorScheme.errorContainer,
        foregroundColor: Get.theme.colorScheme.error,
        minimumSize: minimumSize,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: Get.theme.colorScheme.error,
        ),
      ),
    );
  }
}
