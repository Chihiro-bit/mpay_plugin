package com.chihiro.mpay_plugin.handlers

import android.content.Context
import com.tencent.mm.opensdk.constants.Build
import com.tencent.mm.opensdk.openapi.IWXAPI
import com.tencent.mm.opensdk.openapi.WXAPIFactory
import com.tencent.mm.opensdk.utils.ILog
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

object WXAPiHandler  {

    var wxApi: IWXAPI? = null

//    private var context: Context? = null

    private var registered: Boolean = false

    val wxApiRegistered get() = registered

    //是否为冷启动
    var coolBoot: Boolean = false

    fun setupWxApi(appId: String, context: Context, force: Boolean = true): Boolean {
        if (force || !registered) {
//            setContext(context)
            registerWxAPIInternal(appId, context)
        }
        return registered
    }
//
//    fun setContext(context: Context?) {
//        WXAPiHandler.context = context
//    }

    fun registerApp(call: MethodCall, result: MethodChannel.Result, context: Context?) {

        if (call.argument<Boolean?>("android") == false) {
            return
        }

        if (wxApi != null) {
            result.success(true)
            return
        }

        val appId: String? = call.argument("appId")
        if (appId.isNullOrBlank()) {
            result.error("invalid app id", "are you sure your app id is correct ?", appId)
            return
        }

        context?.let {
            registerWxAPIInternal(appId, it)
        }
        result.success(registered)
    }

    fun checkWeChatInstallation(result: MethodChannel.Result) {
        if (wxApi == null) {
            result.error("Unassigned WxApi", "please config  wxapi first", null)
            return
        } else {
            result.success(wxApi?.isWXAppInstalled)
        }
    }

    fun checkSupportOpenBusinessView(result: MethodChannel.Result) {
        when {
            wxApi == null -> {
                result.error("Unassigned WxApi", "please config  wxapi first", null)
            }

            wxApi?.isWXAppInstalled != true -> {
                result.error("WeChat Not Installed", "Please install the WeChat first", null)
            }

            (wxApi?.wxAppSupportAPI ?: 0) < Build.OPEN_BUSINESS_VIEW_SDK_INT -> {
                result.error("WeChat Not Supported", "Please upgrade the WeChat version", null)
            }

            else -> {
                result.success(true)
            }
        }
    }

    private fun registerWxAPIInternal(appId: String, context: Context) {
        val api = WXAPIFactory.createWXAPI(context.applicationContext, appId)
        registered = api.registerApp(appId)
        wxApi = api
    }

}