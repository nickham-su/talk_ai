import 'package:flutter/cupertino.dart';

class SettingRow extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? tip;

  const SettingRow({
    Key? key,
    required this.title,
    required this.child,
    this.tip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (tip != null) tip!,
          child,
        ],
      ),
    );
  }
}
