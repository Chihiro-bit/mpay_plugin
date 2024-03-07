import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mpay_plugin/mpay_plugin.dart';
import 'package:logger/logger.dart';
import 'package:mpay_plugin/mpay_plugin_platform_interface.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() {
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
  @override
  void initState() {
    super.initState();
    _mPayPlugin.init(
      envEnum: AliPayEnv.ONLINE,
      envType: EnvType.UAT,
    );
    dio = Dio();
    dio.options.baseUrl = "YOUR_BASEURL;
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
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
                  onPressed: () => _mPayPlugin.aliPay(payInfo,"com.mpay_plugin.demo"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.indigo),
                  ),
                  child: const Text("Not MPayAliPay"),
                ),
                ElevatedButton(
                  onPressed: () => pay("wechat"),
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
}
