import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

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
  Widget build(BuildContext context) {
    late Widget picture;

    if (_cacheImg != null) {
      picture = Image.memory(_cacheImg!, fit: BoxFit.cover);
    } else if (widget.data != null) {
      picture = Image.memory(widget.data!, fit: BoxFit.cover);
    } else {
      picture = SvgPicture.asset('assets/icons/assistant.svg',
          width: 20,
          height: 20,
          theme: SvgTheme(
            currentColor: Get.theme.colorScheme.inverseSurface,
          ));
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: selectImage,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: _cacheImg != null || widget.data != null
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
    );
  }

  /// 选择图片
  selectImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      _cacheImg = result.files.single.bytes;
      setState(() {});
      widget.onSelected(_cacheImg);
    }
  }
}
