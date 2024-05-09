import 'package:get/get.dart';

/// 可调节宽度的侧边栏控制器
class ResizableSidebarController extends GetxController {
  final String tag; // 标签
  double width; // 宽度
  double height; // 高度

  ResizableSidebarController(this.tag, this.width, this.height);

  /// 设置宽度
  void setWidth(double newWidth) {
    width = newWidth;
    update([tag]);
  }

  /// 设置高度
  void setHeight(double newHeight) {
    height = newHeight;
    update([tag]);
  }
}
