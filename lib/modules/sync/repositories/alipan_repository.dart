import 'package:hive/hive.dart';

import '../apis/alipan_api.dart';
import '../apis/api_models.dart';

class ALiPanRepository {
  static const _boxName = 'ali_pan';

  /// 保存AccessToken
  static saveToken(TokenModel token) async {
    final box = await Hive.openBox(_boxName);
    box.put('token', token.toJson());
  }

  /// 获取AccessToken
  static Future<TokenModel?> getToken() async {
    final box = await Hive.openBox(_boxName);
    final tokenJson = box.get('token', defaultValue: null);
    if (tokenJson == null) {
      return null;
    }
    return TokenModel.fromJson(tokenJson);
  }

  /// 删除AccessToken
  static deleteToken() async {
    final box = await Hive.openBox(_boxName);
    box.delete('token');
  }

  /// 保存token过期时间
  static saveTokenExpireTime(DateTime expireTime) async {
    final box = await Hive.openBox(_boxName);
    box.put('expire_time', expireTime.millisecondsSinceEpoch);
  }

  /// 获取过期时间
  static Future<DateTime?> getTokenExpireTime() async {
    final box = await Hive.openBox(_boxName);
    final expireTime = box.get('expire_time', defaultValue: null);
    if (expireTime == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(expireTime);
  }

  /// 删除过期时间
  static deleteTokenExpireTime() async {
    final box = await Hive.openBox(_boxName);
    box.delete('expire_time');
  }

  /// 保存DriveInfo
  static saveDriveInfo(DriveInfo driveInfo) async {
    final box = await Hive.openBox(_boxName);
    box.put('drive_info', driveInfo.toJson());
  }

  /// 获取DriveInfo
  static Future<DriveInfo?> getDriveInfo() async {
    final box = await Hive.openBox(_boxName);
    final driveInfoJson = box.get('drive_info', defaultValue: null);
    if (driveInfoJson == null) {
      return null;
    }
    return DriveInfo.fromJson(driveInfoJson);
  }

  /// 删除DriveInfo
  static deleteDriveInfo() async {
    final box = await Hive.openBox(_boxName);
    box.delete('drive_info');
  }

  /// 保存最近一次同步的数据哈希
  static saveLastSyncHash(String hash) async {
    final box = await Hive.openBox(_boxName);
    box.put('last_sync_hash', hash);
  }

  /// 获取最近一次同步的数据哈希
  static Future<String?> getLastSyncHash() async {
    final box = await Hive.openBox(_boxName);
    return box.get('last_sync_hash', defaultValue: null);
  }

  /// 删除最近一次同步的数据哈希
  static deleteLastSyncHash() async {
    final box = await Hive.openBox(_boxName);
    box.delete('last_sync_hash');
  }
}
