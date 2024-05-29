import 'package:get/get.dart';

import '../../../shared/repositories/create_tables.dart';
import '../../../shared/services/llm_service.dart';
import '../../../shared/utils/sqlite.dart';
import '../../../shared/repositories/setting_repository.dart';

class SettingController extends GetxController {
  /// 清空数据
  void clearData() {
    // 清空数据库
    Sqlite.resetDB();
    // 重新创建数据库表
    initDBTables();
    // 刷新LLM列表
    Get.find<LLMService>().refreshLLMList();
  }

  /// 网络超时时间
  int get networkTimeout => SettingRepository.getNetworkTimeout();

  /// 设置网络超时时间
  void setNetworkTimeout(int timeout) {
    SettingRepository.setNetworkTimeout(timeout);
  }

  /// 启用代理
  bool isProxyEnable = SettingRepository.getProxyEnable();

  /// 代理地址
  String proxyAddress = SettingRepository.getProxyAddress();

  /// 设置代理地址
  void setProxyAddress(String address) {
    proxyAddress = address;
    SettingRepository.setProxyAddress(address);
  }

  /// 切换代理开关
  void toggleProxyStatus() {
    isProxyEnable = !isProxyEnable;
    SettingRepository.setProxyEnable(isProxyEnable);
    update();
  }
}
