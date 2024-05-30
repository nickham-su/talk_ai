import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:markdown_widget/widget/inlines/data_url_image.dart';
import 'package:markdown_widget/widget/proxy_rich_text.dart';

import '../../../../../../../shared/repositories/setting_repository.dart';
import 'draggable_zoomable_widget.dart';
import 'network_image_widget.dart';

/// 图片构建器
Widget imgBuilder(String url, Map<String, String> attributes) {
  final imageUrl = attributes['src'] ?? '';
  final alt = attributes['alt'] ?? '图片';
  final isNetImage = imageUrl.startsWith('http');
  final isDataUrl = imageUrl.startsWith("data:");

  final width = Get.width;
  final sidebarWidth = SettingRepository.getSidebarWidth(0);
  final imgWidth = (width - sidebarWidth) / 3;

  final Widget imgWidget;
  if (isNetImage) {
    imgWidget = NetworkImageWidget(imageUrl, fit: BoxFit.cover,
        errorBuilder: (ctx, error, stacktrace) {
      return buildErrorImage(imageUrl, alt, error);
    });
  } else if (isDataUrl) {
    imgWidget = Base64DataUrlImage(imageUrl, fit: BoxFit.cover,
        errorBuilder: (ctx, error, stacktrace) {
      return buildErrorImage(imageUrl, alt, error);
    });
  } else {
    imgWidget = Image.asset(imageUrl, fit: BoxFit.cover,
        errorBuilder: (ctx, error, stacktrace) {
      return buildErrorImage(imageUrl, alt, error);
    });
  }

  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: () {
        Get.dialog(Center(
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(50),
              color: Colors.transparent,
              child: DraggableZoomableWidget(
                child: Hero(tag: 'markdown_image', child: imgWidget),
              ),
            ),
          ),
        ));
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: imgWidth),
        child: Hero(tag: 'markdown_image', child: imgWidget),
      ),
    ),
  );
}

/// 构建错误图片
Widget buildErrorImage(String url, String alt, Object? error) {
  return ProxyRichText(TextSpan(children: [
    WidgetSpan(
        child: Icon(
      Icons.broken_image,
      color: Get.theme.colorScheme.error,
      size: 20,
    )),
    TextSpan(
        text: alt,
        style: TextStyle(
          fontSize: 14,
          color: Get.theme.colorScheme.error,
        )),
  ]));
}
