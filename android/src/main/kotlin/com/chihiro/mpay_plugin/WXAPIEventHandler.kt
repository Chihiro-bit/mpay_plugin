package com.chihiro.mpay_plugin

import android.text.TextUtils
import android.util.Log
import com.tencent.mm.opensdk.modelbase.BaseReq
import com.tencent.mm.opensdk.modelbase.BaseResp
import com.tencent.mm.opensdk.modelmsg.LaunchFromWX
import com.tencent.mm.opensdk.modelmsg.ShowMessageFromWX
import com.tencent.mm.opensdk.modelpay.PayReq
import com.tencent.mm.opensdk.modelpay.PayResp
import com.tencent.mm.opensdk.openapi.IWXAPI
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler
import io.flutter.plugin.common.MethodChannel

class WXAPIEventHandler(private val channel: MethodChannel) : IWXAPIEventHandler {

    companion object {
        const val TAG = "WXAPIEventHandler"
    }

    private var result: MethodChannel.Result? = null
    fun startPayment(api: IWXAPI, payReq: PayReq, result: MethodChannel.Result) {
        this.result = result
        Log.d(
            TAG, "payWeChat: \n" +
                    "appId: ${payReq.appId}, \n" +
                    "partnerId: ${payReq.partnerId}, \n" +
                    "prepayId: ${payReq.prepayId}, " +
                    "packageValue: ${payReq.packageValue}, \n" +
                    "nonceStr: ${payReq.nonceStr}, \n" +
                    "timeStamp: ${payReq.timeStamp}, \n" +
                    "sign: ${payReq.sign}, \n" +
                    "signType: ${payReq.signType}, \n" +
                    "extData: ${payReq.extData}\n"
        )
        val isSent = api.sendReq(payReq)
        if (!isSent) {
            result.error("PAYMENT_ERROR", "Failed to send payment request", null)
        }
    }

    override fun onReq(req: BaseReq) {
        val map = mutableMapOf<String, Any>()
        Log.d(TAG, "onReq3: ${req.type}")
//        发起微信请求
        when (req) {
            is LaunchFromWX.Req -> {
                map["messageAction"] = req.messageAction
                map["messageExt"] = req.messageExt
                map["lang"] = req.lang
                map["country"] = req.country
                channel.invokeMethod("onLaunchFromWXReq", map)
            }

            is ShowMessageFromWX.Req -> {
                map["messageAction"] = req.message.messageAction
                map["messageExt"] = req.message.messageExt
                map["lang"] = req.lang
                map["country"] = req.country
                channel.invokeMethod("onShowMessageFromWXReq", map)
            }
        }
    }

    override fun onResp(resp: BaseResp) {
        val map = mutableMapOf<String, Any>()
//        微信请求回调
        Log.d(TAG, "onResp3: ${resp.toString()}")
        when (resp) {
            is PayResp -> {
//                支付回调
                val resultData: String = if (!TextUtils.isEmpty(resp.errCode.toString())) {
                    when (resp.errCode) {
                        0 -> "支付成功"
                        -1 -> "支付错误：表示支付失败，原因可能是签名错误、未注册 APPID、项目设置错误、或其他错误"
                        -2 -> "用户取消支付"
                        -3 -> "支付请求发送失败"
                        -4 -> " 授权失败，用户拒绝授权申请"
                        -5 -> "不支持的请求"
                        -6 -> "错误禁令"
                        else -> "支付错误：表示支付失败，原因可能是签名错误、未注册 APPID、项目设置错误、或其他错误"
                    }
                } else {
                    "支付结果为空"
                }
                map["resultStatus"] = if (resp.errCode == 0) "9000" else resp.errCode.toString()
                map["result"] = resultData
                map["memo"] = "${resp.errCode}: ${resp.errStr}"
                map["type"] = "WeChatPay"
                result?.success(map)

                result = null
                channel.invokeMethod("onPayResponse", map)
            }
        }
    }
}
