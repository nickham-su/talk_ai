import 'package:TalkAI/shared/components/snackbar.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  @override
  void initState() {
    _imageWidget = ExtendedImage.network(
      widget.url,
      constraints: widget.maxWidth != null
          ? BoxConstraints(maxWidth: widget.maxWidth!)
          : null,
      fit: BoxFit.cover,
      cache: true,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return Container(
              width: 400,
              height: 400,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          case LoadState.completed:
            Future.delayed(Duration.zero, () {
              setState(() {
                _isLoad = true;
              });
            });
            return state.completedWidget;
          case LoadState.failed:
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
      },
    );
    super.initState();
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
              var data = await getNetworkImageData(widget.url, useCache: true);
              if (data != null) {
                final uri = Uri.parse(widget.url);
                await FileSaver.instance.saveFile(
                  name: uri.pathSegments.last,
                  bytes: data,
                );
                snackbar('保存成功', '已保存到"下载"文件夹');
              }
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
}
