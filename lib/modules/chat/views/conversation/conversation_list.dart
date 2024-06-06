import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/chat_app_controller.dart';
import 'conversation_widget.dart';

class ConversationList extends StatelessWidget {
  const ConversationList({super.key});

  @override
  Widget build(BuildContext context) {
    final centerKey = GlobalKey();

    /// 鼠标按下开始移动时间
    int startMoveTime = 0;

    return GetBuilder<ChatAppController>(
      builder: (controller) {
        return Column(
          children: [
            Expanded(
              child: Listener(
                onPointerUp: (PointerUpEvent event) {
                  startMoveTime = 0;
                  controller.stopScrolling();
                },
                onPointerMove: (PointerMoveEvent event) {
                  if (startMoveTime == 0) {
                    startMoveTime = DateTime.now().millisecondsSinceEpoch;
                  }
                  // 防止误触发滚动
                  if (DateTime.now().millisecondsSinceEpoch - startMoveTime <
                      300) {
                    return;
                  }
                  final RenderBox renderBox =
                      context.findRenderObject() as RenderBox;
                  final Offset localPosition =
                      renderBox.globalToLocal(event.position);
                  const double edgeThreshold = 100.0; // 边缘阈值，可以根据需要调整

                  if (localPosition.dy < edgeThreshold) {
                    controller.startScrolling(-1.0); // 向上滚动
                  } else if (localPosition.dy >
                      renderBox.size.height - edgeThreshold) {
                    controller.startScrolling(1.0); // 向下滚动
                  } else {
                    controller.stopScrolling();
                  }
                },
                child: CustomScrollView(
                  key: controller.scrollKey,
                  controller: controller.scrollController,
                  center: centerKey,
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final current =
                              controller.topConversationIds.length - 1 - index;
                          final conversationId =
                              controller.topConversationIds[current];
                          return ConversationWidget(
                            key: ValueKey('key_conversation_$conversationId'),
                            conversationId: conversationId,
                          );
                        },
                        childCount: controller.topConversationIds.length,
                      ),
                    ),
                    SliverList(
                      key: centerKey,
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final conversationId =
                              controller.bottomConversationIds[index];
                          return ConversationWidget(
                            key: ValueKey('key_conversation_$conversationId'),
                            conversationId: conversationId,
                          );
                        },
                        childCount: controller.bottomConversationIds.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (controller.showHistoryMessageHint)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
                color: Get.theme.colorScheme.primaryContainer.withOpacity(0.5),
                child: Text(
                  '可以点击下方的"+"，开始新话题。避免过多的历史信息对模型产生影响。',
                  style: TextStyle(
                    color:
                        Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
