import 'mpay_plugin_platform_interface.dart';
import 'result_model.dart';

class MpayPlugin {
  Future<String?> getPlatformVersion() {
    return MpayPluginPlatform.instance.getPlatformVersion();
  }

  Future<ResultModel> mPay(String? data) async {
    ResultModel resultModel = const ResultModel();
    var result = await MpayPluginPlatform.instance.mPay(data);
    resultModel = ResultModel.fromJson(result);
    return resultModel;
  }

  Future<void> init({
    AliPayEnv envEnum = AliPayEnv.ONLINE,
    EnvType envType = EnvType.PRODUCTION,
  }) {
    return MpayPluginPlatform.instance.init(envEnum: envEnum, envType: envType);
  }
}
