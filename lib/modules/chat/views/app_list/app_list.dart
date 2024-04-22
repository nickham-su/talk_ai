import 'package:talk_ai/modules/chat/models/chat_app_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../shared/components/layout/models/layout_menu_type.dart';
import '../../controllers/chat_app_list_controller.dart';
import 'chat_app_setting_dialog.dart';

class AppList extends GetView<ChatAppListController> {
  const AppList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // color: Get.theme.scaffoldBackgroundColor,
        border: Border(
          right: BorderSide(
            color: Get.theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
      ),
      width: 200,
      height: double.infinity,
      child: Column(
        children: [
          const ListHeader(),
          Expanded(
            child: Obx(() => ListView(children: getChatAppList())),
          ),
        ],
      ),
    );
  }

  List<Widget> getChatAppList() {
    final list = controller.chatAppList
        .map((app) => ListItem(
            app: app,
            selected: app.chatAppId == controller.currentChatAppId.value,
            onTap: () {
              controller.selectChatApp(app.chatAppId);
            }))
        .toList();
    return list;
  }
}

class ListItem extends StatefulWidget {
  final ChatAppModel app;
  final bool selected;
  final Function() onTap;

  const ListItem(
      {super.key,
      required this.app,
      required this.selected,
      required this.onTap});

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          hover = true;
        });
      },
      onExit: (event) async {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          hover = false;
        });
      },
      child: ListTile(
        title: Text(
          widget.app.name,
          style: const TextStyle(
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: hover == false
            ? null
            : Tooltip(
                waitDuration: const Duration(milliseconds: 500),
                showDuration: Duration.zero,
                message: '设置',
                child: IconButton(
                  onPressed: () {
                    Get.dialog(
                      ChatAppSettingDialog(chatAppModel: widget.app),
                      barrierDismissible: true,
                    );
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/setting.svg',
                    width: 16,
                    height: 16,
                    theme: SvgTheme(
                      currentColor: Get.theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ),
        selected: widget.selected,
        selectedTileColor: Get.theme.colorScheme.primaryContainer,
        contentPadding: const EdgeInsets.only(left: 16),
        onTap: widget.onTap,
      ),
    );
  }
}

/// 表头
class ListHeader extends GetView<ChatAppListController> {
  const ListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Get.theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(LayoutMenuType.chat.value,
              style: Get.textTheme.headlineSmall?.copyWith(
                fontSize: 14,
              )),
          IconButton(
            tooltip: '添加助理',
            onPressed: () {
              controller.showChatAppSettingDialog();
            },
            icon: SvgPicture.asset(
              'assets/icons/add.svg',
              width: 18,
              height: 18,
              theme: SvgTheme(
                currentColor: Get.theme.colorScheme.inverseSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
