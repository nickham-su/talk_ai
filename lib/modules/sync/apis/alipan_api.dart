import 'package:dio/dio.dart';

import '../../../shared/apis/new_dio.dart';

class ALiPanApi {
  static const host = 'https://openapi.alipan.com';
  static const accessTokenPath = '/oauth/access_token';
  static const driveInfoPath = '/adrive/v1.0/user/getDriveInfo';

  /// 获取access token
  static Future<TokenModel> getAccessToken(
      String code, String codeVerifier) async {
    final rsp = await newDio().post('$host$accessTokenPath', data: {
      'client_id': '79a72348cfd74f7e81136fd5b8124ee6',
      'grant_type': 'authorization_code',
      'code': code,
      'code_verifier': codeVerifier,
    });
    return TokenModel.fromJson(rsp.data);
  }

  /// 获取用户信息
  static Future<DriveInfo> getDriveInfo(TokenModel token) async {
    const url = '$host$driveInfoPath';
    final header = {
      'Authorization': '${token.tokenType} ${token.accessToken}',
    };
    final rsp = await newDio().post(url, options: Options(headers: header));
    return DriveInfo.fromJson(rsp.data);
  }
}

/// Token响应数据
class TokenModel {
  final String tokenType;
  final String accessToken;
  final String? refreshToken;
  final int expiresIn;

  TokenModel({
    required this.tokenType,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory TokenModel.fromJson(Map<dynamic, dynamic> json) {
    return TokenModel(
      tokenType: json['token_type'] as String,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresIn: json['expires_in'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token_type': tokenType,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
    };
  }
}

/// 用户信息
class DriveInfo {
  String name; // 用户名
  String avatar; // 头像
  String userId; // 用户ID
  String? defaultDriveId; // 默认drive
  String? backupDriveId; // 备份盘。用户选择了授权才会返回
  String? resourceDriveId; // 资源库。用户选择了授权才会返回

  DriveInfo({
    required this.name,
    required this.avatar,
    required this.userId,
    required this.defaultDriveId,
    required this.backupDriveId,
    required this.resourceDriveId,
  });

  factory DriveInfo.fromJson(Map<dynamic, dynamic> json) {
    return DriveInfo(
      name: json['name'],
      avatar: json['avatar'],
      userId: json['user_id'],
      defaultDriveId: json['default_drive_id'],
      backupDriveId: json['backup_drive_id'],
      resourceDriveId: json['resource_drive_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['avatar'] = avatar;
    data['user_id'] = userId;
    data['default_drive_id'] = defaultDriveId;
    data['backup_drive_id'] = backupDriveId;
    data['resource_drive_id'] = resourceDriveId;
    return data;
  }
}
