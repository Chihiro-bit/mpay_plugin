import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mpay_plugin_platform_interface.dart';

/// An implementation of [MpayPluginPlatform] that uses method channels.
class MethodChannelMpayPlugin extends MpayPluginPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('mpay_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<dynamic> mPay(String? data) async {
    var response = await methodChannel.invokeMethod<dynamic>('mPay', data);
    return response;
  }
}
