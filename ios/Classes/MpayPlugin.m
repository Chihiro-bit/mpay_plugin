#import "MpayPlugin.h"
#import "MPayHandler.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import "WXApiObject.h"
#import "WechatAuthSDK.h"
#import "WeChatStringUtil.h"
#import "public/WeChatPayDelegateHeader.h"

@interface MpayPlugin() <WXApiDelegate, WechatAuthAPIDelegate>

@property (strong,nonatomic)NSString *extMsg;

typedef void(^WeChatReqRunnable)(void);

@property (readwrite,copy,nonatomic) FlutterResult callback;

@property (nonatomic) NSString* urlScheme;

@end

const NSString *errStr = @"errStr";
const NSString *errCode = @"errCode";
const NSString *openId = @"openId";
const NSString *fluwxType = @"type";
const NSString *lang = @"lang";
const NSString *country = @"country";
const NSString *description = @"description";

BOOL handleOpenURLByFluwx = YES;

@implementation MpayPlugin {
    FlutterMethodChannel *_channel;
    BOOL _isRunning;
    
    BOOL _attemptToResumeMsgFromWxFlag;
    WeChatReqRunnable _attemptToResumeMsgFromWxRunnable;
    // WXApi未注册时缓存打开url请求，WXApi注册后处理
    WeChatReqRunnable _cachedOpenUrlRequest;
}

+ (instancetype)sharedInstance {
    static MpayPlugin *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MpayPlugin alloc] init];
    });
    return sharedInstance;
}

MPayHandler *payHandler;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"mpay_plugin"
                                     binaryMessenger:[registrar messenger]];
    MpayPlugin* instance = [[MpayPlugin alloc] init];
    payHandler = [[MPayHandler alloc] init];
    
    [registrar addMethodCallDelegate:instance channel:channel];
}
- (instancetype)init:(FlutterMethodChannel *)channel {
    self = [super init];
    if (self) {
        _channel = channel;
        _isRunning = NO;
        _attemptToResumeMsgFromWxFlag = NO;

    [WXApi startLogByLevel:WXLogLevelDetail logBlock:^(NSString *log) {
            [self logToFlutterWithDetail:log];
        }];
        
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([@"init" isEqualToString:call.method]) {
        NSDictionary *arguments = (NSDictionary *)call.arguments;
        // NSString *aliEnv = (NSString *)arguments[@"aliEnv"];
        NSNumber *mpyEnv = (NSNumber *)arguments[@"mpyEnv"];
        [self initMapy:mpyEnv];
    } else if ([@"mPay" isEqualToString:call.method]) {
        NSDictionary *arguments = (NSDictionary *)call.arguments;
        NSString *data = (NSString *)arguments[@"data"];
        NSNumber *channel = (NSNumber *)arguments[@"channel"];
        NSString *withScheme = (NSString *)arguments[@"withScheme"];
        [payHandler pay:data param2:channel param3:result param4:withScheme];
    }else if([@"aliPay" isEqualToString:call.method]){
        NSDictionary *arguments = (NSDictionary *)call.arguments;
        self.callback = result;
        [payHandler processFlutterResult:result];
        [self pay:arguments[@"payInfo"] urlScheme:arguments[@"setIosUrlSchema"]];
    }else if([@"wechatPay" isEqualToString:call.method]){
        [self wechatPay:call result:result];
    }else if([@"wechatPayHongKongWallet" isEqualToString:call.method]){
        [self wechatPayHongKongWallet:call result:result];
    }else if ([@"registerApp" isEqualToString:call.method]) {
        [self registerApp:call result:result];
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
// AliPay
-(void)pay:(NSString*)payInfo urlScheme:(NSString*)urlScheme{
    NSLog(@"urlScheme--->>%@",urlScheme);
    [[AlipaySDK defaultService] payOrder:payInfo
                           dynamicLaunch:false
                              fromScheme:urlScheme
                                callback:^(NSDictionary *resultDic) {
        
        NSLog(@"回调数据%@",resultDic);
        [self onGetResult:resultDic];
    }];
}

- (void)logToFlutterWithDetail:(NSString *) detail {
    if(_channel != nil){
        NSDictionary *result = @{
            @"detail":detail
        };
        [_channel invokeMethod:@"wechatLog" arguments:result];
    }
}
- (void)registerApp:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSNumber* doOnIOS =call.arguments[@"iOS"];
    
    if (![doOnIOS boolValue]) {
        result(@NO);
        return;
    }
    
    NSString *appId = call.arguments[@"appId"];
    if ([WeChatStringUtil isBlank:appId]) {
        result([FlutterError errorWithCode:@"invalid app id" message:@"are you sure your app id is correct ? " details:appId]);
        return;
    }
    
    NSString *universalLink = call.arguments[@"universalLink"];
    
    if ([WeChatStringUtil isBlank:universalLink]) {
        result([FlutterError errorWithCode:@"invalid universal link" message:@"are you sure your universal link is correct ? " details:universalLink]);
        return;
    }
    
    BOOL isWeChatRegistered = [WXApi registerApp:appId universalLink:universalLink];
    
    // 注册失败
    if(!isWeChatRegistered){
        result(@(isWeChatRegistered));
        _isRunning = NO;
        return;
    }
    
    if (_cachedOpenUrlRequest != nil) {
        _cachedOpenUrlRequest();
        _cachedOpenUrlRequest = nil;
    }
    
    // 在调用 `_cachedOpenUrlRequest` 之后设置 `_isRunning` 以确保
    // 由调用 `_cachedOpenUrlRequest` 触发的 `onReq` 将
    // 存储在可获取的`_attemptToResumeMsgFromWxRunnable`中
    // 通过触发 `attemptToResumeMsgFromWx`。
    // 同时这也和Android端的做法不谋而合：
    // 冷启动事件被缓存并通过 `attemptToResumeMsgFromWx` 触发
    _isRunning = isWeChatRegistered;
    
    result(@(isWeChatRegistered));
}

// WechatPay
-(void)wechatPay:(FlutterMethodCall *)call result:(FlutterResult)result {
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
    
    [WXApi sendReq:req completion:^(BOOL done) {
        result(@(done));
    }];
    
}
//    WeChatPay HongKongœ
- (void)wechatPayHongKongWallet:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *partnerId = call.arguments[@"prepayId"];
    
    WXOpenBusinessWebViewReq *req = [[WXOpenBusinessWebViewReq alloc] init];
    req.businessType = 1;
    NSMutableDictionary *queryInfoDic = [NSMutableDictionary dictionary];
    [queryInfoDic setObject:partnerId forKey:@"token"];
    req.queryInfoDic = queryInfoDic;
    [WXApi sendReq:req completion:^(BOOL done) {
        result(@(done));
    }];
    
}


-(void)onGetResult:(NSDictionary*)resultDic{
    NSLog(@"AliPaymentResult---->%@",self.callback);
    //    if(self.callback!=nil){
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    NSString *resultStatus = [resultDic objectForKey:@"resultStatus"];
    NSString *memo = [resultDic objectForKey:@"memo"];
    NSString *result = [resultDic objectForKey:@"result"];
    
    // 向map中添加键值对
    [map setObject:resultStatus forKey:@"resultStatus"];
    [map setObject:result forKey:@"result"];
    [map setObject:memo forKey:@"memo"];
    [map setObject:@"AliPay" forKey:@"type"];
    //        self.callback(map);
    //        self.callback = nil;
    [payHandler processMapValue:map];
    //    }
    
}
-(void)AliPaymentResult:(NSURL *)url /*aNotification:(NSNotification *)aNotification*/ {
    NSLog(@"AliPaymentResult---->%@",url);
    [self handleOpenURL:url];
}


-(BOOL)handleOpenURL:(NSURL*)url{
    if ([url.host isEqualToString:@"safepay"]) {
        NSLog(@"safepay%@",url);
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"支付結果%@",resultDic);
            [self onGetResult:resultDic];
        }];
        
        return YES;
    }
    return NO;
}

- (BOOL)handleWeChatOpenURL:(NSNotification *)aNotification {
    if (handleOpenURLByFluwx) {
        NSString *aURLString = [aNotification userInfo][@"url"];
        NSURL *aURL = [NSURL URLWithString:aURLString];
        return [WXApi handleOpenURL:aURL delegate:self];
    } else {
        return NO;
    }
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application
              openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation {
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:
                (NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application
    continueUserActivity:(NSUserActivity *)userActivity
      restorationHandler:(void (^)(NSArray *_Nonnull))restorationHandler {
    return [WXApi handleOpenUniversalLink:userActivity delegate:self];
}

- (void)onReq:(BaseReq *)req {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSLog(@"onReq---->%@",dictionary);
}

- (void)onResp:(BaseResp *)resp {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:[NSNumber numberWithInt:resp.errCode]
                  forKey:@"errorCode"];
    NSLog(@"onReq---->%@",resp);
    if ([resp isKindOfClass:[PayResp class]]) {
        // 支付
        if (resp.errCode == WXSuccess) {
            PayResp *payResp = (PayResp *)resp;
            [dictionary setValue:payResp.returnKey forKey:@"returnKey"];
        }
        [_channel invokeMethod:@"onPayResp" arguments:dictionary];
    }
}

@end
