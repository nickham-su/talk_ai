import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class SliderWidget extends StatefulWidget {
  final String labelText; // 标签文字
  final double? labelWidth; // 标签宽度
  final TextStyle labelStyle; // 标签样式
  final double min; // 最小值
  final double max; // 最大值
  final double initialValue; // 初始值
  final int divisions; // 分割数
  final EdgeInsetsGeometry margin; // 外边距
  final void Function(double) onChanged; // 滑动回调
  final String Function(double)? format; // 格式化回调
  final String? tooltip; // 提示

  const SliderWidget({
    super.key,
    required this.labelText,
    this.labelWidth,
    this.labelStyle = const TextStyle(fontSize: 14),
    required this.min,
    required this.max,
    required this.initialValue,
    this.divisions = 10,
    this.margin = const EdgeInsets.only(top: 24),
    required this.onChanged,
    this.format,
    this.tooltip,
  });

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  late double value;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> labelWidgets = [
      Text(
        widget.labelText,
        style: widget.labelStyle,
      )
    ];

    if (widget.tooltip != null) {
      labelWidgets.add(Container(
        margin: const EdgeInsets.only(left: 4),
        child: SvgPicture.asset(
          'assets/icons/tips.svg',
          width: 14,
          height: 14,
          theme: SvgTheme(
            currentColor: Get.theme.colorScheme.inverseSurface,
          ),
        ),
      ));
    }

    return Container(
        width: double.infinity,
        height: 32,
        margin: widget.margin,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            SizedBox(
              width: widget.labelWidth,
              child: Tooltip(
                message: widget.tooltip ?? '',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: labelWidgets,
                ),
              ),
            ),
            Expanded(
              child: Slider(
                value: value,
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                onChanged: (value) {
                  this.value = value;
                  widget.onChanged(value);
                  setState(() {});
                },
              ),
            ),
            Text(
              widget.format != null
                  ? widget.format!(value)
                  : value.toStringAsFixed(2),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ));
  }
}
