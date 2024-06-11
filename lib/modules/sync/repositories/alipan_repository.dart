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
}
