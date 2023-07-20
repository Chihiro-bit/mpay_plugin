import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mpay_plugin_method_channel.dart';

/// 支付宝沙箱和在线环境
enum AliPayEnv { ONLINE, SANDBOX }

extension AliPayEnvExtension on AliPayEnv {
  int get value => [0, 1][index];
}

/// 生产环境和UAT环境
enum EnvType { PRODUCTION, SIT, UAT }

extension EnvTypeExtension on EnvType {
  int get value => [0, 1, 2][index];
}

/// 支付渠道，MPay，AliPay，WeChatPay
enum PayChannel { mPay, aliPay, wechatPay }

extension PayChannelExtension on PayChannel {
  int get value => [0, 1, 2][index];
}

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

  Future<Map> mPay(String? data, [PayChannel channel = PayChannel.mPay]) {
    throw UnimplementedError('mPay() has not been implemented.');
  }

  /// 初始化设置(
  Future<void> init(
      {AliPayEnv envEnum = AliPayEnv.ONLINE,
      EnvType envType = EnvType.PRODUCTION}) {
    throw UnimplementedError('init() has not been implemented.');
  }
}
