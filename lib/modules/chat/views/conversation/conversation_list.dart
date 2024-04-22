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
        return CustomScrollView(
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
        );
      },
    );
  }
}
