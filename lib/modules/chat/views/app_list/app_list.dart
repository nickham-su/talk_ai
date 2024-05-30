import 'package:TalkAI/modules/chat/models/chat_app_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../shared/components/layout/models/layout_menu_type.dart';
import '../../controllers/chat_app_list_controller.dart';
import 'app_share_dialog.dart';
import 'chat_app_setting_dialog.dart';

class AppList extends GetView<ChatAppListController> {
  const AppList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ListHeader(),
        Expanded(
          child: Obx(
            () => ListView.separated(
              itemCount: controller.chatAppList.length,
              itemBuilder: (context, index) {
                final app = controller.chatAppList[index];
                return ListItem(
                    key: ValueKey('key_chat_app_${app.chatAppId}'),
                    app: app,
                    selected:
                        app.chatAppId == controller.currentChatAppId.value,
                    onTap: () {
                      controller.selectChatApp(app.chatAppId);
                    });
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 2);
              },
            ),
          ),
        ),
      ],
    );
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
      cursor: SystemMouseCursors.click,
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
      child: GestureDetector(
        onTap: () {
          widget.onTap();
        },
        child: Container(
          padding: const EdgeInsets.only(left: 12),
          height: 40,
          decoration: BoxDecoration(
            color: widget.selected
                ? Get.theme.colorScheme.primaryContainer
                : hover
                    ? Get.theme.colorScheme.secondaryContainer.withOpacity(0.4)
                    : null,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.app.name,
                  style: TextStyle(
                    fontWeight:
                        widget.selected ? FontWeight.w500 : FontWeight.w300,
                    fontSize: 14,
                    height: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hover && widget.selected) getButtons(widget.app)
            ],
          ),
        ),
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
      height: 60,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 12, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(LayoutMenuType.chat.value,
              style: Get.textTheme.headlineSmall?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              )),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                tooltip: '添加助理',
                onPressed: () {
                  controller.showChatAppSettingDialog();
                },
                style: ButtonStyle(
                  minimumSize:
                      MaterialStateProperty.all<Size>(const Size(28, 28)),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.all(0),
                  ),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                icon: SvgPicture.asset(
                  'assets/icons/add.svg',
                  width: 20,
                  height: 20,
                  theme: SvgTheme(
                    currentColor: Get.theme.colorScheme.secondary,
                  ),
                ),
              ),
              IconButton(
                tooltip: '分享助理',
                onPressed: () {
                  Get.dialog(
                    const AppShareDialog(),
                    barrierDismissible: false,
                  );
                },
                style: ButtonStyle(
                  minimumSize:
                      MaterialStateProperty.all<Size>(const Size(28, 28)),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.all(0),
                  ),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                icon: SvgPicture.asset(
                  'assets/icons/share.svg',
                  width: 16,
                  height: 16,
                  theme: SvgTheme(
                    currentColor: Get.theme.colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ],
      ),
    );
  }
}

/// 按钮
Widget getButtons(ChatAppModel chatApp) {
  return Container(
    width: 60,
    child: Row(
      children: [
        Tooltip(
          waitDuration: const Duration(milliseconds: 500),
          showDuration: Duration.zero,
          message:
              chatApp.toppingTime.millisecondsSinceEpoch == 0 ? '置顶' : '取消置顶',
          child: IconButton(
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all<Size>(const Size(28, 28)),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.all(0),
              ),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            onPressed: () async {
              await Future.delayed(const Duration(milliseconds: 100));
              Get.find<ChatAppListController>().toggleTop(chatApp.chatAppId);
            },
            icon: SvgPicture.asset(
              chatApp.toppingTime.millisecondsSinceEpoch == 0
                  ? 'assets/icons/arrow/top.svg'
                  : 'assets/icons/arrow/top_cancel.svg',
              width: 16,
              height: 16,
              theme: SvgTheme(
                currentColor: Get.theme.colorScheme.secondary,
              ),
            ),
          ),
        ),
        Tooltip(
          waitDuration: const Duration(milliseconds: 500),
          showDuration: Duration.zero,
          message: '设置',
          child: IconButton(
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all<Size>(const Size(28, 28)),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.all(0),
              ),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            onPressed: () {
              Get.dialog(
                ChatAppSettingDialog(chatAppModel: chatApp),
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
      ],
    ),
  );
}
