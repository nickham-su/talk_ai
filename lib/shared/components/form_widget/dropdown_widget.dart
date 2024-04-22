import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 下拉框选项
class DropdownOption<T> {
  final String label;
  final T value;

  DropdownOption({required this.label, required this.value});
}

class DropdownWidget<T> extends StatelessWidget {
  final String labelText; // 标签文字
  final String? hintText; // 提示文字
  final T? initialValue; // 初始值
  final List<DropdownOption<T>> items; // 选项
  final bool isRequired; // 是否必填
  final EdgeInsetsGeometry margin; // 外边距
  final void Function(T?) onChanged; // 回调

  const DropdownWidget({
    super.key,
    required this.labelText,
    required this.items,
    required this.onChanged,
    this.initialValue,
    this.isRequired = false,
    this.margin = const EdgeInsets.only(top: 24),
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    T? selectedValue;
    if (initialValue != null) {
      // 判断items中是否包含initialValue，如果包含则赋值给selectedValue
      selectedValue = items
          .firstWhereOrNull((element) => element.value == initialValue)
          ?.value;
    }

    return Container(
      margin: margin,
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: hintText ?? '请选择$labelText',
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
        validator: (value) {
          if (isRequired == true && value == null) {
            return hintText ?? '请选择$labelText';
          }
          return null;
        },
        items: items.map<DropdownMenuItem<T>>((DropdownOption<T> option) {
          return DropdownMenuItem(
              value: option.value,
              child: Text(
                option.label,
                style: const TextStyle(fontSize: 12),
              ));
        }).toList(),
        onChanged: onChanged,
        value: selectedValue,
      ),
    );
  }
}
