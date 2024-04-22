import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'modules/chat/bindings/chat_binding.dart';
import 'modules/chat/views/chat_page.dart';
import 'modules/llm/bindings/llm_binding.dart';
import 'modules/llm/views/llm_page.dart';
import 'modules/setting/bindings/setting_binding.dart';
import 'modules/setting/views/setting_page.dart';

// 路由页面构建器
typedef PageBuilder = Widget Function();

class Routes {
  static const String chat = '/chat';
  static const String llm = '/llm';
  static const String template = '/template';
  static const String setting = '/setting';

  static final routes = [
    GetPage(
      name: chat,
      page: () => const ChatPage(),
      preventDuplicates: true,
      transition: Transition.noTransition,
      bindings: [
        ChatBinding(),
      ],
    ),
    GetPage(
      name: llm,
      page: () => const LLMPage(),
      preventDuplicates: true,
      transition: Transition.noTransition,
      bindings: [
        LLMBinding(),
      ],
    ),
    GetPage(
      name: setting,
      page: () => const SettingPage(),
      preventDuplicates: true,
      transition: Transition.noTransition,
      bindings: [
        SettingBinding(),
      ],
    ),
  ];
}
