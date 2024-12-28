import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:TalkAI/modules/chat/repositorys/chat_app_repository.dart';
import 'package:TalkAI/shared/components/snackbar.dart';
import 'package:TalkAI/shared/repositories/llm_repository.dart';

import '../../../shared/models/llm/llm.dart';
import '../../../shared/services/llm_service.dart';
import '../../chat/controllers/chat_app_list_controller.dart';
import '../../chat/models/chat_app_model.dart';
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

  /// 同步状态
  bool isSyncing = false;

  /// 最近同步时间
  DateTime? lastSyncTime;

  /// 最近同步时间字符串
  String? get lastSyncTimeStr {
    if (lastSyncTime == null) return null;
    return '${lastSyncTime!.month}月${lastSyncTime!.day}日${lastSyncTime!.hour}时${lastSyncTime!.minute}分${lastSyncTime!.second}秒';
  }

  SyncController();

  @override
  void onInit() {
    super.onInit();
    ALiPanRepository.getToken().then((value) {
      token = value;
      ALiPanRepository.getDriveInfo().then((value) {
        driveInfo = value;
        update();
        sync();
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
    await ALiPanRepository.deleteTokenExpireTime();
    await ALiPanRepository.deleteDriveInfo();
    await ALiPanRepository.deleteLastSyncHash();
    token = null;
    driveInfo = null;
    lastSyncTime = null;
    update();
  }

  /// 获取阿里云盘信息
  void getAliPanInfo(String code) async {
    try {
      token = await ALiPanApi.getAccessToken(code, randomCode);
      driveInfo = await ALiPanApi.getDriveInfo(token!);
      if (driveInfo!.backupDriveId == null) {
        driveInfo = null;
        snackbar('授权失败', '请在授权时，选择“备份盘”');
        return;
      }
      await ALiPanRepository.saveToken(token!);
      await ALiPanRepository.saveDriveInfo(driveInfo!);
      final expireTime =
          DateTime.now().add(Duration(seconds: token!.expiresIn));
      await ALiPanRepository.saveTokenExpireTime(expireTime);
      snackbar('授权成功', '已成功授权阿里云盘');
      sync();
    } catch (e) {
      snackbar('授权失败', '请重新登录');
    }
  }

  /// 同步计数
  int syncCount = 0;

  /// 延时同步，过滤频繁操作
  void delaySync() {
    syncCount++;
    Future.delayed(const Duration(seconds: 3), () {
      syncCount--;
      if (syncCount == 0) {
        sync();
      }
    });
  }

  /// 同步数据
  void sync() async {
    if (token == null) return;
    if (driveInfo == null) return;
    if (isSyncing) return;

    // 检查token是否过期
    final tokenExpireTime = await ALiPanRepository.getTokenExpireTime();
    if (tokenExpireTime == null || tokenExpireTime.isBefore(DateTime.now())) {
      snackbar('授权过期', '请重新登录阿里云盘');
      logoutAliPan();
      return;
    }

    isSyncing = true;
    update();

    try {
      // 获取文件夹
      final talkAIFolder = await getFolder();
      // 获取最新的备份文件
      final backupFile = await getLastFile(talkAIFolder.fileId);

      // 获取本地数据
      final localData = getLocalData();
      // 计算本地数据哈希
      final localHash = sha1.convert(localData).toString().toUpperCase();

      if (backupFile == null) {
        // 如果没有备份文件，则上传数据
        await uploadData(talkAIFolder.fileId, localData);
        await ALiPanRepository.saveLastSyncHash(localHash);
        return;
      }

      // 如果云端数据和本地数据一致，则不进行同步
      if (backupFile.contentHash == localHash) {
        return;
      }

      final lastSyncHash = await ALiPanRepository.getLastSyncHash();
      // 如果云端数据和上次同步数据一致，但与本地数据不一致，说明有新增数据，需要上传数据
      if (backupFile.contentHash == lastSyncHash) {
        await uploadData(talkAIFolder.fileId, localData);
        await ALiPanRepository.saveLastSyncHash(localHash);
        return;
      }

      // 云端数据和本地数据不一致，且云端数据和上次同步数据不一致，说明需要下载数据
      await downloadData(backupFile);
      // 保存本次同步数据哈希
      await ALiPanRepository.saveLastSyncHash(backupFile.contentHash!);

      // 再次计算本地数据哈希
      final localData2 = getLocalData();
      final localHash2 = sha1.convert(localData2).toString().toUpperCase();
      // 如果本地数据和云端数据不一致，需要再次上传数据
      if (localHash2 != backupFile.contentHash) {
        await uploadData(talkAIFolder.fileId, localData2);
        await ALiPanRepository.saveLastSyncHash(localHash2);
      }

      // 更新助理
      try {
        Get.find<ChatAppListController>().refreshChatApps();
      } catch (e) {}
    } catch (e) {
      snackbar('同步失败', '请检查网络连接');
    } finally {
      isSyncing = false;
      lastSyncTime = DateTime.now();
      update();
    }
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

  /// 上传数据
  Future<void> uploadData(String fileId, Uint8List data) async {
    final now = DateTime.now();
    final nowStr =
        '${now.year}_${now.month}_${now.day}_${now.hour}_${now.minute}_${now.second}';
    await ALiPanApi.uploadFile(
      token: token!,
      driveId: driveId!,
      parentFileId: fileId,
      name: '$nowStr.talkai',
      data: data,
    );
    // 清理历史文件
    clearHistory(fileId);
  }

  /// 获取本地数据
  Uint8List getLocalData() {
    final chatAppList = ChatAppRepository.queryAll(withoutDeleted: false);
    chatAppList.sort((a, b) => a.name.compareTo(b.name));
    final llmList = LLMRepository.queryAll(withoutDeleted: false);
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
                'deleted_time': e.deletedTime?.millisecondsSinceEpoch ?? 0,
              })
          .toList(),
      'llm_list': llmList.map((e) {
        final map = e.toJson();
        map['name'] = e.name;
        map['type'] = e.type.value;
        map['updated_time'] = e.updatedTime.millisecondsSinceEpoch;
        map['deleted_time'] = e.deletedTime?.millisecondsSinceEpoch ?? 0;
        return map;
      }).toList(),
    };
    final dataStr = encrypt(jsonEncode(data));
    return utf8.encode(dataStr);
  }

  /// 下载数据并更新
  downloadData(FileModel backupFile) async {
    final decrypted = await ALiPanApi.downloadFile(
      token: token!,
      driveId: driveId!,
      fileId: backupFile.fileId,
    );

    try {
      // 即使解析数据出错，后面也会重新上传数据，覆盖掉错误数据
      // 所以这里出错不能影响之后的操作
      final remoteDataStr = decrypt(decrypted);
      final remoteData = jsonDecode(remoteDataStr);
      // 更新助理
      final remoteChatAppList = remoteData['chat_app_list'];
      final localChatAppList =
          ChatAppRepository.queryAll(withoutDeleted: false);
      updateLocalChatApp(remoteChatAppList, localChatAppList);
      // 更新模型
      final remoteLLMList = remoteData['llm_list'];
      final localLLMList = LLMRepository.queryAll();
      updateLocalLLM(remoteLLMList, localLLMList);
    } catch (e) {}
  }

  /// 更新本地助理
  updateLocalChatApp(
      List remoteChatAppList, List<ChatAppModel> localChatAppList) {
    final remoteChatAppNameSet =
        remoteChatAppList.map((e) => e['name']).toSet();
    final localChatAppNameSet = localChatAppList.map((e) => e.name).toSet();
    // 云端有、本地无：新增
    for (final remoteChatApp in remoteChatAppList) {
      final remoteChatAppName = remoteChatApp['name'];
      if (!localChatAppNameSet.contains(remoteChatAppName)) {
        final profilePicture = remoteChatApp['profile_picture'] != null
            ? base64Decode(remoteChatApp['profile_picture'])
            : null;
        ChatAppRepository.insert(
          name: remoteChatApp['name'],
          prompt: remoteChatApp['prompt'],
          temperature: remoteChatApp['temperature'],
          multipleRound: remoteChatApp['multiple_round'],
          profilePicture: profilePicture,
          updatedTime: remoteChatApp['updated_time'],
          deletedTime: remoteChatApp['deleted_time'],
        );
      }
    }
    // 云端有、本地有：云端更新时间晚于本地更新时间，更新本地
    for (final remoteChatApp in remoteChatAppList) {
      final remoteChatAppName = remoteChatApp['name'];
      if (localChatAppNameSet.contains(remoteChatAppName)) {
        final localChatApp =
            localChatAppList.firstWhere((e) => e.name == remoteChatAppName);
        final remoteUpdatedTime = remoteChatApp['updated_time'];
        if (remoteUpdatedTime >
                localChatApp.updatedTime.millisecondsSinceEpoch ||
            localChatApp.updatedTime.millisecondsSinceEpoch == 0) {
          final profilePicture = remoteChatApp['profile_picture'] != null
              ? base64Decode(remoteChatApp['profile_picture'])
              : null;
          ChatAppRepository.update(
            chatAppId: localChatApp.chatAppId,
            llmId: localChatApp.llmId,
            name: remoteChatApp['name'],
            prompt: remoteChatApp['prompt'],
            temperature: remoteChatApp['temperature'],
            multipleRound: remoteChatApp['multiple_round'],
            profilePicture: profilePicture,
            updatedTime: remoteUpdatedTime != 0
                ? remoteUpdatedTime
                : DateTime.now().millisecondsSinceEpoch,
            deletedTime: remoteChatApp['deleted_time'],
          );
        }
      }
    }
  }

  /// 更新本地LLM
  updateLocalLLM(List remoteLLMList, List<LLM> localLLMList) {
    final remoteLLMNameSet = remoteLLMList.map((e) => e['name']).toSet();
    final localLLMNameSet = localLLMList.map((e) => e.name).toSet();
    // 云端有、本地无：新增
    for (final remoteLLM in remoteLLMList) {
      final remoteLLMName = remoteLLM['name'];
      if (!localLLMNameSet.contains(remoteLLMName)) {
        Get.find<LLMService>().addLLM(remoteLLM);
      }
    }

    // 云端有、本地有：云端更新时间晚于本地更新时间，更新本地
    for (final remoteLLM in remoteLLMList) {
      final remoteLLMName = remoteLLM['name'];
      if (localLLMNameSet.contains(remoteLLMName)) {
        final localLLM =
            localLLMList.firstWhere((e) => e.name == remoteLLMName);
        final remoteUpdatedTime = remoteLLM['updated_time'];
        if (remoteUpdatedTime > localLLM.updatedTime.millisecondsSinceEpoch ||
            localLLM.updatedTime.millisecondsSinceEpoch == 0) {
          Get.find<LLMService>().updateLLMByData(
            localLLM.llmId,
            remoteLLM,
            updatedTime: remoteUpdatedTime != 0
                ? remoteUpdatedTime
                : DateTime.now().millisecondsSinceEpoch,
          );
        }
      }
    }
  }

  /// 保留历史文件数量
  static const historyFileCount = 10;

  /// 清理云端历史文件，保留最近的10个
  Future<void> clearHistory(
    String fileId,
  ) async {
    final list = await ALiPanApi.getFileList(
      token: token!,
      driveId: driveId!,
      parentFileId: fileId,
      orderBy: 'created_at',
      orderDirection: 'DESC',
      type: 'file',
    );
    if (list.length <= historyFileCount) return;
    for (var i = historyFileCount; i < list.length; i++) {
      await ALiPanApi.deleteFile(
        token: token!,
        driveId: driveId!,
        fileId: list[i].fileId,
      );
    }
  }

  /// 密钥
  static const aesSecretKey = r'a4*s^*cM6g3~?XTjM"~6GQa\3N:RCMb7';

  /// IV
  static const aesIV = r'^XBmbN,J^S.jn[2`';

  /// 加密
  String encrypt(String text) {
    final key = Key.fromUtf8(aesSecretKey);
    final iv = IV.fromUtf8(aesIV);
    final encrypter = Encrypter(AES(key));
    return encrypter.encrypt(text, iv: iv).base64;
  }

  /// 解密
  String decrypt(String decrypted) {
    final key = Key.fromUtf8(aesSecretKey);
    final iv = IV.fromUtf8(aesIV);
    final encrypter = Encrypter(AES(key));
    return encrypter.decrypt64(decrypted, iv: iv);
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
