import 'dart:convert';

import 'package:TalkAI/modules/chat/models/chat_app_model.dart';
import 'package:get/get.dart';

import '../../../shared/models/llm/llm.dart';
import '../../../shared/services/llm_service.dart';
import '../../../shared/utils/compress.dart';
import 'chat_app_list_controller.dart';

class ChatAppShareController extends GetxController {
  /// 选中状态
  final Map<int, bool> selected = {};

  /// 是否选中
  bool isSelect(int chatAppId) => selected[chatAppId] ?? false;

  /// 切换选中状态
  void toggleSelect(int chatAppId) {
    selected[chatAppId] = !(selected[chatAppId] ?? false);
    update();
  }

  /// 分享头像
  bool shareProfilePicture = false;

  /// 设置分享头像
  void setShareProfilePicture(value) {
    shareProfilePicture = value;
    update();
  }

  /// 获取分享链接
  String getShareUrl() {
    List<int> chatAppIds = [];
    for (var key in selected.keys) {
      if (selected[key] == true) {
        chatAppIds.add(key);
      }
    }
    final chatAppListController = Get.find<ChatAppListController>();

    List<ChatAppModel> chatApps = chatAppListController.chatAppList.value
        .where((element) => chatAppIds.contains(element.chatAppId))
        .toList();

    List<Map> apps = chatApps.map((e) {
      return {
        'name': e.name,
        'prompt': e.prompt,
        'temperature': e.temperature,
        'multiple_round': e.multipleRound,
        'profile_picture': shareProfilePicture && e.profilePicture != null
            ? base64Encode(e.profilePicture as List<int>)
            : null,
      };
    }).toList();
    final jsonStr = jsonEncode({'apps': apps});
    final compressed = gzipCompress(jsonStr);
    return '您的好友分享了${apps.length}个助理。打开TalkAI，在[同步]页面中导入：\ntalkai://share/$compressed';
  }
}
