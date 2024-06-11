/// Token响应数据
class TokenModel {
  final String tokenType; // token类型
  final String accessToken; // 访问token
  final String? refreshToken; // 刷新token
  final int expiresIn; // 过期时间

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

/// 文件模型
class FileModel {
  String driveId;
  String fileId; // 文件ID
  String parentFileId; // 父文件夹ID,根目录是 root
  String name; // 文件名
  String type; // 文件类型: file | folder
  String? fileExtension; // 文件扩展名
  String? contentHash; // 内容hash
  String? contentHashName; // 内容hash名
  String? createdAt; // 创建时间
  String? updatedAt; // 更新时间
  String? uploadId; // 上传ID
  List<PartInfo>? partInfoList; // 分片信息

  FileModel({
    required this.driveId,
    required this.fileId,
    required this.parentFileId,
    required this.name,
    required this.fileExtension,
    required this.contentHash,
    required this.contentHashName,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.uploadId,
    required this.partInfoList,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      driveId: json['drive_id'],
      fileId: json['file_id'],
      parentFileId: json['parent_file_id'],
      name: json['name'] ?? json['file_name'],
      fileExtension: json['file_extension'],
      contentHash: json['content_hash'],
      contentHashName: json['content_hash_name'],
      type: json['type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      uploadId: json['upload_id'],
      partInfoList: json['part_info_list'] == null
          ? null
          : (json['part_info_list'] as List)
              .map((e) => PartInfo.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'drive_id': driveId,
      'file_id': fileId,
      'parent_file_id': parentFileId,
      'name': name,
      'file_extension': fileExtension,
      'content_hash': contentHash,
      'content_hash_name': contentHashName,
      'type': type,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'upload_id': uploadId,
      'part_info_list': partInfoList?.map((e) => e.toJson()).toList(),
    };
  }
}

/// 分片信息
class PartInfo {
  int partNumber; // 分片序号
  String uploadUrl; // 上传地址

  PartInfo({
    required this.partNumber,
    required this.uploadUrl,
  });

  factory PartInfo.fromJson(Map<String, dynamic> json) {
    return PartInfo(
      partNumber: json['part_number'],
      uploadUrl: json['upload_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'part_number': partNumber,
      'upload_url': uploadUrl,
    };
  }
}

/// 文件列表
class FileListModel {
  List<FileModel> items;

  FileListModel({
    required this.items,
  });

  factory FileListModel.fromJson(Map<String, dynamic> json) {
    return FileListModel(
      items: (json['items'] as List).map((e) => FileModel.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}
