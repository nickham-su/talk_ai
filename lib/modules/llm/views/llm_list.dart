import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../shared/components/layout/models/layout_menu_type.dart';
import '../../../shared/components/resizable_sidebar/resizable_sidebar_widget.dart';
import '../../../shared/components/share/llm_share_import_dialog.dart';
import '../../../shared/models/llm/llm_type.dart';
import '../controllers/llm_controller.dart';
import 'llm_share_dialog.dart';

class LLMList extends GetView<LLMController> {
  const LLMList({super.key});

  @override
  Widget build(BuildContext context) {
    return ResizableSidebarWidget(
      tag: 'llm_list',
      minWidth: 150,
      child: Container(
        decoration: BoxDecoration(
          // color: Get.theme.scaffoldBackgroundColor,
          border: Border(
            right: BorderSide(
              color: Get.theme.colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            const ListHeader(),
            Expanded(
              child: Obx(() => ListView(children: getList())),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getList() {
    return controller.llmService.llmList.map((llm) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Get.theme.colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
        ),
        height: 46,
        child: ListTile(
          onTap: () {
            if (llm.llmId != null) {
              controller.changeIndex(llm.llmId!);
            }
          },
          selected: controller.currentId.value == llm.llmId,
          selectedTileColor: Get.theme.colorScheme.primaryContainer,
          contentPadding: const EdgeInsets.only(left: 16, right: 12),
          trailing: Text(
            llm.type.value,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
          title: Text(
            llm.name,
            style: const TextStyle(
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }).toList();
  }
}

/// 表头
class ListHeader extends GetView<LLMController> {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(LayoutMenuType.llm.value,
              style: Get.textTheme.headlineSmall?.copyWith(
                fontSize: 14,
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
