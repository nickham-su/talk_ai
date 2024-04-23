import 'package:TalkAI/modules/chat/views/conversation/conversation_list.dart';
import 'package:flutter/material.dart';

import 'editor/editor_widget.dart';
import 'search/search_widget.dart';

class ConversationPage extends StatelessWidget {
  const ConversationPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(children: [
            const ConversationList(),
            SearchWidget(),
          ]),
        ),
        const EditorWidget(),
      ],
    );
  }
}
