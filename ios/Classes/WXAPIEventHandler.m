#import "MpayPlugin.h"
#import <Foundation/Foundation.h>
#import "WXAPIEventHandler.h"
#import "public/WeChatPayDelegateHeader.h"

@interface WXAPIEventHandler()
@property (nonatomic, strong) FlutterMethodChannel *channel;
@property (nonatomic, strong) FlutterResult result;
@end

@implementation WXAPIEventHandler

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    if (self) {
        _channel = channel;
    }
    return self;
}

- (void)startPaymentWithPayReq:(FlutterMethodCall *)call result:(FlutterResult)result {
    self.result = result;
    NSNumber *timestamp = call.arguments[@"timeStamp"];
    
    NSString *partnerId = call.arguments[@"partnerId"];
    NSString *prepayId = call.arguments[@"prepayId"];
    NSString *packageValue = call.arguments[@"packageValue"];
    NSString *nonceStr = call.arguments[@"nonceStr"];
    UInt32 timeStamp = [timestamp unsignedIntValue];
    NSString *sign = call.arguments[@"sign"];
    [WeChatPayDelegateHeader defaultManager].extData = call.arguments[@"extData"];
    
    NSString * appId = call.arguments[@"appId"];
    PayReq *req = [[PayReq alloc] init];
    req.openID = (appId == (id) [NSNull null]) ? nil : appId;
    req.partnerId = partnerId;
    req.prepayId = prepayId;
    req.nonceStr = nonceStr;
    req.timeStamp = timeStamp;
    req.package = packageValue;
    req.sign = sign;
    BOOL isSent = false;
    [WXApi sendReq:req completion:^(BOOL done) {
        if (done) {
            
        } else {
            result([FlutterError errorWithCode:@"PAYMENT_ERROR" message:@"Failed to send payment request" details:nil]);
        }
    }];
}

- (void)onReq:(BaseReq *)req {
    NSLog(@"onReq---->%@",@"OnReq調用了");
}

- (void)onResp:(BaseResp *)resp {
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    NSLog(@"onResp: %@", resp);
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *payResp = (PayResp *)resp;
        NSString *resultData;
        switch (payResp.errCode) {
            case WXSuccess:
                resultData = @"支付成功";
                break;
            case WXErrCodeCommon:
                resultData = @"支付错误：表示支付失败，原因可能是签名错误、未注册 APPID、项目设置错误、或其他错误";
                break;
            case WXErrCodeUserCancel:
                resultData = @"用户取消支付";
                break;
            case WXErrCodeSentFail:
                resultData = @"支付请求发送失败";
                break;
            case WXErrCodeAuthDeny:
                resultData = @"授权失败，用户拒绝授权申请";
                break;
            case WXErrCodeUnsupport:
                resultData = @"不支持的请求";
                break;
            default:
                resultData = @"支付错误：表示支付失败，原因可能是签名错误、未注册 APPID、项目设置错误、或其他错误";
                break;
        }
        map[@"resultStatus"] = payResp.errCode == WXSuccess ? @"9000" : @(payResp.errCode).stringValue;
        map[@"result"] = resultData;
        map[@"memo"] = [NSString stringWithFormat:@"%d: %@", payResp.errCode, payResp.errStr];
        map[@"type"] = @"WeChatPay";
        self.result(map);

        self.result = nil;
        [self.channel invokeMethod:@"onPayResponse" arguments:map];
    }
}

@end
