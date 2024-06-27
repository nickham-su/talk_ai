import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/components/buttons/cancel_button.dart';
import '../../../../shared/components/buttons/confirm_button.dart';
import '../../../../shared/components/dialog_widget/dialog_widget.dart';
import '../../../../shared/components/form_widget/text_widget.dart';
import '../../../../shared/components/snackbar.dart';
import '../../controllers/openai_batch_add_controller.dart';

class OpenaiModelPicker extends StatelessWidget {
  const OpenaiModelPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogWidget(
      width: 600,
      height: 600,
      title: '批量添加OpenAI模型',
      child: GetBuilder<OpenaiBatchAddController>(
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '第2步：选择需要添加的模型',
                    style: TextStyle(
                      height: 1,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 12),
                      minimumSize: const Size(0, 0),
                    ),
                    onPressed: () {
                      controller.selectAll();
                    },
                    child: const Text('全选'),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                  child: ListView.builder(
                itemCount: controller.models.length,
                itemBuilder: (context, index) {
                  return getItem(controller, index);
                },
              )),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 50,
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        '当模型名称冲突时，可添加前后缀',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextWidget(
                      labelText: '前缀',
                      hintText: '添加前缀',
                      initialValue: controller.prefix,
                      margin: EdgeInsets.zero,
                      onChanged: (value) {
                        controller.setPrefix(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: TextWidget(
                      labelText: '后缀',
                      hintText: '添加后缀',
                      initialValue: controller.suffix,
                      margin: EdgeInsets.zero,
                      onChanged: (value) {
                        controller.setSuffix(value);
                      },
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConfirmButton(
                      text: '保存',
                      onPressed: () async {
                        try {
                          controller.save();
                          Get.back();
                        } catch (e) {
                          snackbar('保存失败', e.toString());
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
              )
            ],
          );
        },
      ),
    );
  }

  /// 获取列表项
  Widget getItem(OpenaiBatchAddController controller, int index) {
    final model = controller.models[index];
    final fullName = controller.getFullName(model);
    final isSelect = controller.isSelect(model);
    final existLLM = controller.getExistLLM(model);
    final isExistFullName = controller.isExistCustomName(fullName);

    String text = '';
    Color? color;
    if (existLLM == null) {
      if (isSelect) {
        if (!isExistFullName) {
          text = '添加: $fullName';
        } else {
          text = '添加: $fullName 名称被占用，请添加前后缀';
          color = Get.theme.colorScheme.error;
        }
      } else {
        text = '未添加';
        color = Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.5);
      }
    } else {
      if (isSelect) {
        if (existLLM.name == fullName) {
          text = '已存在';
        } else {
          if (!isExistFullName) {
            text = '已存在，修改名称: ${existLLM.name} -> $fullName';
          } else {
            text = '已存在，修改名称: ${existLLM.name} -> $fullName 被占用，请添加前后缀';
            color = Get.theme.colorScheme.error;
          }
        }
      } else {
        text = '已存在 -> 删除';
        color = Get.theme.colorScheme.error;
      }
    }

    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        model,
        style: TextStyle(
          color: isSelect
              ? null
              : Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w300,
        ),
      ),
      value: isSelect,
      onChanged: (value) {
        controller.toggleSelect(model);
      },
    );
  }
}
