import 'dart:convert';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:TalkAI/modules/chat/repositorys/chat_app_picture_repository.dart';
import 'package:TalkAI/modules/chat/repositorys/chat_app_repository.dart';
import 'package:TalkAI/shared/components/snackbar.dart';
import 'package:TalkAI/shared/repositories/llm_repository.dart';

import '../apis/alipan_api.dart';
import '../apis/api_models.dart';
import '../repositories/alipan_repository.dart';

class SyncController extends GetxController {
  /// 阿里云盘授权地址
  static const authorizeUrl =
      'https://openapi.alipan.com/oauth/authorize?client_id=79a72348cfd74f7e81136fd5b8124ee6&redirect_uri=talkai%3A%2F%2Falipan&scope=user:base,file:all:read,file:all:write&response_type=code&code_challenge_method=S256&code_challenge=';

  /// 随机码
  String randomCode = '';

  /// token
  TokenModel? token;

  /// 阿里云盘信息
  DriveInfo? driveInfo;

  /// 备份盘id
  String? get driveId => driveInfo?.backupDriveId;

  SyncController();

  @override
  void onInit() {
    super.onInit();
    ALiPanRepository.getToken().then((value) {
      token = value;
      ALiPanRepository.getDriveInfo().then((value) {
        driveInfo = value;
        update();
      });
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
      token = await ALiPanApi.getAccessToken(code, randomCode);
      driveInfo = await ALiPanApi.getDriveInfo(token!);
      if (driveInfo!.backupDriveId == null) {
        driveInfo = null;
        snackbar('授权失败', '请在授权时，选择“备份盘”');
        return;
      }
      await ALiPanRepository.saveToken(token!);
      await ALiPanRepository.saveDriveInfo(driveInfo!);
      snackbar('授权成功', '已成功授权阿里云盘');
      update();
    } catch (e) {
      snackbar('授权失败', '请重新登录');
    }
  }

  void sync() async {
    if (token == null) return;
    if (driveInfo == null) return;

    final talkAIFolder = await getFolder();
    final backupFile = await getLastFile(talkAIFolder.fileId);
    print(jsonEncode(backupFile));
    if (backupFile == null) {
      return;
    }
    final data = await ALiPanApi.downloadFile(
      token: token!,
      driveId: driveId!,
      fileId: backupFile.fileId,
    );
    print('data.length: ${data.length}');

    // final data = getLocalData();
    // final hash = sha1.convert(data).toString().toUpperCase();
    // print('hash: $hash');
    //
    // final now = DateTime.now();
    // final nowStr =
    //     '${now.year}_${now.month}_${now.day}_${now.hour}_${now.minute}_${now.second}';
    // ALiPanApi.uploadFile(
    //   token: token!,
    //   driveId: driveId!,
    //   parentFileId: talkAIFolder.fileId,
    //   name: 'backup_$nowStr.json',
    //   data: data,
    // );
  }

  /// 获取文件夹
  Future<FileModel> getFolder() async {
    final driveId = driveInfo!.backupDriveId!;
    // 创建文件夹，如果存在则不创建
    return await ALiPanApi.create(
      token: token!,
      driveId: driveId,
      parentFileId: 'root',
      name: 'TalkAI',
      type: 'folder',
    );
  }

  /// 获取备份列表
  Future<FileModel?> getLastFile(String fileId) async {
    final list = await ALiPanApi.getFileList(
      token: token!,
      driveId: driveId!,
      parentFileId: fileId,
      orderBy: 'created_at',
      orderDirection: 'DESC',
      limit: 1,
      type: 'file',
    );
    return list.isNotEmpty ? list.first : null;
  }

  uploadData() {}

  /// 获取本地数据
  Uint8List getLocalData() {
    final chatAppList = ChatAppRepository.queryAll();
    chatAppList.sort((a, b) => a.name.compareTo(b.name));
    final llmList = LLMRepository.queryAll();
    llmList.sort((a, b) => a.name.compareTo(b.name));
    final data = {
      'chat_app_list': chatAppList
          .map((e) => {
                'name': e.name,
                'prompt': e.prompt,
                'temperature': e.temperature,
                'multiple_round': e.multipleRound,
                'profile_picture': e.profilePicture != null
                    ? base64Encode(e.profilePicture as List<int>)
                    : null,
                'updated_time': e.updatedTime.millisecondsSinceEpoch,
              })
          .toList(),
      'llm_list': llmList.map((e) {
        final map = e.toJson();
        map['name'] = e.name;
        map['type'] = e.type.value;
        return map;
      }).toList(),
    };
    final dataStr = jsonEncode(data);
    return utf8.encode(dataStr);
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
