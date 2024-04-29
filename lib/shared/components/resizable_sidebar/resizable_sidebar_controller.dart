import 'package:get/get.dart';

/// 可调节宽度的侧边栏控制器
class ResizableSidebarController extends GetxController {
  double width; // 宽度

  ResizableSidebarController(this.width);

  /// 设置宽度
  void setWidth(double newWidth) {
    width = newWidth;
    update();
  }
}
