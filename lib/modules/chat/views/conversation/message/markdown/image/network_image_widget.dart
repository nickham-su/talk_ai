import 'dart:convert';
import 'dart:io';

import 'package:TalkAI/shared/components/snackbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

import '../../../../../../../shared/apis/new_dio.dart';
import '../../../../../../../shared/repositories/cache_image_repository.dart';

/// 网络图片组件
class NetworkImageWidget extends StatefulWidget {
  final String url; // 图片地址
  final BoxFit? fit; // 图片填充方式
  final ImageErrorWidgetBuilder? errorBuilder; // 错误构建器

  const NetworkImageWidget(
    this.url, {
    Key? key,
    this.fit,
    this.errorBuilder,
  }) : super(key: key);

  @override
  _NetworkImageWidgetState createState() => _NetworkImageWidgetState();
}

class _NetworkImageWidgetState extends State<NetworkImageWidget> {
  bool _isLoad = false; // 是否加载完成

  late Widget _imageWidget; // 图片组件

  @override
  void initState() {
    Widget? cacheWidget = loadCacheImg();
    if (cacheWidget != null) {
      _imageWidget = cacheWidget;
      _isLoad = true;
    } else {
      _imageWidget = getLoadingWidget();
      loadNetworkImg();
    }
    super.initState();
  }

  /// 加载缓存图片
  Widget? loadCacheImg() {
    try {
      final imgFile = CacheImageRepository.getImage(widget.url);
      if (imgFile != null) {
        return Image.file(
          imgFile,
          fit: widget.fit,
          errorBuilder: widget.errorBuilder,
        );
      }
    } catch (e) {}
    return null;
  }

  /// 加载
  void loadNetworkImg() async {
    try {
      // 下载图片
      final response = await newDio(timeout: 30)
          .get(widget.url, options: Options(responseType: ResponseType.bytes));
      // 保存缓存
      CacheImageRepository.saveImage(widget.url, response.data);

      if (!mounted) return;
      // 显示图片
      _imageWidget = Image.memory(
        response.data,
        fit: widget.fit,
        errorBuilder: widget.errorBuilder,
      );
      _isLoad = true;
    } catch (e) {}
    setState(() {});
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
            onPressed: saveImage,
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

  void saveImage() async {
    if (!_isLoad) return;

    try {
      // 获取下载文档目录
      final downloadDir = await getDownloadsDirectory();
      await CacheImageRepository.exportImage(widget.url, downloadDir!.path);
      snackbar('保存成功', '已保存到"下载"文件夹');
    } catch (e) {
      snackbar('提示', e.toString());
    }
  }

  /// 获取加载中组件
  Widget getLoadingWidget() {
    return Container(
      width: 300,
      height: 300,
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }
}
