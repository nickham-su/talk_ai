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
          height: 600,
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
                          maxLines: 4,
                          isRequired: false,
                          onChanged: (value) {
                            controller.prompt = value;
                          },
                        ),
                        Obx(() => DropdownWidget<int>(
                              labelText: '模型',
                              isRequired: true,
                              initialValue: controller.llmId,
                              items: llmService.llmList
                                  .map((e) => DropdownOption<int>(
                                        label: e.name,
                                        value: e.llmId,
                                      ))
                                  .toList(),
                              onChanged: (int? value) {
                                if (value != null) {
                                  controller.llmId = value;
                                }
                              },
                            )),
                        SliderWidget(
                          labelText: '温度',
                          tooltip: '''温度Temperature：
控制生成文本的随机性，它是一个0到1之间的浮点数。
当temperature接近0时,模型会变得更加确定和保守,倾向于选择概率最高的下一个词。这会导致输出更加确定但缺乏多样性。
当temperature接近1时,模型会变得更加随机和富有创造力,生成的文本更加多样化但相关性可能降低。''',
                          labelWidth: 60,
                          initialValue: controller.temperature,
                          max: 1,
                          min: 0.1,
                          divisions: 18,
                          onChanged: (value) {
                            controller.temperature = value;
                          },
                        ),
                        SliderWidget(
                          labelText: 'top_p',
                          tooltip: '''Top_p:
Top_p参数也叫nucleus sampling,用于从概率分布的前p部分中采样下一个词。它同样是0到1之间的浮点数。
当top_p=1时,模型会考虑所有可能的下一个词。
当top_p<1时(如0.9),模型只会从累积概率达到top_p的那些词中采样,忽略概率较低的词。这有助于生成更相关连贯的文本。
适中的top_p值可以过滤掉一些低概率的噪音,同时保留一定的多样性。''',
                          labelWidth: 60,
                          initialValue: controller.topP,
                          max: 1,
                          min: 0.1,
                          divisions: 18,
                          onChanged: (value) {
                            controller.topP = value;
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
  void addChatApp() {
    if (_formKey.currentState!.validate()) {
      try {
        chatAppController.addChatApp(
          name: controller.name,
          prompt: controller.prompt,
          llmId: controller.llmId,
          temperature: controller.temperature,
          topP: controller.topP,
        );
        Get.back();
        snackbar('添加成功', '助理已添加');
      } catch (e) {
        snackbar('添加失败', '助理添加失败，请检查助理名称是否重复');
      }
    }
  }

  /// 编辑聊天助理
  void editChatApp() {
    if (_formKey.currentState!.validate()) {
      try {
        chatAppController.updateChatApp(
          chatAppId: controller.chatAppId,
          name: controller.name,
          prompt: controller.prompt,
          llmId: controller.llmId,
          temperature: controller.temperature,
          topP: controller.topP,
        );
        Get.back();
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
        onPressed: () {
          Get.back(); // 关闭确认对话框
          chatAppController.deleteChatApp(controller.chatAppId);
          Get.back(); // 关闭设置窗口
          snackbar('删除成功', '助理已删除');
        },
      ),
    );
  }
}
