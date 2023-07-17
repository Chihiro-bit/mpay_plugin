import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mpay_plugin_method_channel.dart';

abstract class MpayPluginPlatform extends PlatformInterface {
  MpayPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static MpayPluginPlatform _instance = MethodChannelMpayPlugin();
  static MpayPluginPlatform get instance => _instance;
  static set instance(MpayPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  Future<dynamic> mPay(String? data) {
    throw UnimplementedError('mPay() has not been implemented.');
  }
}
