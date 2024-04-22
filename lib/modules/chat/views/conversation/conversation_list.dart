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

    return GetBuilder<ChatAppController>(
      builder: (controller) {
        return Listener(
          onPointerUp: (PointerUpEvent event) {
            controller.stopScrolling();
          },
          onPointerMove: (PointerMoveEvent event) {
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
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
            controller: controller.scrollController,
            center: centerKey,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final current =
                        controller.topConversationIds.length - 1 - index;
                    return ConversationWidget(
                      key: ValueKey(controller.topConversationIds[current]),
                      conversationId: controller.topConversationIds[current],
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
                      key: ValueKey(conversationId),
                      conversationId: conversationId,
                    );
                  },
                  childCount: controller.bottomConversationIds.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
