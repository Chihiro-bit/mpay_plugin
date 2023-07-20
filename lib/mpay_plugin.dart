import 'mpay_plugin_platform_interface.dart';
import 'result_model.dart';

class MpayPlugin {
  Future<String?> getPlatformVersion() {
    return MpayPluginPlatform.instance.getPlatformVersion();
  }

  Future<ResultModel> mPay(String? data,PayChannel channel) async {
    ResultModel resultModel = const ResultModel();
    var result = await MpayPluginPlatform.instance.mPay(data,channel);
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
}
