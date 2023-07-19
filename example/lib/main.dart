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

  @override
  void initState() {
    super.initState();
    _mPayPlugin.init(
      envEnum: AliPayEnv.SANDBOX,
      envType: EnvType.UAT,
    );
    dio = Dio();
    dio.options.baseUrl = "http://k3qdjv.natappfree.cc/";
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
    EasyLoading.show(status: "loading...",maskType: EasyLoadingMaskType.black);
    Map<String, dynamic> innerMsg = {
      "sub_merchant_name": "九紅家電",
      "sub_merchant_id": "888535722315285",
      "sub_merchant_industry": "5722",
    };
    Map<String, dynamic> params = {
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
      "extend_params": jsonEncode(innerMsg),
    };
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
    var result = await _mPayPlugin.mPay(jsonString);
    if(result.resultStatus=="9000"){
      EasyLoading.showSuccess("支付成功");
    }else{
      EasyLoading.showError(result.result??"");
    }
    EasyLoading.dismiss();
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
