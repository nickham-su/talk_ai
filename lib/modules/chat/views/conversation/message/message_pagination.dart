import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/message_pagination_controller.dart';
import '../../../../../shared/models/message/conversation_message_model.dart';

class MessagePagination extends StatelessWidget {
  // 消息ID
  final ConversationMessageModel message;

  const MessagePagination({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessagePaginationController>(
      id: 'message_pagination_${message.msgId}',
      tag: 'message_pagination_${message.msgId}',
      init: MessagePaginationController(message.msgId),
      builder: (controller) {
        return Container(
          width: double.infinity,
          height: 30,
          margin: const EdgeInsets.only(top: 16,left: 12),
          child: ListView.builder(
            itemCount: controller.indexList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return paginationButton(
                text: (index + 1).toString(),
                selected:
                    controller.messages[index].generateId == message.generateId,
                onPressed: () {
                  controller.selectMessage(index);
                },
              );
            },
          ),
        );
      },
    );
  }
}

/// 分页按钮
Widget paginationButton({
  String? text,
  Widget? child,
  bool selected = false,
  void Function()? onPressed,
}) {
  return Container(
    alignment: Alignment.center,
    margin: const EdgeInsets.only(right: 4),
    child: IconButton(
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(Size(24, 24)),
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        backgroundColor: selected
            ? MaterialStateProperty.all(Get.theme.colorScheme.primaryContainer)
            : MaterialStateProperty.all(
                Get.theme.colorScheme.secondaryContainer.withOpacity(0.2)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      onPressed: onPressed,
      icon: child ??
          Text(
            text ?? '',
            style: TextStyle(
              height: 1,
              fontWeight: FontWeight.w300,
              color: selected
                  ? Get.theme.colorScheme.primary
                  : Get.theme.colorScheme.inverseSurface.withOpacity(0.35),
            ),
          ),
    ),
  );
}
