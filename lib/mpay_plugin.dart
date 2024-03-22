import 'package:mpay_plugin/arguments.dart';
import 'package:mpay_plugin/response/cancelable.dart';
import 'package:mpay_plugin/response/wechat_response.dart';

import 'mpay_plugin_platform_interface.dart';
import 'result_model.dart';

class MpayPlugin {

  late final WeakReference<void Function(WeChatResponse event)> responseListener;
  final List<WeChatResponseSubscriber> _responseListeners = [];

  Future<String?> getPlatformVersion() {
    return MpayPluginPlatform.instance.getPlatformVersion();
  }
  MpayPlugin() {
    responseListener = WeakReference((event) {
      for (var listener in _responseListeners) {
        listener(event);
      }
    });
    final target = responseListener.target;
    if (target != null) {
      MpayPluginPlatform.instance.responseEventHandler.listen(target);
    }
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
    AliPayEnv aliPayEnv = AliPayEnv.ONLINE,
    MPayEnv mPayEnv = MPayEnv.PRODUCTION,
  }) {
    return MpayPluginPlatform.instance.init(aliPayEnv: aliPayEnv, mPayEnv: mPayEnv);
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
  Future<bool> wechatPay(PayType payType) async {
    return await MpayPluginPlatform.instance.wechatPay(payType);
  }

  FluwxCancelable addSubscriber(WeChatResponseSubscriber listener) {
    _responseListeners.add(listener);
    return FluwxCancelableImpl(onCancel: () {
      removeSubscriber(listener);
    });
  }

  /// remove your subscriber from WeChat
  removeSubscriber(WeChatResponseSubscriber listener) {
    _responseListeners.remove(listener);
  }

  /// remove all existing
  clearSubscribers() {
    _responseListeners.clear();
  }
}
