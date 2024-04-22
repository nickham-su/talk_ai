import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfirmButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;

  const ConfirmButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        foregroundColor: Get.theme.colorScheme.primary,
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
