import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'buttons/cancel_button.dart';

void dialog({
  required String title,
  required String middleText,
  Widget? cancel,
  Widget? confirm,
}) {
  Get.defaultDialog(
    titlePadding: const EdgeInsets.only(top: 30),
    titleStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    contentPadding:
        const EdgeInsets.only(top: 20, bottom: 30, left: 30, right: 30),
    title: title,
    middleText: middleText,
    cancel: cancel ??
        CancelButton(
          text: '取消',
          onPressed: () {
            Get.back();
          },
        ),
    confirm: confirm,
  );
}
