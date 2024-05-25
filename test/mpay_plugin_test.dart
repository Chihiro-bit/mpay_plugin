import 'package:flutter_test/flutter_test.dart';
import 'package:mpay_plugin/arguments.dart';
import 'package:mpay_plugin/mpay_plugin.dart';
import 'package:mpay_plugin/mpay_plugin_platform_interface.dart';
import 'package:mpay_plugin/mpay_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMpayPluginPlatform
    with MockPlatformInterfaceMixin
    implements MpayPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Map> aliPay(String data, String setIosUrlSchema) {
    // TODO: implement aliPay
    throw UnimplementedError();
  }

  @override
  Future<void> init({AliPayEnv aliPayEnv = AliPayEnv.ONLINE, MPayEnv mPayEnv = MPayEnv.PRODUCTION}) {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  Future<Map> mPay(String? data, {PayChannel channel = PayChannel.mPay, String? withScheme}) {
    // TODO: implement mPay
    throw UnimplementedError();
  }

  @override
  Future<bool> registerApi({required String appId, bool doOnIOS = true, bool doOnAndroid = true, String? universalLink}) {
    // TODO: implement registerApi
    throw UnimplementedError();
  }

  @override
  Future<bool> wechatPay(PayType which) {
    // TODO: implement wechatPay
    throw UnimplementedError();
  }
}

void main() {
  final MpayPluginPlatform initialPlatform = MpayPluginPlatform.instance;

  test('$MethodChannelMpayPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMpayPlugin>());
  });

  test('getPlatformVersion', () async {
    MpayPlugin mpayPlugin = MpayPlugin();
    MockMpayPluginPlatform fakePlatform = MockMpayPluginPlatform();
    MpayPluginPlatform.instance = fakePlatform;

    expect(await mpayPlugin.getPlatformVersion(), '42');
  });
}
