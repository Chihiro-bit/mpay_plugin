import 'package:flutter_test/flutter_test.dart';
import 'package:mpay_plugin/mpay_plugin.dart';
import 'package:mpay_plugin/mpay_plugin_platform_interface.dart';
import 'package:mpay_plugin/mpay_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMpayPluginPlatform
    with MockPlatformInterfaceMixin
    implements MpayPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
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
