---

# Flutter MPay 插件使用文档（澳门通定制版）

---

## 一、功能特性

本插件专为澳门通支付体系定制，提供以下支付渠道：  
✅ **澳门通MPay**  
✅ **支付宝（通过澳门通渠道）**  
✅ **微信支付（通过澳门通渠道）**  
✅ **独立支付宝支付（非澳门通渠道）**  
✅ **独立微信支付（非澳门通渠道）**

---

## 二、核心概念

### 支付方式分类
| **支付方式**       | **数据来源**              | **适用场景**                  |
|---------------------|---------------------------|-----------------------------|
| `PayChannel.mPay`    | 澳门通后台生成            | 澳门通自有支付体系            |
| `PayChannel.alipay`  | 澳门通后台生成            | 通过澳门通渠道的支付宝支付      |
| `PayChannel.wechat`  | 澳门通后台生成            | 通过澳门通渠道的微信支付        |
| `aliPay()`           | 自行构造支付参数          | 直连支付宝（非澳门通渠道）      |
| `wechatPay()`        | 自行构造支付参数          | 直连微信支付（非澳门通渠道）    |

---

## 三、支付流程对比

### 1. 澳门通渠道支付流程
```mermaid
graph TD
  A[客户端] --> B{选择支付方式}
  B -->|MPay/Alipay/Wechat| C[请求澳门通后台]
  C --> D[获取澳门通签名数据]
  D --> E[调用mPay()方法]
```

### 2. 独立支付流程
```mermaid
graph TD
  A[客户端] --> B{选择支付方式}
  B -->|直连Alipay/Wechat| C[自行构造支付参数]
  C --> D[调用aliPay()/wechatPay()]
```

---

## 四、接口详解

### 1. 澳门通统一支付接口
```dart
Future<Map> mPay(
  String signData,        // 必须从澳门通后台获取的签名数据
  PayChannel channel,     // 指定支付渠道类型
  String? iosUrlScheme    // iOS专用URL Scheme
)
```

#### 参数说明：
| 参数          | 类型         | 必填 | 说明                          |
|---------------|--------------|------|-----------------------------|
| signData      | String       | 是   | 澳门通后台返回的**加密支付数据** |
| channel       | PayChannel   | 是   | 必须与signData的渠道类型一致    |
| iosUrlScheme  | String?      | 否   | iOS支付宝跳转标识（仅iOS需要）  |

#### 代码示例：
```dart
// 从澳门通后台获取支付数据
final response = await dio.post(
  "/mpay/create_order",
  data: {"amount": "100", "currency": "MOP"}
);

// 解析澳门通返回的签名数据
final signData = jsonEncode(response.data["signData"]);

// 发起支付（渠道类型必须与后台数据匹配）
final result = await _mPayPlugin.mPay(
  signData,
  PayChannel.alipay, // 可选：mPay/alipay/wechat
  "com.yourcompany.app" // iOS Scheme
);
```

### 2. 独立支付接口
```dart
// 支付宝直连
Future<Map> aliPay(
  String payInfo,       // 自行构造的支付参数
  String iosUrlScheme   // iOS专用URL Scheme
);

// 微信直连
Future<Map> wechatPay(
  Payment paymentData   // 自行构造的支付参数
);
```

#### 代码示例：
```dart
// 直连支付宝（非澳门通渠道）
final payInfo = "_input_charset=\"UTF-8\"&total_fee=\"0.01\"...";
await _mPayPlugin.aliPay(payInfo, "com.yourcompany.app");

// 直连微信（非澳门通渠道）
final payment = Payment(
  appId: "wx1234567890",
  partnerId: "1900000109",
  prepayId: "wx202308...",
  nonceStr: "5K8264...",
  timestamp: 1690343604,
  packageValue: "Sign=WXPay",
  sign: "C380BEC2BF..."
);
await _mPayPlugin.wechatPay(payment);
```

---

## 五、错误处理指南

### 常见错误码对照表
| 错误码 | 渠道      | 含义                  | 处理建议                     |
|--------|-----------|-----------------------|----------------------------|
| 1001   | MPay      | 订单已存在            | 检查订单号唯一性             |
| 2003   | Alipay    | 支付超时              | 提示用户重新发起支付         |
| 3008   | Wechat    | 余额不足              | 引导用户更换支付方式         |
| 4000   | All       | 网络错误              | 检查设备网络连接             |

### 调试建议
```dart
try {
  final result = await _mPayPlugin.mPay(...);
  if (result['resultStatus'] == "9000") {
    EasyLoading.showSuccess("支付成功");
  } else {
    _handleError(result);
  }
} catch (e) {
  Logger().e("支付异常: ${e.toString()}");
  EasyLoading.showError("系统繁忙，请稍后重试");
}

void _handleError(Map result) {
  final errorMap = {
    "1001": "订单重复提交",
    "2003": "支付超时，请检查网络",
    "3008": "账户余额不足"
  };
  EasyLoading.showError(errorMap[result['code']] ?? "支付失败");
}
```

---

## 六、最佳实践

### 1. 环境配置建议
```dart
@override
void initState() {
  super.initState();
  
  // 测试环境配置
  if (isTestEnv) {
    _mPayPlugin.init(
      aliPayEnv: AliPayEnv.SANDBOX,
      mPayEnv: MPayEnv.UAT
    );
  }
  
  // 生产环境配置
  else {
    _mPayPlugin.init(
      aliPayEnv: AliPayEnv.ONLINE,
      mPayEnv: MPayEnv.PRODUCTION
    );
  }
}
```

### 2. 支付方式选择器
```dart
void showPaymentSelector() {
  showModalBottomSheet(
    context: context,
    builder: (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text("澳门通MPay"),
          onTap: () => _payWithChannel(PayChannel.mPay),
        ),
        ListTile(
          title: Text("支付宝（澳门通）"),
          onTap: () => _payWithChannel(PayChannel.alipay),
        ),
        ListTile(
          title: Text("微信（澳门通）"),
          onTap: () => _payWithChannel(PayChannel.wechat),
        ),
        Divider(),
        ListTile(
          title: Text("直连支付宝"),
          onTap: _payDirectAlipay,
        ),
        ListTile(
          title: Text("直连微信"),
          onTap: _payDirectWechat,
        ),
      ],
    ),
  );
}
```

---

## 七、注意事项

1. **数据签名验证**
    - 澳门通渠道支付必须使用其后台生成的签名数据
    - 禁止修改签名数据的任何字段

2. **渠道一致性规则**
   ```dart
   // 错误用法（渠道类型与数据不匹配）
   final data = getMpayAlipayData(); // 澳门通支付宝数据
   _mPayPlugin.mPay(data, PayChannel.wechat); // ❌ 渠道类型错误
   ```

3. **iOS配置要求**
   ```xml
   <!-- Info.plist -->
   <key>CFBundleURLTypes</key>
   <array>
     <!-- 支付宝 -->
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.yourcompany.app</string> <!-- 与iosUrlScheme一致 -->
       </array>
     </dict>
     <!-- 微信 -->
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>wx1234567890abcdef</string> <!-- 微信APPID -->
       </array>
     </dict>
   </array>
   ```
