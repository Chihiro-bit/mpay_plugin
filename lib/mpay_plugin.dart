
import 'mpay_plugin_platform_interface.dart';

class MpayPlugin {
  Future<String?> getPlatformVersion() {
    return MpayPluginPlatform.instance.getPlatformVersion();
  }

  Future<dynamic> mPay(String? data) {
    return MpayPluginPlatform.instance.mPay(data);
  }
}
