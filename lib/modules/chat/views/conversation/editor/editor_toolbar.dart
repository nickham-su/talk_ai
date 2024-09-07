import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../shared/components/snackbar.dart';
import '../../../../../shared/repositories/cache_image_repository.dart';
import '../../../controllers/chat_app_controller.dart';
import '../../../controllers/editor_controller.dart';
import 'llm_picker.dart';
import 'package:image/image.dart' as img;

/// 编辑器工具栏
class EditorToolbar extends StatelessWidget {
  const EditorToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 4),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Get.theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const LLMPicker(),
          const SizedBox(width: 8),
          const AddButton(),
          const SearchButton(),
          getDivider(),
          const UpButton(),
          const BottomButton(),
          getDivider(),
          const AddImageButton(),
          GetBuilder<ChatAppController>(
            id: 'editor_toolbar',
            builder: (controller) {
              if (!controller.isSending) {
                return const SizedBox();
              }
              return Row(
                children: [getDivider(), const StopButton()],
              );
            },
          )
        ],
      ),
    );
  }
}

/// 分割线
Widget getDivider() {
  return Container(
    width: 1,
    height: 20,
    margin: const EdgeInsets.symmetric(horizontal: 12),
    color: Get.theme.colorScheme.outlineVariant.withOpacity(0.5),
  );
}

/// 添加按钮
class AddButton extends StatelessWidget {
  const AddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        padding: const EdgeInsets.all(0),
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size(32, 32)),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        tooltip: '开始新话题',
        icon: SvgPicture.asset(
          'assets/icons/add.svg',
          width: 22,
          height: 22,
          theme: SvgTheme(
            currentColor: Get.theme.colorScheme.inverseSurface,
          ),
        ),
        onPressed: () {
          Get.find<ChatAppController>()
            ..addConversation() // 添加新会话
            ..scrollToBottom(); // 滚动到底部
          // 聚焦输入框
          Get.find<EditorController>().focus();
        },
      ),
    );
  }
}

/// 搜索按钮
class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        padding: const EdgeInsets.all(0),
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size(32, 32)),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        tooltip: '搜索',
        icon: SvgPicture.asset(
          'assets/icons/search.svg',
          width: 17,
          height: 17,
          theme: SvgTheme(
            currentColor: Get.theme.colorScheme.inverseSurface,
          ),
        ),
        onPressed: () {
          final controller = Get.find<ChatAppController>();
          controller.toggleSearch();
        },
      ),
    );
  }
}

/// 停止按钮
class StopButton extends StatelessWidget {
  const StopButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        padding: const EdgeInsets.all(0),
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size(32, 32)),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        tooltip: '停止',
        icon: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Container(
            width: 14,
            height: 14,
            color: Colors.red,
          ),
        ),
        onPressed: () {
          Future.delayed(const Duration(milliseconds: 100)).then((value) {
            // 停止接收
            Get.find<ChatAppController>().stopReceive();
            // 聚焦输入框
            Get.find<EditorController>().focus();
          });
        },
      ),
    );
  }
}

/// 上一个会话按钮
class UpButton extends StatelessWidget {
  const UpButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        padding: const EdgeInsets.all(0),
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size(32, 32)),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        tooltip: '上一个会话',
        icon: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationZ(pi),
          child: SvgPicture.asset(
            'assets/icons/arrow/down.svg',
            width: 20,
            height: 20,
            theme: SvgTheme(
              currentColor: Get.theme.colorScheme.inverseSurface,
            ),
          ),
        ),
        onPressed: () {
          // 滚动到上一个会话
          Get.find<ChatAppController>().scrollToPreviousConversation();
          // 聚焦输入框
          Get.find<EditorController>().focus();
        },
      ),
    );
  }
}

/// 到底部按钮
class BottomButton extends StatelessWidget {
  const BottomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        padding: const EdgeInsets.all(0),
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size(32, 32)),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        tooltip: '到底部',
        icon: SvgPicture.asset(
          'assets/icons/arrow/bottom.svg',
          width: 18,
          height: 18,
          theme: SvgTheme(
            currentColor: Get.theme.colorScheme.inverseSurface,
          ),
        ),
        onPressed: () {
          // 滚动到底部
          Get.find<ChatAppController>().scrollToBottom();
          // 聚焦输入框
          Get.find<EditorController>().focus();
        },
      ),
    );
  }
}

/// 添加图片按钮
class AddImageButton extends StatelessWidget {
  const AddImageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        padding: const EdgeInsets.all(0),
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size(32, 32)),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        tooltip: '添加图片',
        icon: SvgPicture.asset(
          'assets/icons/add_image.svg',
          width: 20,
          height: 20,
          theme: SvgTheme(
            currentColor: Get.theme.colorScheme.inverseSurface,
          ),
        ),
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            withData: true,
          );
          if (result == null) return;
          img.Image? image = img.decodeImage(result.files.single.bytes!);
          if (image == null) {
            snackbar('提示', '图片格式不支持，请重新选择');
            return;
          }
          // 添加缓存
          final imgFile =
              CacheImageRepository.saveLocalImage(result.files.single);
          Get.find<EditorController>()
            ..addFile(imgFile)
            ..focus();
        },
      ),
    );
  }
}
