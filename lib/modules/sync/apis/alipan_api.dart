import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../../../shared/apis/new_dio.dart';
import 'api_models.dart';

class ALiPanApi {
  static const host = 'https://openapi.alipan.com';

  /// 获取access token
  static Future<TokenModel> getAccessToken(
      String code, String codeVerifier) async {
    final rsp = await newDio().post('$host/oauth/access_token', data: {
      'client_id': '79a72348cfd74f7e81136fd5b8124ee6',
      'grant_type': 'authorization_code',
      'code': code,
      'code_verifier': codeVerifier,
    });
    return TokenModel.fromJson(rsp.data);
  }

  /// 获取用户信息
  static Future<DriveInfo> getDriveInfo(TokenModel token) async {
    const url = '$host/adrive/v1.0/user/getDriveInfo';
    final header = {
      'Authorization': '${token.tokenType} ${token.accessToken}',
    };
    final rsp = await newDio().post(url, options: Options(headers: header));
    return DriveInfo.fromJson(rsp.data);
  }

  /// 查询文件
  static Future<FileModel> getByPath(
      TokenModel token, String driveId, String path) async {
    const url = '$host/adrive/v1.0/openFile/get_by_path';
    final header = {
      'Authorization': '${token.tokenType} ${token.accessToken}',
    };
    final rsp =
        await newDio().post(url, options: Options(headers: header), data: {
      'drive_id': driveId,
      'file_path': path,
    });
    return FileModel.fromJson(rsp.data);
  }

  /// 创建文件或文件夹
  static Future<FileModel> create({
    required TokenModel token, // token
    required String driveId, // driveId
    required String parentFileId, // 父文件夹ID,根目录是 root
    required String name, // 文件名
    required String type, // file | folder
  }) async {
    const url = '$host/adrive/v1.0/openFile/create';
    final header = {
      'Authorization': '${token.tokenType} ${token.accessToken}',
    };
    final data = {
      'drive_id': driveId,
      'parent_file_id': parentFileId,
      'name': name,
      'type': type,
      'check_name_mode': 'refuse',
    };
    final rsp =
        await newDio().post(url, options: Options(headers: header), data: data);
    return FileModel.fromJson(rsp.data);
  }

  static Future<List<FileModel>> getFileList({
    required TokenModel token,
    required String driveId,
    required String parentFileId,
    String? orderBy, // created_at | updated_at | name | size | name_enhanced
    String? orderDirection, // DESC | ASC
    int? limit,
    String? type, // all | file | folder
  }) async {
    const url = '$host/adrive/v1.0/openFile/list';
    final header = {
      'Authorization': '${token.tokenType} ${token.accessToken}',
    };
    final data = {
      'drive_id': driveId,
      'parent_file_id': parentFileId,
      'order_by': orderBy,
      'order_direction': orderDirection,
      'limit': limit,
      'type': type,
    };
    final rsp =
        await newDio().post(url, options: Options(headers: header), data: data);
    final list = FileListModel.fromJson(rsp.data);
    return list.items;
  }

  /// 上传文件
  static uploadFile({
    required TokenModel token,
    required String driveId,
    required String parentFileId,
    required String name,
    required Uint8List data,
  }) async {
    final file = await create(
      token: token,
      driveId: driveId,
      parentFileId: parentFileId,
      name: name,
      type: 'file',
    );

    Uri uri = Uri.parse(file.partInfoList![0].uploadUrl);
    final rsp = await http.put(uri, body: data);
    if (rsp.statusCode != 200) {
      throw Exception('上传失败');
    }

    await newDio().post(
      '$host/adrive/v1.0/openFile/complete',
      options: Options(headers: {
        'Authorization': '${token.tokenType} ${token.accessToken}',
      }),
      data: {
        'drive_id': driveId,
        'file_id': file.fileId,
        'upload_id': file.uploadId,
      },
    );
  }

  /// 下载文件
  static Future<String> downloadFile({
    required TokenModel token,
    required String driveId,
    required String fileId,
  }) async {
    final rsp = await newDio().post(
      '$host/adrive/v1.0/openFile/getDownloadUrl',
      options: Options(
        headers: {
          'Authorization': '${token.tokenType} ${token.accessToken}',
        },
      ),
      data: {
        'drive_id': driveId,
        'file_id': fileId,
      },
    );

    final url = rsp.data['url'];

    final rsp2 = await newDio().get(url);
    return rsp2.data;
  }
}
