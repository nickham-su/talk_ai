import 'dart:convert';

import 'package:TalkAI/modules/llm/controllers/llm_share_controller.dart';
import 'package:TalkAI/shared/components/snackbar.dart';
import 'package:TalkAI/shared/utils/compress.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../modules/chat/repositorys/chat_app_repository.dart';
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
                          onPressed: () async {
                            try {
                              await importData(input.trim());
                            } catch (e) {
                              snackbar('导入失败', '请检查分享链接是否正确！');
                            }
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

  importData(String url) async {
    final reg = RegExp(r'^(.*?\n)*?talkai://');
    final compressed = url.replaceAll(reg, '');
    final jsonStr = gzipDecompress(compressed);
    final data = jsonDecode(jsonStr);

    /// 导入模型
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

    /// 导入助理
    final countChatApps = data['apps']?.length ?? 0;
    final List<String> failureChatAppsList = [];
    if (countChatApps > 0) {
      for (final app in data['apps']) {
        try {
          ChatAppRepository.insert(
            name: app['name'],
            prompt: app['prompt'],
            llmId: -1,
            temperature: app['temperature'],
          );
        } catch (e) {
          if (app['name'] != null) {
            failureChatAppsList.add(app['name']);
          }
        }
      }
    }

    /// 关闭对话框
    Get.back();
    await Future.delayed(const Duration(milliseconds: 200));

    /// 提示导入结果
    String ret = '';
    if (countModels > 0) {
      ret += '模型：成功导入${countModels - failureModelsList.length}个';
      if (failureModelsList.isNotEmpty) {
        ret += '\n导入失败: ${failureModelsList.join('、')}';
      }
    }
    if (countChatApps > 0) {
      if (ret.isNotEmpty) {
        ret += '\n\n';
      }
      final countSuccess = countChatApps - failureChatAppsList.length;
      ret += '助理：成功导入$countSuccess个';
      if (failureChatAppsList.isNotEmpty) {
        ret += '\n导入失败: ${failureChatAppsList.join('、')}';
      }
      if (countSuccess > 0) {
        ret += '\n使用前，需要为助理设置模型！';
      }
    }
    snackbar('导入结果', ret, duration: const Duration(seconds: 5));
  }
}
