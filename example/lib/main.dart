import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mpay_plugin/arguments.dart';
import 'dart:async';
import 'package:mpay_plugin/mpay_plugin.dart';
import 'package:logger/logger.dart';
import 'package:mpay_plugin/mpay_plugin_platform_interface.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mpay_plugin/response/wechat_response.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _mPayPlugin = MpayPlugin();
  late Dio dio;
  String payInfo =
  """_input_charset=\"UTF-8\"&body=\"Product\"&currency=\"HKD\"&forex_biz=\"FP\"&it_b_pay=\"179m\"&notify_url=\"https://api.yedpay.com/notify/alipay-online\"&out_trade_no=\"169034360430235\"&partner=\"2088721929663896\"&payment_type=\"1\"&product_code=\"NEW_WAP_OVERSEAS_SELLER\"&return_url=\"https://api.yedpay.com/alipay-online\"&secondary_merchant_id=\"2NMJVPOMGD3YO70RL8\"&secondary_merchant_industry=\"7538\"&secondary_merchant_name=\"TTECH Global Service Limited\"&seller_id=\"2088721929663896\"&service=\"mobile.securitypay.pay\"&sign=\"bKSHYm91pFmKAD%2FCTr5K0B9%2F2dHHuykSkcVP9WJIpBlxthz5LkAwkqkRENFrKgOfd3JNSlth3KdkbZ9EB9aWpTm1zuGMJ2wwgljoi2jsUNao5y3AbkZfBQ1vgD8KT6UdHmPq%2BckZUoqNqr4MjN4bVNYAb4xXBGVw9Xh%2B%2Bch6AUjmKqXt3R8qk4NG4w9xgsDgItFxdiOeNPoBkbSc19FwwCqrEwwQ%2BEHyTTfgSk3UJ9yl3R2JL1r%2Fi2nNDOLFuXGzExOQPipr6KtKjQ1rS5oF3KAkaCIpLugNT4LfkSMS3gf0ohBOcr%2BA%2FBDFVG3u4xOHD84yUxmHMDJNuupOLyF8%2BA%3D%3D\"&sign_type=\"RSA\"&subject=\"Product\"&total_fee=\"0.20\"""";

  // late Function(WeChatResponse) responseListener;

  Future<void> registerWeChat() async {
    var aa = await _mPayPlugin.registerApi(
      appId: "YOUR_APPID",
      doOnIOS: true,
      doOnAndroid: true,
      universalLink: "YOUR_UNIVERSALINK",
    );
    Logger().i(aa);
  }

  @override
  void initState() {
    super.initState();
    registerWeChat();
    _mPayPlugin.init(
      aliPayEnv: AliPayEnv.ONLINE,
      mPayEnv: MPayEnv.UAT,
    );
    dio = Dio();
    dio.options.baseUrl = "YOUR_BASER_URL";
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    dio.interceptors.add(LogInterceptor(responseBody: true));
    // 添加请求头
    dio.options.headers["auth-token"] =
    "eyJhbGciOiJIUzI1NiJ9.eyJ1SWQiOjE2LCJzdWIiOiJUb2tlbiIsImF1ZCI6ImFIdUhrQiIsInRlbmFudEtleSI6ImFkbWluIiwibmFtZSI6IjE5ODA3MDU3NDRAcXEuY29tIiwiZXhwIjoxNzE2ODg5NTc5LCJkZXZpY2UiOiJhcHAiLCJpYXQiOjE3MTY4MDMxNzl9.lg0gnv-U4w7u0akVgsy5zNmVvF2NsJ-El8KssLBG0PM";
    dio.options.headers["content-type"] = "application/x-www-form-urlencoded";
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          Logger().i(options.data);
          Logger().i(options.path);
          return handler.next(options);
        },
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          Logger().i(response.data);
          return handler.next(response);
        },
        onError: (DioException e, ErrorInterceptorHandler handler) {
          Logger().i(e);
          return handler.next(e);
        },
      ),
    );

    // responseListener = (response) {
    //   if (response is WeChatPaymentResponse) {
    //     Logger().i(response.isSuccessful);
    //   }
    // };
    // _mPayPlugin.addSubscriber(responseListener);
  }

  Future<void> pay(String type) async {
    EasyLoading.show(status: "loading...", maskType: EasyLoadingMaskType.black);
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
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.indigo),
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => pay("mpay"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.indigo),
                  ),
                  child: const Text("MPay"),
                ),
                ElevatedButton(
                  onPressed: () => pay("alipay"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.indigo),
                  ),
                  child: const Text("AliPay"),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _mPayPlugin.aliPay(payInfo, "com.mpay_plugin.demo"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.indigo),
                  ),
                  child: const Text("Not MPayAliPay"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    var response = await dio.post(
                      "/appApi/payment",
                      data: {
                        "orderNo": "2024052717420001",
                        "mechanism": "CHINAUMS",
                        "channel": "wechat",
                        "terminal": "APP",
                        "wallet": "HK",
                        "currency": "CNY"
                      },
                    );
                    var paymentNo = findKeyAsString(response.data, "paymentNo");
                    var errCode = findKeyAsString(response.data, "errCode");
                    if (errCode == "SUCCESS") {
                      var result = json.decode(response.data["data"]["result"]["payInfo"]);
                      Logger().d(result);
                      if (result != null) {
                        Payment payType = Payment(
                            appId: findKeyAsString(result, "appid") ?? '',
                            partnerId: findKeyAsString(result, "partnerid") ?? '',
                            prepayId: findKeyAsString(result, "prepayid") ?? '',
                            packageValue: findKeyAsString(result, "package") ?? '',
                            nonceStr: findKeyAsString(result, "noncestr") ?? '',
                            timestamp: int.tryParse(
                                findKeyAsString(result, "timestamp") ?? '0') ??
                                0,
                            sign: findKeyAsString(result, "sign") ?? '');
                        var payWechat = await _mPayPlugin.wechatPay(payType);

                        Logger().d("微信支付 result回调${payWechat.toJson()}");
                      }
                    } else {

                      Logger().d("微信支付申请异常");
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.indigo),
                  ),
                  child: const Text("WeChatPay"),
                ),
              ],
            ),
          ),
        ),
      ),
      builder: EasyLoading.init(),
    );
  }

  static String? findKeyAsString(Map<dynamic, dynamic> data, String key) {
    // 检查当前层级的Map中是否包含key
    if (data.containsKey(key)) {
      // 确保返回值为字符串类型
      return data[key]?.toString();
    }

    // 如果没有找到，递归检查每个嵌套的Map
    for (var value in data.values) {
      if (value is Map) {
        String? result = findKeyAsString(value, key);
        if (result != null) {
          return result;
        }
      }
    }
    // 如果所有路径都没有找到，则返回null
    return null;
  }
}
