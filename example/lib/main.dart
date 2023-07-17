import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mpay_plugin/mpay_plugin.dart';

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

  @override
  void initState() {
    super.initState();
    dio = Dio();
    dio.options.baseUrl = "http://k3qdjv.natappfree.cc/";
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 5);
  }

  Future<void> pay() async {
    Map<String, dynamic> innerMsg = {
      "sub_merchant_name": "九紅家電",
      "sub_merchant_id": "888535722315285",
      "sub_merchant_industry": "5722",
    };
    var response = await dio.post("/test/onlineAppCreate", data: {
      "org_id": "00000000004414",
      "sign_type": "MD5",
      "pay_channel": "mpay",
      "total_fee": "0.1",
      "body": "我的商品1",
      "sub_appid": "0000000000441402",
      "subject": "商品",
      "sub_merchant_name": "九紅家電",
      "sub_merchant_id": "888535722315285",
      "sub_merchant_industry": "5722",
      "extend_params": "WECHAT",
    });
    print(response);
    // Map<String, dynamic> map = jsonDecode(value.data.toString());
    // _mPayPlugin.mPay(map["data"]["pay_info"]);
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
                  onPressed: () => _mPayPlugin.mPay(
                      """_input_charset＝"utf-8"&body＝"正掃付款+%"&currency="HKD"&forex_biz="FP"&it_b_pay="5m\'&notify_url="https://uatopenapi.macaupay.com.mo/ucop/v2/api/alipayNotify.do"&out_trade_no="202=+%"www.macaupass.com"&return_url=\https://uatopenapi.macaupay.com.mo/ucop/v2/api/alipayReturn.do"&secondary_merchant_id="888534816774062\&secondar"&seller_id="2088621971500654\&service=\mobile.securitypay.pay"&sign="M0kx06ocqqkJnxMFWg809dBtg7nx6h7vVqwD5ncirm1Jqe3bX%2FXN6Hwt5J%2B8um7TsQKVG3DMrJHRNHJN08U%2FtqcD1s6BFvYTATHr8yr%2FA6WMqhtjRKTYj%2Bh1%2FWoSiW3%2BBsJk8UKwdgxpQ45vNOCGGuo02AzuVibTBxI2LUaLYIK7jKdhbwAve6N2v1C%2FIC8bmHt%2BXHn9zmZsY1QB""").then(
                    (value) {
                      print("value: $value");
                    },
                  ),
                  // onPressed: () => pay(),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.indigo),
                  ),
                  child: const Text("Pay"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
