import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mpay_plugin/arguments.dart';

import 'mpay_plugin_platform_interface.dart';

/// An implementation of [MpayPluginPlatform] that uses method channels.
class MethodChannelMpayPlugin extends MpayPluginPlatform {
  final StreamController<Map> _responseEventHandler =
      StreamController.broadcast();

  @visibleForTesting
  final methodChannel = const MethodChannel('mpay_plugin');

  MethodChannelMpayPlugin() {
    methodChannel.setMethodCallHandler(_methodHandler);
  }

  // MethodChannelMpayPlugin() {
  //   methodChannel.setMethodCallHandler(_methodHandler);
  // }
  //
  @override
  Stream<Map> get responseEventHandler => _responseEventHandler.stream;

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  Future _methodHandler(MethodCall methodCall) {
    if (methodCall.method == 'onPayResponse') {
      _responseEventHandler
          .add(Map<String, dynamic>.from(methodCall.arguments));
    } else if (methodCall.method == 'wechatLog') {
      _printLog(methodCall.arguments);
    }

    return Future.value();
  }

  void _printLog(Map data) {
    debugPrint('FluwxLog: ${data["detail"]}');
  }

  @override
  Future<Map> mPay(
    String? data, {
    PayChannel channel = PayChannel.mPay,
    String? withScheme,
  }) async {
    var response = await methodChannel.invokeMethod<dynamic>('mPay', {
      "data": data,
      "channel": channel.value,
      "withScheme": withScheme,
    });
    return response;
  }

  @override
  Future<Map> aliPay(String data, String setIosUrlSchema) async {
    var response = await methodChannel.invokeMethod<dynamic>('aliPay', {
      "payInfo": data,
      "setIosUrlSchema": setIosUrlSchema,
    });
    return response;
  }

  @override
  Future<bool> registerApi({
    required String appId,
    bool doOnIOS = true,
    bool doOnAndroid = true,
    String? universalLink,
  }) async {
    if (doOnIOS && Platform.isIOS) {
      if (universalLink == null ||
          universalLink.trim().isEmpty ||
          !universalLink.startsWith('https')) {
        throw ArgumentError.value(
          universalLink,
          "You're trying to use illegal universal link, see "
          'https://developers.weixin.qq.com/doc/oplatform/Mobile_App/Access_Guide/iOS.html '
          'for more detail',
        );
      }
    }
    return await methodChannel.invokeMethod('registerApp', {
      'appId': appId,
      'iOS': doOnIOS,
      'android': doOnAndroid,
      'universalLink': universalLink
    });
  }

  @override
  Future<Map> wechatPay(PayType which) async {
    // var response = await methodChannel
    //     .invokeMethod<dynamic>('', {"payInfo": payInfo});
    // return response;
    switch (which) {
      case Payment():
        return await methodChannel.invokeMethod<dynamic>(
            'wechatPay', which.arguments);
      case HongKongWallet():
        return await methodChannel.invokeMethod<dynamic>(
            'wechatPayHongKongWallet', which.arguments);
    }
  }

  @override
  Future<void> init(
      {AliPayEnv aliPayEnv = AliPayEnv.ONLINE,
      MPayEnv mPayEnv = MPayEnv.PRODUCTION}) async {
    await methodChannel.invokeMethod<void>('init', {
      'aliEnv': aliPayEnv.value,
      'mpyEnv': mPayEnv.value,
    });
  }
}
