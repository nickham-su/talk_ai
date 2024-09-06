import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';

import '../utils/app_cache_dir.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

import '../utils/hash.dart';

class CacheImageRepository {
  /// 缓存网络图片文件夹
  static const String _cacheNetworkImageDir = 'cache_images';

  /// 缓存本地图片文件夹
  static const String _cacheLocalImageDir = 'cache_local_images';

  /// 获取缓存的网络图片
  static File? getNetworkImage(String uri) {
    try {
      final imgFile = File(_getNetworkImgCachePath(uri));
      return imgFile.existsSync() ? imgFile : null;
    } catch (e) {
      return null;
    }
  }

  /// 保存网络图片
  static File saveNetworkImage(String uri, Uint8List bytes) {
    final imgFile = File(_getNetworkImgCachePath(uri));
    imgFile.writeAsBytesSync(bytes);
    return imgFile;
  }

  /// 导出网络图片
  /// [uri] 图片地址
  /// [targetDir] 目标文件夹
  static Future<void> exportNetworkImage(String uri, String targetDir) async {
    final imgFile = getNetworkImage(uri);
    if (imgFile == null) {
      throw '图片不存在';
    }

    final imgUri = Uri.parse(uri);
    String fileName = path.basename(imgUri.path);
    String extension = path.extension(imgUri.path);
    final savePath = path.join(targetDir, fileName);
    if (extension.isNotEmpty) {
      // 存在正确的扩展名，复制文件
      await imgFile.copy(savePath);
      return;
    }

    // 不存在扩展名，尝试解析图片，保存为jpg格式
    final bytes = await imgFile.readAsBytes();
    img.Image? decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      throw '图片保存失败';
    }
    if (!await img.encodeJpgFile('$savePath.jpg', decodedImage)) {
      throw '图片保存失败';
    }
  }

  /// 获取网络图片缓存路径
  static String _getNetworkImgCachePath(String uri) {
    // app缓存文件夹
    final appCacheDir = getAppCacheDirSync();
    // 图片缓存文件夹
    final imgDirPath = path.join(appCacheDir, _cacheNetworkImageDir);
    final imgDir = Directory(imgDirPath);
    if (imgDir.existsSync() == false) {
      imgDir.createSync(); // 创建文件夹
    }
    // 使用url hash值作为文件名
    final urlHash = sha256Hash(uri);
    final imgUri = Uri.parse(uri);
    final extension = path.extension(imgUri.path);
    final fileName = '$urlHash$extension';
    return path.join(imgDirPath, fileName);
  }

  /// 获取缓存的本地图片
  static File? getLocalImage(String path) {
    try {
      final imgFile = File(path);
      return imgFile.existsSync() ? imgFile : null;
    } catch (e) {
      return null;
    }
  }

  /// 保存本地图片
  static File saveLocalImage(PlatformFile file) {
    // 创建缓存文件夹
    var imgDir =
        Directory(path.join(getAppCacheDirSync(), _cacheLocalImageDir));
    if (imgDir.existsSync() == false) {
      imgDir.createSync();
    }
    // 以文件hash值作为文件夹名，避免文件名冲突
    var digest = sha256.convert(file.bytes!); // 计算SHA-256哈希值
    imgDir = Directory(path.join(imgDir.path, digest.toString()));
    if (imgDir.existsSync() == false) {
      imgDir.createSync();
    }
    // 保存文件
    final imgFile = File(path.join(imgDir.path, file.name));
    // 判断文件是否存在
    if (imgFile.existsSync()) {
      return imgFile;
    }
    imgFile.writeAsBytesSync(file.bytes!);
    return imgFile;
  }
}
