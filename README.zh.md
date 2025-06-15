# Flutter MPay 插件（澳门通版）

此插件在 Flutter 中集成澳门通支付，并提供独立的支付宝、微信以及香港微信钱包支付能力。

## 功能特点

- MPay 渠道统一支付：MPay、支付宝、微信
- 直连支付宝支付
- 直连微信支付
- 香港微信钱包支付
- 可配置支付环境（支付宝、MPay）
- 通过事件流监听支付结果

## 快速开始

```dart
final _mpay = MpayPlugin();

// 初始化环境
await _mpay.init(
  aliPayEnv: AliPayEnv.ONLINE,
  mPayEnv: MPayEnv.PRODUCTION,
);

// 注册微信
await _mpay.registerApi(appId: 'your_wechat_appid');
```

### MPay 渠道
```dart
final result = await _mpay.mPay(signData, PayChannel.wechatPay);
```

### 直连支付宝 / 微信
```dart
await _mpay.aliPay(payInfo, 'your.ios.scheme');
await _mpay.wechatPay(Payment(...));
```

### 香港微信钱包
```dart
await _mpay.wechatPay(HongKongWallet(prepayId: token));
```

### 监听支付回调
```dart
final cancel = _mpay.addSubscriber((event) {
  print('支付结果: $event');
});
```

无需监听时调用 `cancel.cancel()` 移除订阅。

## iOS 配置
关于 URL Scheme 与 Universal Link 的设置，请参考澳门通官方文档。
