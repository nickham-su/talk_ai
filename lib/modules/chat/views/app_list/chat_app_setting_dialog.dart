import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/components/buttons/cancel_button.dart';
import '../../../../shared/components/buttons/confirm_button.dart';
import '../../../../shared/components/buttons/danger_button.dart';
import '../../../../shared/components/dialog.dart';
import '../../../../shared/components/form_widget/dropdown_widget.dart';
import '../../../../shared/components/form_widget/slider_widget.dart';
import '../../../../shared/components/form_widget/text_widget.dart';
import '../../../../shared/components/snackbar.dart';
import '../../../../shared/services/llm_service.dart';
import '../../controllers/chat_app_list_controller.dart';
import '../../controllers/chat_app_setting_controller.dart';
import '../../models/chat_app_model.dart';

class ChatAppSettingDialog extends GetView<ChatAppSettingController> {
  final llmService = Get.find<LLMService>();
  final ChatAppListController chatAppController =
      Get.find<ChatAppListController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ChatAppSettingDialog({super.key, ChatAppModel? chatAppModel}) {
    if (chatAppModel != null) {
      controller.setFormData(chatAppModel);
    } else {
      controller.initFormData();
    }
  }

  /// 编辑模型状态
  get isEditMode => controller.chatAppId != 0;

  @override
  Widget build(BuildContext context) {
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
          width: 700,
          height: 500,
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
                      color:
                          Get.theme.colorScheme.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                ),
                child: Text(
                  isEditMode ? '编辑助理' : '新建助理',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextWidget(
                          labelText: '助理名称',
                          hintText: '请输入助理名称',
                          initialValue: controller.name,
                          isRequired: true,
                          onChanged: (value) {
                            controller.name = value;
                          },
                        ),
                        TextWidget(
                          labelText: '角色设定/提示词（选填）',
                          hintText: '请输入助理角色设定/提示词',
                          initialValue: controller.prompt,
                          maxLines: 8,
                          isRequired: false,
                          onChanged: (value) {
                            controller.prompt = value;
                          },
                        ),
                        SliderWidget(
                          labelText: 'Temperature',
                          tooltip: '''控制生成文本的随机性，它是一个0到1之间的浮点数。
当temperature接近0时,模型会变得更加确定和保守,倾向于选择概率最高的下一个词。这会导致输出更加确定但缺乏多样性。
当temperature接近1时,模型会变得更加随机和富有创造力,生成的文本更加多样化但相关性可能降低。''',
                          labelWidth: 120,
                          initialValue: controller.temperature,
                          max: 1,
                          min: 0.1,
                          divisions: 18,
                          onChanged: (value) {
                            controller.temperature = value;
                          },
                          format: (value) {
                            if (value <= 0.65) {
                              return '${value.toStringAsFixed(2)} 严谨';
                            } else if (value <= 0.85) {
                              return '${value.toStringAsFixed(2)} 均衡';
                            } else {
                              return '${value.toStringAsFixed(2)} 创意';
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: getButtons(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> getButtons() {
    List<Widget> buttuns = [
      ConfirmButton(
        text: isEditMode ? '保存' : '添加',
        onPressed: () {
          if (isEditMode) {
            editChatApp();
          } else {
            addChatApp();
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
    ];

    if (isEditMode) {
      buttuns.add(const SizedBox(width: 16));
      buttuns.add(DangerButton(
        text: '删除',
        onPressed: deleteChatApp,
      ));
    }
    return buttuns;
  }

  /// 添加聊天助理
  void addChatApp() async {
    if (_formKey.currentState!.validate()) {
      try {
        chatAppController.addChatApp(
          name: controller.name,
          prompt: controller.prompt,
          temperature: controller.temperature,
          topP: controller.topP,
        );
        Get.back();
        await Future.delayed(const Duration(milliseconds: 200));
        snackbar('添加成功', '助理已添加');
      } catch (e) {
        snackbar('添加失败', '助理添加失败，请检查助理名称是否重复');
      }
    }
  }

  /// 编辑聊天助理
  void editChatApp() async {
    if (_formKey.currentState!.validate()) {
      try {
        chatAppController.updateChatApp(
          chatAppId: controller.chatAppId,
          name: controller.name,
          prompt: controller.prompt,
          temperature: controller.temperature,
          topP: controller.topP,
        );
        Get.back();
        await Future.delayed(const Duration(milliseconds: 200));
        snackbar('保存成功', '助理设置已保存');
      } catch (e) {
        snackbar('保存失败', '助理设置失败，请检查助理名称是否重复');
      }
    }
  }

  /// 删除聊天助理
  void deleteChatApp() {
    dialog(
      title: '删除当前助理',
      middleText: '确定要删除当前助理吗？',
      confirm: DangerButton(
        text: '删除',
        onPressed: () async {
          Get.back(); // 关闭确认对话框
          chatAppController.deleteChatApp(controller.chatAppId);
          await Future.delayed(const Duration(milliseconds: 200));
          Get.back(); // 关闭设置窗口
          await Future.delayed(const Duration(milliseconds: 200));
          snackbar('删除成功', '助理已删除');
        },
      ),
    );
  }
}
