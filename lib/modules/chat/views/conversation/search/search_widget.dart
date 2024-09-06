import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../controllers/chat_app_controller.dart';
import '../../../controllers/editor_controller.dart';

class SearchWidget extends StatelessWidget {
  SearchWidget({Key? key}) : super(key: key);
  final inputController = TextEditingController();
  final inputFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatAppController>(
      builder: (controller) {
        if (!controller.showSearch) {
          inputController.clear();
          return const SizedBox();
        }

        // 显示搜索框，如果搜索关键字为空，则自动获取焦点
        if (inputController.text.isEmpty) {
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            inputFocusNode.requestFocus();
          });
        }

        return Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
              ),
              border: Border(
                top: BorderSide(
                  color: Get.theme.colorScheme.outlineVariant,
                ),
                right: BorderSide(
                  color: Get.theme.colorScheme.outlineVariant,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Get.theme.colorScheme.outlineVariant.withOpacity(0.2),
                  offset: const Offset(4, -4),
                  blurRadius: 8,
                ),
              ],
            ),
            width: 400,
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 8, right: 8),
                    child: TextField(
                      controller: inputController,
                      focusNode: inputFocusNode,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                      decoration: InputDecoration(
                        hintText: '搜索',
                        contentPadding: EdgeInsets.only(left: 8),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 1.5,
                            color: Get.theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: '上一个',
                  icon: SvgPicture.asset(
                    'assets/icons/arrow/arrowup.svg',
                    width: 16,
                    height: 16,
                    theme: SvgTheme(
                      currentColor: Get.theme.colorScheme.secondary,
                    ),
                  ),
                  onPressed: () {
                    controller.searchMessage(
                      keyword: inputController.text,
                      isDesc: true,
                    );
                  },
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: '下一个',
                  icon: SvgPicture.asset(
                    'assets/icons/arrow/arrowdown.svg',
                    width: 16,
                    height: 16,
                    theme: SvgTheme(
                      currentColor: Get.theme.colorScheme.secondary,
                    ),
                  ),
                  onPressed: () {
                    controller.searchMessage(
                      keyword: inputController.text,
                      isDesc: false,
                    );
                  },
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: '关闭',
                  icon: SvgPicture.asset(
                    'assets/icons/close.svg',
                    width: 16,
                    height: 16,
                    theme: SvgTheme(
                      currentColor: Get.theme.colorScheme.secondary,
                    ),
                  ),
                  onPressed: () async {
                    await Future.delayed(const Duration(milliseconds: 100));
                    controller.toggleSearch();
                    // 聚焦输入框
                    Get.find<EditorController>().focus();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
