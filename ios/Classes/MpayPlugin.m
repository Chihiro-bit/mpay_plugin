#import "MpayPlugin.h"

@implementation MpayPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"mpay_plugin"
            binaryMessenger:[registrar messenger]];
  MpayPlugin* instance = [[MpayPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
      result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([@"init" isEqualToString:call.method]) {
      NSDictionary *arguments = (NSDictionary *)call.arguments;
      NSString *aliEnv = (NSString *)arguments[@"aliEnv"];
      NSNumber *mpyEnv = (NSNumber *)arguments[@"mpyEnv"];
      [self initMapy:mpyEnv];
    } else if ([@"mPay" isEqualToString:call.method]) {
      NSDictionary *arguments = (NSDictionary *)call.arguments;
      NSString *data = (NSString *)arguments[@"data"];
      NSNumber *channel = (NSNumber *)arguments[@"channel"];
      [self pay:data param2:channel param3:result];
    } else {
      result(FlutterMethodNotImplemented);
    }
}

// 初始化mpay支付設置
- (void)initMapy:(NSNumber *)mpyEnv {
    NSString *mpyEnvString = [mpyEnv stringValue];

    if ([mpyEnvString isEqualToString:@"0"]) {
        [[OpenSDK sharedInstance] setEnvironmentType:MPay_Prod];
    } else if ([mpyEnvString isEqualToString:@"1"]) {
        [[OpenSDK sharedInstance] setEnvironmentType:MPay_SIT];
    } else if ([mpyEnvString isEqualToString:@"2"]) {
        [[OpenSDK sharedInstance] setEnvironmentType:MPay_UAT];
    }
}



#pragma mark - SDK

/**
 @param data 支付信息
 @param channel 支付渠道（ 0->mPay  ,  1-> alipay  ,  2->wechatPay ）
 */
- (void)pay:(NSString *)data param2:(NSNumber *)channel param3:(FlutterResult)result{
    NSString *channelString = [channel stringValue];
    if([channelString isEqualToString:@"0"]){
        [self mPay:data];
    }else if([channelString isEqualToString:@"1"]){
        [self aliPay:data];
    }else if([channelString isEqualToString:@"2"]){
        [self wechatPay:data];
    }
    NSDictionary *map = @{
        @"resultStatus" : @"-1",
        @"result" : @"success",
        @"memo" : @"success Info",
        @"type":@"Mpay"
    };
    result(map);
}

// Mpay
- (void) mPay:(NSString *)data{
    [[OpenSDK sharedInstance]MPayWithJsonString:data withSchema:@"mpayPlugin" WithSender:self withDelegate:self];
}
// AliPay
- (void) aliPay:(NSString *)data{
    [[OpenSDK sharedInstance]AliPayWithJsonString:data withScheme:@"mpayPlugin" with:self];
}
// WeChatPay
- (void) wechatPay:(NSString *)data{
    [[OpenSDK sharedInstance]WeChatPayWithJsonString:data withScheme:@"mpayPlugin" with:self];
}

#pragma mark - SDK Delegate 回調代理
/**
 支付結果成功回調
 @param status 訂單状态
 @param order 訂單信息
 */
-(void)OpenSDK_WithPayStatus:(bool)status WithOrder:(NSDictionary *)order{
    NSLog(@"Order Info: %@", order);
}
/**
 異常報錯
 @param errorInfo 異常信息
 */
-(void)OpenSDK_WithFailed:(NSString *)errorInfo withErrorCode:(NSString *)errorCode{
    NSLog(@"ErrorInfo: %@", errorInfo);
    NSLog(@"errorCode: %@", errorCode);
}

@end
