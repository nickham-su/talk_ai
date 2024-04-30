import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../shared/components/layout/models/layout_menu_type.dart';
import '../../../shared/models/llm/llm_model.dart';
import '../../../shared/models/llm/llm_type.dart';
import '../controllers/llm_controller.dart';
import 'llm_share_dialog.dart';

class LLMList extends GetView<LLMController> {
  const LLMList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ListHeader(),
        Expanded(
          child: Obx(() {
            final currentId = controller.currentId.value;
            return ListView.separated(
              itemCount: controller.llmService.llmList.length,
              itemBuilder: (context, index) {
                final llm = controller.llmService.llmList[index];
                return ListItem(
                  onTap: () {
                    controller.changeIndex(llm.llmId);
                  },
                  selected: currentId == llm.llmId,
                  trailing: llm.type.value,
                  title: llm.name,
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 2);
              },
            );
          }),
        ),
      ],
    );
  }
}

class ListItem extends StatefulWidget {
  final String title;
  final String trailing;
  final bool selected;
  final Function() onTap;

  const ListItem({
    super.key,
    required this.title,
    required this.trailing,
    required this.selected,
    required this.onTap,
  });

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
          padding: const EdgeInsets.only(left: 12, right: 12),
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
                  widget.title,
                  style: TextStyle(
                    fontWeight:
                        widget.selected ? FontWeight.w500 : FontWeight.w300,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                widget.trailing,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 表头
class ListHeader extends GetView<LLMController> {
  const ListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 12, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(LayoutMenuType.llm.value,
              style: Get.textTheme.headlineSmall?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              )),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                tooltip: '添加模型',
                onPressed: () {
                  Get.find<LLMController>().addLLM(LLMType.openai);
                },
                style: ButtonStyle(
                  minimumSize:
                      MaterialStateProperty.all<Size>(const Size(28, 28)),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.all(0),
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
                tooltip: '分享模型',
                onPressed: () {
                  Get.dialog(
                    const LLMShareDialog(),
                    barrierDismissible: true,
                  );
                },
                style: ButtonStyle(
                  minimumSize:
                      MaterialStateProperty.all<Size>(const Size(28, 28)),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.all(0),
                  ),
                ),
                icon: SvgPicture.asset(
                  'assets/icons/share.svg',
                  width: 17,
                  height: 17,
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

/// 添加模型，弹出选择框
void addLLM() {
  List<LLMType> items = LLMType.values;
  Get.dialog(
    AlertDialog(
      title: const Text('选择添加的类型'),
      content: SizedBox(
        width: Get.width / 2, // or whatever you need
        height: 200, // or whatever you need
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(items[index].value),
              onTap: () {
                Get.find<LLMController>().addLLM(items[index]);
                Get.back();
              },
            );
          },
        ),
      ),
    ),
  );
}
