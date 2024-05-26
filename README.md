# mpay_plugin

澳門通支付插件

## Getting Started

```dart
import 'package:mpay_plugin/mpay_plugin.dart';
```

### 初始化

```dart

final _mPayPlugin = MpayPlugin();
```

### 参数说明

| 参数        | 类型                                           | 说明                         |
|:----------|:---------------------------------------------|:---------------------------|
| aliPayEnv | AliPayEnv.ONLINE, AliPayEnv.SANDBOX          | AliPay线上环境和沙箱环境，仅支持Android |
| mPayEnv   | EnvType.PRODUCTION,EnvType.SIT, EnvType.UAT, | MPay生产环境，测试环境和UAT          |

```dart
  @override
void initState() {
  super.initState();
  _mPayPlugin.init(
    aliPayEnv: AliPayEnv.ONLINE,
    mPayEnv: EnvType.UAT,
  );

  _mPayPlugin.registerApi(
    appId: 'your app id',
    doOnIOS: true,
    doOnIOS: true,
    universalLink: 'your universal link',
  );
}
```

### 任何支付回调都可以用await来接收，native端的数据都会通过result返回，不需要使用监听器来接收支付结果

### 支付 - Mpay

```dart

PayChannel payChannel = PayChannel.mpay;

var result = await _mPayPlugin.pay("pay info", payChannel,withScheme:"iOS scheme");
```

### 支付 - AliPay

```dart
PayChannel payChannel = PayChannel.aliPay;
var result = await _mPayPlugin.aliPay("pay info", "ios scheme");
```

### 支付 - WeChat

```dart
PayType payType = PayType();
var result = await _mPayPlugin.MpayPluginPlatform(payType);
```
