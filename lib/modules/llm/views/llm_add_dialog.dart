import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../shared/components/dialog_widget/dialog_widget.dart';
import '../../../shared/models/llm/llm_type.dart';
import '../controllers/llm_controller.dart';
import 'openai_subscription/openai_batch_add_dialog.dart';

class LLMAddDialog extends StatelessWidget {
  final List<LLMType> items = LLMType.values;

  LLMAddDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogWidget(
      width: 600,
      height: 280,
      title: '选择模型类型',
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final llmType = items[index];
          return ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  llmType.info.description,
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  children: llmType.info.docList
                      .map((doc) => DocLink(doc: doc))
                      .toList(),
                )
              ],
            ),
            trailing: SizedBox(
              width: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (llmType == LLMType.openai)
                    TextButton(
                      onPressed: () {
                        Get.back();
                        Get.dialog(
                          OpenaiBatchAddDialog(),
                          barrierDismissible: false,
                        );
                      },
                      child: Text('批量添加'),
                    ),
                  TextButton(
                    onPressed: () {
                      Get.find<LLMController>().addLLM(llmType);
                      Get.back();
                    },
                    child: Text('添加'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('选择模型类型'),
          IconButton(
            onPressed: () {
              Get.back();
            },
            icon: SvgPicture.asset(
              'assets/icons/close.svg',
              width: 24,
              height: 24,
              theme: SvgTheme(
                currentColor: Get.theme.colorScheme.inverseSurface,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 600, // or whatever you need
        height: 280, // or whatever you need
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final llmType = items[index];
            return ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    llmType.info.description,
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    children: llmType.info.docList
                        .map((doc) => DocLink(doc: doc))
                        .toList(),
                  )
                ],
              ),
              trailing: SizedBox(
                width: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (llmType == LLMType.openai)
                      TextButton(
                        onPressed: () {
                          Get.back();
                          Get.dialog(
                            OpenaiBatchAddDialog(),
                            barrierDismissible: false,
                          );
                        },
                        child: Text('批量添加'),
                      ),
                    TextButton(
                      onPressed: () {
                        Get.find<LLMController>().addLLM(llmType);
                        Get.back();
                      },
                      child: Text('添加'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 文档链接
class DocLink extends StatelessWidget {
  final Doc doc;

  const DocLink({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 4),
      child: TextButton(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all<Size>(const Size(0, 32)),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(horizontal: 2)),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        onPressed: () {
          launchUrlString(doc.url);
        },
        child: Text(
          doc.title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w200,
            color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
