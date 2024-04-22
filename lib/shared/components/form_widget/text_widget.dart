import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextWidget extends StatelessWidget {
  final String labelText; // 标签文字
  final String? hintText; // 提示文字
  final String initialValue; // 初始值
  final int maxLines; // 最大行数
  final bool isRequired; // 是否必填
  final bool isDisabled; // 是否禁用
  final EdgeInsetsGeometry margin; // 外边距
  final void Function(String) onChanged; // 回调

  const TextWidget({
    super.key,
    required this.labelText,
    required this.onChanged,
    this.initialValue = '',
    this.maxLines = 1,
    this.isRequired = false,
    this.isDisabled = false,
    this.margin = const EdgeInsets.only(top: 24),
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: TextFormField(
        enabled: !isDisabled,
        maxLines: maxLines,
        validator: (value) {
          if (isRequired == true && (value == null || value.isEmpty)) {
            return '请输入$labelText';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: hintText ?? '请输入$labelText',
          hintStyle: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Colors.grey.withOpacity(0.5),
              fontWeight: FontWeight.w300),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1.5,
              color: Get.theme.colorScheme.primary,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.5),
            ),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(),
          ),
        ),
        style: const TextStyle(fontSize: 12, height: 1.5),
        initialValue: initialValue,
        onChanged: onChanged,
      ),
    );
  }
}
