import 'package:flutter/material.dart';
import 'package:get/get.dart';

SnackbarController? _snackbarController;

/// 显示Snackbar
void snackbar(
  String title,
  String content, {
  Duration duration = const Duration(seconds: 3),
  double maxWidth = 400,
  EdgeInsets margin = const EdgeInsets.only(top: 20),
}) async {
  try {
    await _snackbarController?.close(withAnimations: false);
  } catch (e) {}

  _snackbarController = Get.snackbar(
    title,
    content,
    maxWidth: maxWidth,
    margin: margin,
    duration: duration,
    animationDuration: const Duration(milliseconds: 300),
  );
}
