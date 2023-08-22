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

#### MPay支付
--- payChannel 是提供给后台的使用的支付方式，一般有 mpay,alipay,wechatPay 三个，需要根据这个参数设置不同的PayChannel 枚举传入，否则ios端无法判断是什么支付类型
```dart
  Future<void> pay(String type) async {
    Map<String, dynamic> datas = {
      "payChannel": type,
      "totalFee": "5",
      "currency": "MOP",
      "subject": "测试订单",
      "body": "测试app验签支付"
    };
    var response =
        await dio.post("test/merchantSign", data: FormData.fromMap(datas));

    String jsonString = json.encode(response.data["data"]["signData"]);
    Logger().i(jsonString);
    try {
      PayChannel payChannel = PayChannel.aliPay;
      if (type == "mpay") {
        payChannel = PayChannel.mPay;
      } else if (type == "alipay") {
        payChannel = PayChannel.aliPay;
      } else {
        payChannel = PayChannel.wechatPay;
      }
      var result = await _mPayPlugin.mPay(jsonString, payChannel);
      if (result.resultStatus == "9000") {
        EasyLoading.showSuccess("支付成功");
      } else {
        EasyLoading.showError(result.result ?? "");
      }
      Logger().i(result.toString());
    } catch (e) {
    }
  }
```

### 因为MPay支付插件集成了AliPay 和 wechatPay，所以如果你还依赖他们的sdk就会冲突，考虑到有时候只要这两个可能需要单独的支付，所以这里提供了两个方法，可以单独调用
--- 调用如下
##### aliPay
```dart
var response = await _mPayPlugin.aliPay('payInfo',"com.mpay_plugin.demo"), // payInfo是请求后台返回来的支付字符串，com.mpay_plugin.demo是shceme ios端需要，并且需要在info.plist中配置 URL Types
```

##### wechatPay
```dart
var response = await _mPayPlugin.wechatPay(Payment(
appId: 'appid',
partnerId: 'partnerid',
prepayId: 'prepayid',
packageValue: 'package',
nonceStr: 'noncestr',
timestamp: 0,
sign: 'sign',
));
```
--- 以上的参数都是需要通过后台获取到数据传入，而不是填写上面的字符串，这里只是为了方便演示，实际使用中需要通过后台获取到数据传入。微信支付ios需要配置url_scheme，universal_link, LSApplicationQueriesSchemes，具体配置请参考微信支付官方文档

### Ios 端特别配置

打开AppDelegate.m文件，添加如下代码
```objectivec
#import <OpenSDK/OpenSDK.h>
#import <MpayPlugin.h>
```
--- 在application方法中添加 `[[OpenSDK sharedInstance] ProcessOrderWithPaymentResult:url];
[[MpayPlugin sharedInstance] AliPaymentResult:url];`这一步本可以在插件中处理，但是实际使用发现会出现接收不到消息的情况，或者接收消息速度缓慢，AppDelegate中处理的话就不会出现这种情况，所以这里建议在AppDelegate中处理
```objectivec
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    //回调方法，必調
    [[OpenSDK sharedInstance] ProcessOrderWithPaymentResult:url];
    [[MpayPlugin sharedInstance] AliPaymentResult:url];
    return true;
}
}