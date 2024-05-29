import 'dart:convert';
import 'dart:io';

import 'package:TalkAI/shared/components/snackbar.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../../../../shared/apis/new_dio.dart';
import '../../../../../../shared/utils/app_cache_dir.dart';

/// 网络图片组件
class NetworkImageWidget extends StatefulWidget {
  final String url; // 图片地址
  final double? maxWidth; // 最大宽度

  const NetworkImageWidget({
    Key? key,
    required this.url,
    required this.maxWidth,
  }) : super(key: key);

  @override
  _NetworkImageWidgetState createState() => _NetworkImageWidgetState();
}

class _NetworkImageWidgetState extends State<NetworkImageWidget> {
  bool _isLoad = false; // 是否加载完成

  late Widget _imageWidget; // 图片组件

  String? _imgPath; // 图片路径

  @override
  void initState() {
    _imageWidget = getLoadingWidget();
    _loadImg();
    super.initState();
  }

  void _loadImg() async {
    // app缓存文件夹
    final appCacheDir = await getAppCacheDir();
    // 图片缓存文件夹
    final imgDirPath = path.join(appCacheDir, 'cache_images');
    final imgDir = Directory(imgDirPath);
    if (await imgDir.exists() == false) {
      imgDir.createSync(); // 创建文件夹
    }
    // 使用url hash值作为文件名
    final urlHash = generateSha256Hash(widget.url);
    final imgUri = Uri.parse(widget.url);
    final extension = path.extension(imgUri.path);
    final fileName = '$urlHash$extension';
    _imgPath = path.join(imgDirPath, fileName);

    final imgFile = File(_imgPath!);
    if (await imgFile.exists() == false) {
      // 没有缓存文件，下载图片
      try {
        final response = await newDio(timeout: 30).get(widget.url,
            options: Options(responseType: ResponseType.bytes));
        await imgFile.writeAsBytes(response.data as List<int>);
      } catch (e) {
        // 下载失败
        _imageWidget = getErrorWidget();
        if (mounted) {
          setState(() {});
        }
        return;
      }
    }

    // 用缓存文件加载图片
    _imageWidget = Image.file(
      imgFile,
      width: widget.maxWidth,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return getErrorWidget();
      },
    );

    _isLoad = true;
    setState(() {});
  }

  String generateSha256Hash(String input) {
    var bytes = utf8.encode(input); // 将输入字符串转换为字节数组
    var digest = sha256.convert(bytes); // 计算SHA-256哈希值
    return digest.toString(); // 将哈希值转换为十六进制字符串
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      _imageWidget,
      Positioned(
        left: 8,
        bottom: 8,
        child: Visibility(
          visible: _isLoad,
          child: TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              backgroundColor: Get.theme.colorScheme.surface.withOpacity(0.4),
              foregroundColor: null,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () async {
              if (_imgPath == null) return;
              // 缓存的图片文件
              final imgFile = File(_imgPath!);
              // 获取下载文档目录
              final downloadDir = await getDownloadsDirectory();
              // 从url中获取原始文件名
              final uri = Uri.parse(widget.url);
              final savePath =
                  path.join(downloadDir!.path, uri.pathSegments.last);
              // 复制文件
              imgFile.copySync(savePath);
              snackbar('保存成功', '已保存到"下载"文件夹');
            },
            child: Text('下载图片',
                style: TextStyle(
                  color:
                      Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                )),
          ),
        ),
      ),
    ]);
  }

  /// 获取加载中组件
  getLoadingWidget() {
    return Container(
      width: 300,
      height: 300,
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }

  /// 获取加载失败组件
  getErrorWidget() {
    return Row(
      children: [
        Icon(
          Icons.broken_image,
          color: Get.theme.colorScheme.error,
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          '图片加载失败',
          style: TextStyle(
            fontSize: 14,
            color: Get.theme.colorScheme.error,
          ),
        ),
      ],
    );
  }
}

/// 自定义markdown图片解析语法
class CustomImageSyntax extends m.InlineSyntax {
  CustomImageSyntax() : super(r'!\[([^\]]+)\]\(([^)\s]+)(?:\s+"([^"]+)")?\)');

  @override
  bool onMatch(m.InlineParser parser, Match match) {
    final alt = match.group(1);
    final src = match.group(2);
    final title = match.group(3);
    m.Element el = m.Element.withTag('img');
    el.attributes['alt'] = alt ?? '';
    el.attributes['src'] = src ?? '';
    el.attributes['title'] = title ?? '';
    parser.addNode(el);
    return true;
  }
}
