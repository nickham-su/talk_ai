import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 代码块包装器
Widget preWrapper(Widget child, String text) {
  return PreWrapperWidget(child, text);
}

/// 代码块包装器组件
class PreWrapperWidget extends StatefulWidget {
  final Widget child;
  final String text;

  const PreWrapperWidget(this.child, this.text, {Key? key}) : super(key: key);

  @override
  State<PreWrapperWidget> createState() => _PreWrapperState();
}

class _PreWrapperState extends State<PreWrapperWidget> {
  late Widget _switchWidget;
  bool hasCopied = false;

  @override
  void initState() {
    super.initState();
    _switchWidget = Icon(
      Icons.copy_rounded,
      key: UniqueKey(),
      size: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _switchWidget,
                  ),
                  onTap: () async {
                    if (hasCopied) return;
                    await Clipboard.setData(ClipboardData(text: widget.text.trim()));
                    _switchWidget = Icon(
                      Icons.check,
                      key: UniqueKey(),
                      size: 16,
                    );
                    refresh();
                    Future.delayed(const Duration(seconds: 2), () {
                      hasCopied = false;
                      _switchWidget = Icon(
                        Icons.copy_rounded,
                        key: UniqueKey(),
                        size: 16,
                      );
                      refresh();
                    });
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}
