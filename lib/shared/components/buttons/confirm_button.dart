import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfirmButton extends StatelessWidget {
  final String text;
  final Size? minimumSize;
  final void Function()? onPressed;

  const ConfirmButton({
    super.key,
    required this.text,
    this.minimumSize,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        foregroundColor: Get.theme.colorScheme.primary,
        minimumSize: minimumSize,
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
