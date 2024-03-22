import 'package:mpay_plugin/response/wechat_response.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'arguments.dart';
import 'mpay_plugin_method_channel.dart';

/// 支付宝沙箱和在线环境
enum AliPayEnv { ONLINE, SANDBOX }

extension AliPayEnvExtension on AliPayEnv {
  int get value => [0, 1][index];
}

/// 生产环境和UAT环境
enum MPayEnv { PRODUCTION, SIT, UAT }

extension MPayEnvExtension on MPayEnv {
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

  Future<Map> mPay(
    String? data, {
    PayChannel channel = PayChannel.mPay,
    String? withScheme,
  }) {
    throw UnimplementedError('mPay() has not been implemented.');
  }

  /// 初始化设置(
  Future<void> init({
    AliPayEnv aliPayEnv = AliPayEnv.ONLINE,
    MPayEnv mPayEnv = MPayEnv.PRODUCTION,
  }) {
    throw UnimplementedError('init() has not been implemented.');
  }

  /// 支付寶支付
  Future<Map> aliPay(String data,String setIosUrlSchema) {
    throw UnimplementedError('aliPay() has not been implemented.');
  }

  // 注册微信支付
  Future<bool> registerApi({
    required String appId,
    bool doOnIOS = true,
    bool doOnAndroid = true,
    String? universalLink,
  }) {
    throw UnimplementedError('registerWxApi() has not been implemented.');
  }

  /// 微信支付
  Future<bool> wechatPay(PayType which) {
    throw UnimplementedError('wechatPay() has not been implemented.');
  }

  Stream<WeChatResponse> get responseEventHandler {
    throw UnimplementedError('responseEventHandler has not been implemented.');
  }

}
