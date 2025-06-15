# Flutter MPay Plugin (Macau Pass Edition)

This package integrates the payment service of Macau Pass into Flutter. It also provides direct Alipay and WeChat payments as well as Hong Kong WeChat Wallet support.

## Features

- Unified payment via MPay channel: MPay, Alipay and WeChat Pay
- Direct Alipay payment
- Direct WeChat payment
- Hong Kong WeChat Wallet payment
- Configurable environments for Alipay and MPay
- Payment response stream allowing listeners to be registered

## Quick Start

```dart
final _mpay = MpayPlugin();

// Initialise environments
await _mpay.init(
  aliPayEnv: AliPayEnv.ONLINE,
  mPayEnv: MPayEnv.PRODUCTION,
);

// Register WeChat
await _mpay.registerApi(appId: 'your_wechat_appid');
```

### MPay channel
```dart
final result = await _mpay.mPay(signData, PayChannel.wechatPay);
```

### Direct Alipay / WeChat
```dart
await _mpay.aliPay(payInfo, 'your.ios.scheme');
await _mpay.wechatPay(Payment(...));
```

### Hong Kong WeChat Wallet
```dart
await _mpay.wechatPay(HongKongWallet(prepayId: token));
```

### Listen for payment result
```dart
final cancel = _mpay.addSubscriber((event) {
  print('pay result: $event');
});
```

Call `cancel.cancel()` when you no longer need the listener.

## iOS configuration
Refer to the MPay documentation for URL schemes and universal links settings.

