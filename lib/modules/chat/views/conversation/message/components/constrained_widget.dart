import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConstrainedWidget extends StatefulWidget {
  final Widget child; // 子组件

  const ConstrainedWidget({super.key, required this.child});

  @override
  State<StatefulWidget> createState() => _ConstrainedWidgetState();
}

class _ConstrainedWidgetState extends State<ConstrainedWidget> {
  final GlobalKey boxKey = GlobalKey();

  static const _maxHeight = 90.0;

  // 是否超过最大高度
  bool overMaxHeight = false;

  // 显示全部
  bool showAll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
          boxKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        if (renderBox.size.height >= _maxHeight) {
          setState(() {
            overMaxHeight = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          key: boxKey,
          constraints: BoxConstraints(
            maxHeight: showAll ? double.infinity : _maxHeight,
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: widget.child,
              ),
              Visibility(
                visible: overMaxHeight && !showAll,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1],
                      colors: [
                        Get.theme.colorScheme.background.withOpacity(0),
                        Get.theme.colorScheme.background
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: overMaxHeight && !showAll,
          child: Container(
            padding: const EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: () {
                showAll = true;
                setState(() {});
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text(
                  '显示全部',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
