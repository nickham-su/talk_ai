import 'package:get/get.dart';

/// 可调节宽度的侧边栏控制器
class ResizableSidebarController extends GetxController {
  final String tag; // 侧边栏标识
  double width; // 宽度

  ResizableSidebarController(this.tag, this.width);

  /// 设置宽度
  void setWidth(double newWidth) {
    width = newWidth;
    update([tag]);
  }
}
