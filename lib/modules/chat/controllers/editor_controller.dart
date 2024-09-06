import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditorController extends GetxController {
  /// 输入框控制器
  final TextEditingController inputController = TextEditingController();

  /// 输入框焦点
  final inputFocusNode = FocusNode();

  @override
  void onClose() {
    inputController.dispose();
    inputFocusNode.dispose();
    super.onClose();
  }

  /// 清空输入框
  void clearContent() {
    inputController.clear();
  }

  /// 设置输入框内容
  void setContent(String content) {
    inputController.text = content;
  }

  /// 获取焦点
  void focus() {
    inputFocusNode.requestFocus();
  }

  /// 输入Enter键
  Future<String?> onEnterKey() async {
    final text1 = inputController.text; // 按Enter键前的文本
    await Future.delayed(const Duration(milliseconds: 16));
    final text2 = inputController.text; // 按Enter键后的文本
    // 比较按Enter键前后的文本，如果是插入换行，则发送消息
    final dmp = DiffMatchPatch();
    List<Diff> diffs = dmp.diff(text1, text2);
    if ((diffs.length == 2 || diffs.length == 3) &&
        (diffs[0].text == '\n' || diffs[1].text == '\n')) {
      final inputText = text1.trim();
      // 恢复文本
      inputController.text = inputText;
      // 发送消息，用text1是因为text2包含换行
      return inputText;
    }
    return null;
  }
}
