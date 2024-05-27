#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "WXApi.h"
#import "WXApiObject.h"
#import "WechatAuthSDK.h"
#import "WeChatStringUtil.h"


@interface WXAPIEventHandler : NSObject

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel;
- (void)startPaymentWithPayReq:(FlutterMethodCall *)call result:(FlutterResult)result;
- (void)onReq:(BaseReq *)req;
- (void)onResp:(BaseResp *)resp;

@end
