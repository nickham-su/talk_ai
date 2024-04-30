import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/components/buttons/confirm_button.dart';
import '../../../shared/components/buttons/danger_button.dart';
import '../../../shared/components/dialog.dart';
import '../../../shared/components/form_widget/text_widget.dart';
import '../../../shared/components/snackbar.dart';
import '../../../shared/models/llm/llm_model.dart';
import '../controllers/llm_controller.dart';

class LLMSetting extends GetView<LLMController> {
  // 表单key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 最大宽度
  final maxWidth = 700.0;

  LLMSetting({super.key});

  @override
  Widget build(BuildContext context) {
    double parentWidth = MediaQuery.of(context).size.width;
    return Obx(() => Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 49,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          Get.theme.colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                ),
                child: Text(controller.isCreate ? '新建模型' : '编辑模型'),
              ),
              Expanded(
                  child: Center(
                child: Container(
                  width: parentWidth > maxWidth ? maxWidth : parentWidth,
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ListView(
                    children: [
                      ...controller.formData
                          .map((e) => FormItem(data: e))
                          .toList(),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: getButtons(),
                        ),
                      )
                    ],
                  ),
                ),
              )),
            ],
          ),
        ));
  }

  List<Widget> getButtons() {
    List<Widget> buttons = [];
    if (controller.isCreate || controller.isEdit) {
      buttons.add(ConfirmButton(
        text: '保存',
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            try {
              controller.saveLLM();
              if (controller.isCreate) {
                snackbar('恭喜您', '模型添加成功');
              } else {
                snackbar('恭喜您', '模型设置成功');
              }
            } catch (e) {
              snackbar('保存失败', e.toString());
            }
          }
        },
      ));
    }

    if (controller.isEdit) {
      buttons.add(const SizedBox(width: 16));

      buttons.add(DangerButton(
        text: '删除',
        onPressed: () {
          dialog(
            title: '删除模型',
            middleText: '确定要删除该模型吗？',
            confirm: DangerButton(
              text: '删除',
              onPressed: () async {
                controller.deleteLLM();
                Get.back();
                await Future.delayed(const Duration(milliseconds: 200));
                snackbar('提示', '模型已删除');
              },
            ),
          );
        },
      ));
    }

    return buttons;
  }
}

class FormItem extends StatelessWidget {
  final FormDataItem data;

  const FormItem({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextWidget(
      labelText: data.label,
      onChanged: (value) {
        data.value = value;
      },
      initialValue: data.value,
      isRequired: data.isRequired ?? false,
      isDisabled: data.isDisabled ?? false,
    );
  }
}
