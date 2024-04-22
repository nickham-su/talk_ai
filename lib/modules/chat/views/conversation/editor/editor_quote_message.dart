import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../shared/models/message/message_model.dart';
import '../../../controllers/chat_app_controller.dart';

class EditorQuoteMessage extends StatelessWidget {
  const EditorQuoteMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatAppController>(
      id: 'editor_quote_message',
      builder: (controller) {
        if (controller.quoteMessage == null) {
          return const SizedBox();
        }

        final quoteMessage = controller.quoteMessage!;
        late String quoteType;
        if (quoteMessage.role == MessageRole.user) {
          quoteType = '修改';
        } else {
          quoteType = '回复';
        }

        final msgLength = quoteMessage.content.length;
        const maxLength = 40;
        String content = quoteMessage.content.substring(0, min(maxLength, msgLength));
        if (msgLength > maxLength) {
          content += '...';
        }
        // 删除content中的换行符
        content = content.replaceAll(RegExp(r'\n'), ' ');

        // 四周都有边框
        return Row(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Get.theme.colorScheme.primary.withOpacity(0.5),
                ),
              ),
              padding: const EdgeInsets.only(left: 8, right: 2, top: 4, bottom: 4),
              child: Row(
                children: [
                  Text(
                    '$quoteType: $content',
                    style: TextStyle(
                      color: Get.theme.colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                  IconButton(
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    icon: SvgPicture.asset(
                      'assets/icons/close.svg',
                      width: 16,
                      height: 16,
                      theme: SvgTheme(
                        currentColor:
                        Get.theme.colorScheme.primary,
                      ),
                    ),
                    onPressed: () {
                      controller.removeQuote();
                    },
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
