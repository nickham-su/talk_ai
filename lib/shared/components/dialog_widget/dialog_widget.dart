import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class DialogWidget extends StatelessWidget {
  final double width;
  final double height;
  final String title;
  final Widget child;

  const DialogWidget(
      {Key? key,
      required this.width,
      required this.height,
      required this.title,
      required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          IconButton(
            onPressed: () {
              Get.back();
            },
            icon: SvgPicture.asset(
              'assets/icons/close.svg',
              width: 24,
              height: 24,
              theme: SvgTheme(
                currentColor: Get.theme.colorScheme.inverseSurface,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: width,
        height: height,
        child: child,
      ),
    );
  }
}
