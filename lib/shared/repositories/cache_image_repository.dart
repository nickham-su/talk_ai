import 'dart:io';
import 'dart:typed_data';

import '../utils/app_cache_dir.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

import '../utils/hash.dart';

class CacheImageRepository {
  static const String _cacheDir = 'cache_images';

  /// 获取缓存图片文件
  static File? getImage(String uri) {
    try {
      final imgFile = File(_getImgCachePath(uri));
      return imgFile.existsSync() ? imgFile : null;
    } catch (e) {
      return null;
    }
  }

  /// 保存图片
  static File saveImage(String uri, Uint8List bytes) {
    final imgFile = File(_getImgCachePath(uri));
    imgFile.writeAsBytesSync(bytes);
    return imgFile;
  }

  /// 导出图片
  /// [uri] 图片地址
  /// [targetDir] 目标文件夹
  static Future<void> exportImage(String uri, String targetDir) async {
    final imgFile = getImage(uri);
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

  /// 获取图片缓存路径
  static String _getImgCachePath(String uri) {
    // app缓存文件夹
    final appCacheDir = getAppCacheDirSync();
    // 图片缓存文件夹
    final imgDirPath = path.join(appCacheDir, _cacheDir);
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
}
