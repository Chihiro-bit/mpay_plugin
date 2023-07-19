package com.chihiro.mpay_plugin

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import com.alipay.sdk.app.EnvUtils
import com.macau.pay.sdk.OpenSdk
import com.macau.pay.sdk.base.ConstantBase
import com.macau.pay.sdk.util.Logger

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** MpayPlugin */
class MpayPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel

    // 上下文 Context
    private lateinit var mContext: Context
    private var mActivity: Activity? = null
    private var initializationParams: Map<String, Any>? = null
    private var isInitialized = false
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "mpay_plugin")
        channel.setMethodCallHandler(this)
        mContext = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            "mPay" -> {
                val mPayHandler = MPayHandler(result, mActivity!!)
                /// 接收Flutter端支付參數
                mPayHandler.pay(call.arguments as String?)
                return
            }

            "init" -> {
                setInitializationParams(call.arguments as Map<String, Any>)
                return
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mActivity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }

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
}
