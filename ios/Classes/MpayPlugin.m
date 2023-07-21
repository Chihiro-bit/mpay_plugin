#import "MpayPlugin.h"
#import "MPayHandler.h"
@implementation MpayPlugin

MPayHandler *payHandler;
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"mpay_plugin"
            binaryMessenger:[registrar messenger]];
  MpayPlugin* instance = [[MpayPlugin alloc] init];
  payHandler = [[MPayHandler alloc] init];
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
//      [self pay:data param2:channel param3:result];
        // 创建MPayHandler对象
    
        [payHandler pay:data param2:channel param3:result];
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
@end
