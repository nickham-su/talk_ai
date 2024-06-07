import 'dart:convert';
import 'dart:math';

import 'package:TalkAI/shared/components/snackbar.dart';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../apis/alipan_api.dart';
import '../repositories/alipan_repository.dart';

class SyncController extends GetxController {
  /// 阿里云盘授权地址
  static const authorizeUrl =
      'https://openapi.alipan.com/oauth/authorize?client_id=79a72348cfd74f7e81136fd5b8124ee6&redirect_uri=talkai%3A%2F%2Falipan&scope=user:base,file:all:read,file:all:write&response_type=code&code_challenge_method=S256&code_challenge=';

  /// 随机码
  String randomCode = '';

  /// 阿里云盘信息
  DriveInfo? driveInfo;

  SyncController();

  @override
  void onInit() {
    super.onInit();
    ALiPanRepository.getDriveInfo().then((value) {
      driveInfo = value;
      update();
    });
  }

  /// 登录阿里云盘
  void loginAliPan() {
    randomCode = generateRandomString(64);
    final digest = sha256.convert(randomCode.codeUnits); // 计算SHA-256哈希
    final base64String = base64UrlEncode(digest.bytes); // base64编码
    launchUrlString(authorizeUrl + base64String);
  }

  /// 退出登录
  void logoutAliPan() async {
    await ALiPanRepository.deleteToken();
    await ALiPanRepository.deleteDriveInfo();
    driveInfo = null;
    update();
  }

  /// 获取阿里云盘信息
  void getAliPanInfo(String code) async {
    try {
      ALiPanRepository.deleteToken();
      ALiPanRepository.deleteDriveInfo();
      final token = await ALiPanApi.getAccessToken(code, randomCode);
      driveInfo = await ALiPanApi.getDriveInfo(token);
      if (driveInfo!.backupDriveId == null) {
        snackbar('授权失败', '请在授权时，选择“备份盘”');
        return;
      }
      await ALiPanRepository.saveToken(token);
      await ALiPanRepository.saveDriveInfo(driveInfo!);
      snackbar('授权成功', '已成功授权阿里云盘');
      update();
    } catch (e) {
      snackbar('授权失败', '请重新登录');
    }
  }
}

/// 生成随机字符
String generateRandomString(int length) {
  const charPool =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  var random = Random();
  return List.generate(length, (_) => charPool[random.nextInt(charPool.length)])
      .join();
}
