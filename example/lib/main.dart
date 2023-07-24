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
      envEnum: AliPayEnv.ONLINE,
      envType: EnvType.UAT,
    );
    dio = Dio();
    dio.options.baseUrl = "http://yc2x9m.natappfree.cc";
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
    try{
      PayChannel payChannel = PayChannel.aliPay;
      if(type=="mpay"){
        payChannel = PayChannel.mPay;
      }else if(type =="alipay"){
        payChannel = PayChannel.aliPay;
      }else{
        payChannel =PayChannel.wechatPay;
      }
      var result = await _mPayPlugin.mPay(jsonString,payChannel);
      if(result.resultStatus=="9000"){
        EasyLoading.showSuccess("支付成功");
      }else{
        EasyLoading.showError(result.result??"");
      }
      Logger().i(result.toString());
      EasyLoading.dismiss();
    }catch(e){
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
