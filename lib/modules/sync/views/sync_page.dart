import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/components/buttons/confirm_button.dart';
import '../../../shared/components/layout/models/layout_menu_type.dart';
import '../../../shared/components/layout/views/layout.dart';
import '../../../shared/components/share/llm_share_import_dialog.dart';
import '../controllers/sync_controller.dart';

class SyncPage extends StatelessWidget {
  // 最大宽度
  final maxWidth = 700.0;

  const SyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    double parentWidth = MediaQuery.of(context).size.width;

    return Layout(
      currentMenu: LayoutMenuType.sync,
      child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 80),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.background,
          ),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              width: parentWidth > maxWidth ? maxWidth : parentWidth,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GetBuilder<SyncController>(builder: (controller) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: const Text('阿里云盘同步',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold))),
                        const Text('将助理和模型的设置信息保存到阿里云盘，不包含聊天信息'),
                        const Text('使用场景：数据备份、多设备同步'),
                        const SizedBox(height: 8),
                        if (controller.driveId == null)
                          Text(
                            '阿里云盘需要自己注册（有赠送免费容量）',
                            style: TextStyle(
                              color: Get.theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.5),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        if (controller.driveId == null)
                          const SizedBox(height: 12),
                        controller.driveInfo != null
                            ? Row(
                                children: [
                                  Text(
                                    '已授权：${controller.driveInfo!.name}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    child: Text('取消授权'),
                                    onPressed: () {
                                      controller.logoutAliPan();
                                    },
                                  ),
                                ],
                              )
                            : ConfirmButton(
                                text: '阿里云盘授权',
                                onPressed: () {
                                  controller.loginAliPan();
                                },
                              ),
                        if (controller.driveId != null &&
                            controller.lastSyncTimeStr != null)
                          Text(
                            '上次同步时间: ${controller.lastSyncTimeStr}',
                            style: TextStyle(
                              color: Get.theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.7),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (controller.driveId != null)
                          ConfirmButton(
                            text: controller.isSyncing ? '正在同步数据...' : '立即同步',
                            onPressed: controller.isSyncing
                                ? null
                                : () {
                                    controller.sync();
                                  },
                          ),
                        const SizedBox(height: 40),
                      ],
                    );
                  }),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: const Text('导入分享数据',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold))),
                      const Text('导入好友分享的助理和模型：'),
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 24),
                        child: ConfirmButton(
                          text: '导入数据',
                          onPressed: () {
                            Get.dialog(
                              const LLMShareImportDialog(),
                              barrierDismissible: true,
                            );
                          },
                        ),
                      ),
                      Text('分享数据方法：点击助理和模型列表上面的分享按钮，进行分享',
                          style: TextStyle(
                              color: Get.theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.5))),
                      const SizedBox(height: 8),
                      Text('以下是分享信息示例：',
                          style: TextStyle(
                              color: Get.theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.5))),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Get.theme.colorScheme.secondaryContainer
                              .withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectionArea(
                          child: Text(
                            '您的好友分享了1个助理。打开TalkAI，在[同步]页面中导入：\ntalkai://share/H4sIAAAAAAAAE6tWSiwoKFayiq5WykvMTVWyUnratfL5hDYlHaWCovzcghKgCJBdkppbkFqUWFJaBFRiqGego5RbmlOSWZCTGl%2BUX5qXomRVUlSaCtaTlgkULMhMhqjNK83JqY2tBQBX67j9ZwAAAA%3D%3D',
                            style: TextStyle(
                                color: Get.theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.5)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  )
                ],
              ))),
    );
  }
}
