import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../shared/components/buttons/cancel_button.dart';
import '../../../../shared/components/buttons/confirm_button.dart';
import '../../../../shared/components/buttons/danger_button.dart';
import '../../../../shared/components/dialog.dart';
import '../../../../shared/components/dialog_widget/dialog_widget.dart';
import '../../../../shared/components/form_widget/dropdown_widget.dart';
import '../../../../shared/components/form_widget/slider_widget.dart';
import '../../../../shared/components/form_widget/text_widget.dart';
import '../../../../shared/components/snackbar.dart';
import '../../controllers/chat_app_list_controller.dart';
import '../../controllers/chat_app_setting_controller.dart';
import '../../models/chat_app_model.dart';
import 'components/image_picker_widget.dart';

class ChatAppSettingDialog extends GetView<ChatAppSettingController> {
  final ChatAppListController chatAppListController =
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
    return DialogWidget(
      width: min(Get.width / 2, 600),
      height: 580,
      title: isEditMode ? '编辑助理' : '新建助理',
      child: Container(
        height: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      DropdownWidget<bool>(
                        labelText: '对话方式',
                        isRequired: true,
                        initialValue: controller.multipleRound,
                        items: [
                          DropdownOption(label: '多轮对话', value: true),
                          DropdownOption(label: '单轮对话', value: false),
                        ],
                        onChanged: (bool? value) {
                          if (value == null) return;
                          controller.multipleRound = value;
                        },
                      ),
                      TextWidget(
                        labelText: '角色设定/提示词（选填）',
                        hintText: '请输入助理角色设定/提示词',
                        initialValue: controller.prompt,
                        maxLines: 4,
                        isRequired: false,
                        onChanged: (value) {
                          controller.prompt = value;
                        },
                      ),
                      DropdownWidget<int>(
                        labelText: '默认模型（选填。如果选择，新会话自动切换该模型）',
                        isRequired: true,
                        initialValue: controller.llmId,
                        items: controller.llmOptions,
                        onChanged: (int? value) {
                          if (value == null) return;
                          controller.llmId = value;
                        },
                      ),
                      SliderWidget(
                        labelText: 'Temperature',
                        tooltip: '''控制生成文本的随机性，它是一个0到2之间的浮点数。
temperature接近0时,模型会变得更加确定和保守,倾向于选择概率最高的下一个词。这会导致输出更加确定但缺乏多样性。
temperature增大时,模型会变得更加随机和富有创造力,生成的文本更加多样化但相关性可能降低。''',
                        labelWidth: 120,
                        initialValue: controller.temperature,
                        max: 2,
                        min: 0.1,
                        divisions: 19,
                        onChanged: (value) {
                          controller.temperature = value;
                        },
                        format: (value) {
                          if (value < 0.55) {
                            return '${value.toStringAsFixed(2)} 严谨';
                          } else if (value < 0.85) {
                            return '${value.toStringAsFixed(2)} 均衡';
                          } else {
                            return '${value.toStringAsFixed(2)} 创意';
                          }
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: Row(
                          children: [
                            const Text('助理头像',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w300)),
                            const SizedBox(width: 84),
                            ImagePickerWidget(
                              data: controller.profilePicture,
                              onSelected: (data) {
                                controller.profilePicture = data;
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 24, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: getButtons(),
              ),
            ),
          ],
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
        chatAppListController.addChatApp(
          name: controller.name,
          prompt: controller.prompt,
          temperature: controller.temperature,
          llmId: controller.llmId,
          multipleRound: controller.multipleRound,
          profilePicture: controller.profilePicture,
        );
        Get.back();
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        snackbar('添加失败', '助理添加失败，请检查助理名称是否重复');
      }
    }
  }

  /// 编辑聊天助理
  void editChatApp() async {
    if (_formKey.currentState!.validate()) {
      try {
        chatAppListController.updateChatApp(
          chatAppId: controller.chatAppId,
          name: controller.name,
          prompt: controller.prompt,
          temperature: controller.temperature,
          llmId: controller.llmId,
          multipleRound: controller.multipleRound,
          profilePicture: controller.profilePicture,
        );
        Get.back();
        await Future.delayed(const Duration(milliseconds: 200));
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
          chatAppListController.deleteChatApp(controller.chatAppId);
          await Future.delayed(const Duration(milliseconds: 200));
          Get.back(); // 关闭设置窗口
          await Future.delayed(const Duration(milliseconds: 200));
        },
      ),
    );
  }
}
