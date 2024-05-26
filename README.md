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

| 参数 | 类型                                           | 说明                         |
| :-----|:---------------------------------------------|:---------------------------|
| envEnum | AliPayEnv.ONLINE, AliPayEnv.SANDBOX          | AliPay线上环境和沙箱环境，仅支持Android |
| envType | EnvType.PRODUCTION,EnvType.SIT, EnvType.UAT, | MPay生产环境，测试环境和UAT          |


```dart
  @override
void initState() {
  super.initState();
  _mPayPlugin.init(
    envEnum: AliPayEnv.ONLINE,
    envType: EnvType.UAT,
  );
}
```