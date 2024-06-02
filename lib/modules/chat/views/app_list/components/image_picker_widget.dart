import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;

class ImagePickerWidget extends StatefulWidget {
  final Uint8List? data;
  final Function(Uint8List?) onSelected;

  ImagePickerWidget({this.data, required this.onSelected});

  @override
  State<StatefulWidget> createState() {
    return _ImagePickerWidgetState();
  }
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  Uint8List? _cacheImg;

  @override
  void initState() {
    super.initState();
    _cacheImg = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    late Widget picture;

    if (_cacheImg != null) {
      picture = Image.memory(_cacheImg!, fit: BoxFit.cover);
    } else {
      picture = SvgPicture.asset('assets/icons/assistant.svg',
          width: 22,
          height: 22,
          theme: SvgTheme(
            currentColor: Get.theme.colorScheme.inverseSurface,
          ));
    }

    return Stack(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: selectImage,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: _cacheImg != null
                    ? Border.all(
                        color: Get.theme.colorScheme.primary,
                        width: 1.5,
                      )
                    : null,
                color: Get.theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: picture,
              ),
            ),
          ),
        ),
        if (_cacheImg != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Get.theme.colorScheme.primaryContainer),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(width: 14, height: 14),
                onPressed: deleteImage,
                icon: SvgPicture.asset(
                  'assets/icons/delete.svg',
                  width: 12,
                  height: 12,
                  theme: SvgTheme(
                    currentColor: Get.theme.colorScheme.inverseSurface,
                  ),
                )),
          )
      ],
    );
  }

  /// 选择图片
  selectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null) return;

    img.Image? image = img.decodeImage(result.files.single.bytes!);
    if (image == null) {
      Get.snackbar('提示', '图片格式不支持，请重新选择');
      return;
    }
    final resizeImg = img.copyResize(image, width: 144, height: 144);
    _cacheImg = img.encodeJpg(resizeImg);
    setState(() {});
    widget.onSelected(_cacheImg);
  }

  /// 删除图片
  deleteImage() {
    _cacheImg = null;
    setState(() {});
    widget.onSelected(null);
  }
}
