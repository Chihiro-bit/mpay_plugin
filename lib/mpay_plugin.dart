import 'package:mpay_plugin/arguments.dart';

import 'mpay_plugin_platform_interface.dart';
import 'result_model.dart';

class MpayPlugin {
  Future<String?> getPlatformVersion() {
    return MpayPluginPlatform.instance.getPlatformVersion();
  }

  Future<ResultModel> mPay(
    String? data,
    PayChannel channel, {
    String? withScheme,
  }) async {
    ResultModel resultModel = const ResultModel();
    var result = await MpayPluginPlatform.instance
        .mPay(data, channel: channel, withScheme: withScheme);
    resultModel = ResultModel.fromJson(result);
    return resultModel;
  }

  /// 初始化設置，支付寶沙箱模式僅限android使用，
  /// envType 對應mPay的支付模式
  Future<void> init({
    AliPayEnv envEnum = AliPayEnv.ONLINE,
    EnvType envType = EnvType.PRODUCTION,
  }) {
    return MpayPluginPlatform.instance.init(envEnum: envEnum, envType: envType);
  }

  /// 支付寶支付
  Future<ResultModel> aliPay(String payInfo, String setIosUrlSchema) async {
    ResultModel resultModel = const ResultModel();
    var result =
        await MpayPluginPlatform.instance.aliPay(payInfo, setIosUrlSchema);
    print("mpay_plugin----->$result");
    resultModel = ResultModel.fromJson(result);
    return resultModel;
  }

  // 注册微信
  Future<bool> registerApi({
    required String appId,
    bool doOnIOS = true,
    bool doOnAndroid = true,
    String? universalLink,
  }) async {
    return MpayPluginPlatform.instance.registerApi(
        appId: appId,
        doOnAndroid: doOnAndroid,
        doOnIOS: doOnIOS,
        universalLink: universalLink);
  }

  /// 微信支付
  Future<ResultModel> wechatPay(PayType payType) async {
    ResultModel resultModel = const ResultModel();
    var result = await MpayPluginPlatform.instance.wechatPay(payType);
    resultModel = ResultModel.fromJson(result);
    return resultModel;
  }
}
