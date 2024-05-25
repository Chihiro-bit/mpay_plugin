#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "WXApi.h"
#import "WXApiObject.h"
#import "WechatAuthSDK.h"
#import "WeChatStringUtil.h"
#import "public/WeChatPayDelegateHeader.h"

@interface WXAPIEventHandler : NSObject <WXApiDelegate, WechatAuthAPIDelegate>
@property NSMutableString *payChannel;
- (instancetype)initWithChannel:(FlutterMethodChannel *)channel;
- (void)startPaymentWithAPI:(WXApi *)api payReq:(FlutterMethodCall *)call result:(FlutterResult)result;

@end
