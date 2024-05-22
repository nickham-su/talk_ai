/// 表单数据项
class LLMFormDataItem {
  String label; // 标签
  String key; // 字段
  String value; // 值
  bool? isRequired; // 是否必填
  bool? isDisabled; // 是否禁止编辑

  LLMFormDataItem({
    required this.label,
    required this.key,
    required this.value,
    this.isRequired,
    this.isDisabled,
  });
}
