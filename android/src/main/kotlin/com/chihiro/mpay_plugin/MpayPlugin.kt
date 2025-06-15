package com.chihiro.mpay_plugin

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.AsyncTask
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.alipay.sdk.app.EnvUtils
import com.alipay.sdk.app.PayTask
import com.chihiro.mpay_plugin.wxapi.WechatCallbackActivity
import com.macau.pay.sdk.OpenSdk
import com.macau.pay.sdk.util.Logger
import com.tencent.mm.opensdk.modelbase.BaseReq
import com.tencent.mm.opensdk.modelbase.BaseResp
import com.tencent.mm.opensdk.modelmsg.LaunchFromWX
import com.tencent.mm.opensdk.modelmsg.ShowMessageFromWX
import com.tencent.mm.opensdk.modelpay.PayReq
import com.tencent.mm.opensdk.modelpay.PayResp
import com.tencent.mm.opensdk.modelbiz.WXOpenBusinessWebview
import com.tencent.mm.opensdk.openapi.IWXAPI
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler
import com.tencent.mm.opensdk.openapi.WXAPIFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.lang.ref.WeakReference
import java.util.HashMap
import java.util.concurrent.Executors

/** MpayPlugin */
class MpayPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.NewIntentListener {

    private lateinit var channel: MethodChannel
    private var activityPluginBinding: ActivityPluginBinding? = null

    // 上下文 Context
    private lateinit var mContext: Context
    private var mActivity: Activity? = null
    private var initializationParams: Map<String, Any>? = null
    private lateinit var wxapiEventHandler: WXAPIEventHandler

    companion object {
        private const val TAG = "MpayPlugin"
        private const val errStr = "errStr"
        private const val errCode = "errCode"
        private const val openId = "openId"
        private const val type = "type"

        //        微信支付 api
        var iwxapi: IWXAPI? = null
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "mpay_plugin")
        channel.setMethodCallHandler(this)
        mContext = flutterPluginBinding.applicationContext
        wxapiEventHandler = WXAPIEventHandler(channel)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            "mPay" -> {
                val mPayHandler = MPayHandler(result, mActivity!!)
                /// 接收Flutter端支付參數
                val arguments = call.arguments as Map<*, *>
                // 支付參數
                val data = arguments["data"] as String
                // 支付通道，當前android用不上
                var channel = arguments["channel"] as Int
                mPayHandler.pay(data)
                return
            }

            "init" -> {
                setInitializationParams(call.arguments as Map<String, Any>)
                return
            }
            /// 純支付寶支付，不走mPay通道
            "aliPay" -> {
                val payInfo = call.argument<String>("payInfo")
                pay(mActivity, payInfo, result)
            }

            "registerApp" -> {
//                WXAPiHandler.registerApp(call, result, mActivity)
//                WXAPiHandler.wxApi?.setLogImpl(weChatLogger)
                registerApp(call, result);
            }

            "wechatPay" -> {
//                handlePayCall(call, result)
                payWeChat(call, result)
            }

            "wechatPayHongKongWallet" -> {
                payWithHongKongWallet(call, result)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mActivity = binding.activity
        binding.addOnNewIntentListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }

    /**
     * 使用支付寶直接支付，不通過mpay通道
     * @param activity 生命週期context
     * @param payInfo 支付信息
     * @param callback 支付回調
     */
    fun pay(currentActivity: Activity?, payInfo: String?, callback: Result) {
        val executor = Executors.newSingleThreadExecutor()
        val handler = Handler(Looper.getMainLooper())

        executor.execute {
            val result: Map<String?, String?> = try {
                val alipay = PayTask(currentActivity)
                alipay.payV2(payInfo, true)
            } catch (e: Exception) {
                val errorResult: MutableMap<String?, String?> = HashMap()
                errorResult["\$error"] = e.message
                errorResult
            }

            handler.post {
                val error = result["\$error"]
                if (error != null) {
                    callback.error(error, "支付发生错误", null)
                } else {
                    callback.success(result)
                }
            }
        }
    }



//    Thread payThread = new Thread(payRunnable);
//    payThread.start();


    private fun initializePlugin(params: Map<String, Any>) {
        /// 支付宝环境
        val envEnum = params["aliEnv"] as Int
        /// Mpay 生产或者测试环境
        val envType = params["mpyEnv"] as Int
        if (envEnum == 0) {
            EnvUtils.setEnv(EnvUtils.EnvEnum.ONLINE)

        } else {
            EnvUtils.setEnv(EnvUtils.EnvEnum.SANDBOX)
        }
        OpenSdk.setMPayAppId(envType)
        OpenSdk.setEnvironmentType(envType)
        Logger.i("支付宝环境：$envEnum")
        Logger.i("Mpay环境：$envType")
    }

    private fun setInitializationParams(params: Map<String, Any>) {
        // 则设置参数并初始化插件
        initializationParams = params
        initializationParams?.let { initializePlugin(it) }
    }

    private fun registerApp(call: MethodCall, result: Result) {
        val appId = call.argument<String>("appId")
        //        final String universalLink = call.argument("universalLink");
        iwxapi = WXAPIFactory.createWXAPI(mActivity, appId)
        iwxapi!!.registerApp(appId)
        result.success(null)
    }

    private fun payWeChat(call: MethodCall, result: Result) {
        try {
            val request = PayReq()
            request.appId = call.argument("appId")
            request.partnerId = call.argument("partnerId")
            request.prepayId = call.argument("prepayId")
            request.packageValue = call.argument("packageValue")
            request.nonceStr = call.argument("nonceStr")
            request.timeStamp = call.argument<Long>("timeStamp").toString()
            request.sign = call.argument("sign")
            request.signType = call.argument("signType")
            request.extData = call.argument("extData")
//            iwxapi!!.sendReq(request)
            wxapiEventHandler.startPayment(iwxapi!!, request, result)
        } catch (e: Exception) {
            Log.d(TAG, "payWeChat: ${e}")
        }
    }

    private fun payWithHongKongWallet(call: MethodCall, result: Result) {
        try {
            val prepayId = call.argument<String>("prepayId")
            val req = WXOpenBusinessWebview.Req()
            req.businessType = 1
            val info = HashMap<String, String>()
            info["token"] = prepayId ?: ""
            req.queryInfo = info
            val done = iwxapi?.sendReq(req) ?: false
            result.success(done)
        } catch (e: Exception) {
            Log.d(TAG, "payWithHongKongWallet: $e")
            result.error("HKPAY_ERROR", e.message, null)
        }
    }

    override fun onNewIntent(intent: Intent): Boolean {
        val extra = WechatCallbackActivity.extraCallback(intent)
        if (iwxapi != null) {
            Log.d(TAG, "onNewIntent: $extra")
            Log.d(TAG, "onNewIntent: $iwxapi")
            iwxapi!!.handleIntent(extra, wxapiEventHandler)
            return true
        }
        return false
    }

//    override fun onReq(p0: BaseReq?) {
//        Log.d(TAG, "onReq1: ${p0?.type}")
//    }
//
//    override fun onResp(p0: BaseResp?) {
//        Log.d(TAG, "onResp1: ${p0?.type}")
//    }

//    private val iwxapiEventHandler: IWXAPIEventHandler = object : IWXAPIEventHandler {
//        override fun onReq(req: BaseReq) {
//            Log.d(TAG, "onReq2: ${req.type}")
//        }
//
//        override fun onResp(resp: BaseResp) {
//            Log.d(TAG, "onResp2: ${resp}")
//        }
//    }
//
//    private fun handlePayResp(response: PayResp) {
//        val result = mapOf(
//            "prepayId" to response.prepayId,
//            "returnKey" to response.returnKey,
//            "extData" to response.extData,
//            errStr to response.errStr,
//            type to response.type,
//            errCode to response.errCode
//        )
//        channel.invokeMethod("onPayResponse", result)
//        Log.d(TAG, "handlePayResp: $result")
//    }
}
