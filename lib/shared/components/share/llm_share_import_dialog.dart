import 'dart:convert';

import 'package:TalkAI/modules/llm/controllers/llm_share_controller.dart';
import 'package:TalkAI/shared/components/snackbar.dart';
import 'package:TalkAI/shared/utils/compress.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../buttons/cancel_button.dart';
import '../buttons/confirm_button.dart';
import '../../services/llm_service.dart';
import '../form_widget/text_widget.dart';

class LLMShareImportDialog extends StatelessWidget {
  final String? importValue;

  const LLMShareImportDialog({Key? key, this.importValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String input = importValue ?? '';

    return GetBuilder<LLMShareController>(
      init: LLMShareController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Get.theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Get.theme.colorScheme.outlineVariant,
                ),
              ),
              width: 500,
              height: 300,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 48,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Get.theme.colorScheme.outlineVariant
                              .withOpacity(0.5),
                        ),
                      ),
                    ),
                    child: const Text(
                      '导入数据',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextWidget(
                        labelText: '粘贴分享连接',
                        hintText: '请在此粘贴分享连接',
                        initialValue: input,
                        maxLines: 6,
                        isRequired: false,
                        onChanged: (value) {
                          input = value;
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConfirmButton(
                          text: '导入',
                          onPressed: () {
                            importData(input.trim());
                          },
                        ),
                        const SizedBox(width: 16),
                        CancelButton(
                          text: '取消',
                          onPressed: () {
                            Get.back();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void importData(String url) async {
    final compressed = url.replaceAll('talkai://', '');
    final jsonStr = gzipDecompress(compressed);
    final data = jsonDecode(jsonStr);

    final countModels = data['models']?.length ?? 0;
    final List<String> failureModelsList = [];

    if (countModels > 0) {
      for (final model in data['models']) {
        try {
          Get.find<LLMService>().addLLM(model);
        } catch (e) {
          if (model['name'] != null) {
            failureModelsList.add(model['name']);
          }
        }
      }
    }
    Get.back();
    await Future.delayed(const Duration(milliseconds: 200));

    String ret = '';
    if (countModels > 0) {
      ret += '模型：成功导入${countModels - failureModelsList.length}个\n';
      if (failureModelsList.isNotEmpty) {
        ret += '导入失败: ${failureModelsList.join('、')}';
      }
    }
    snackbar('导入结果', ret);
  }
}
