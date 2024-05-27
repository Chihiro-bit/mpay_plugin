#import "MpayPlugin.h"
#import "MPayHandler.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import "WXApiObject.h"
#import "WechatAuthSDK.h"
#import "WeChatStringUtil.h"
#import "public/WeChatPayDelegateHeader.h"
#import "WXAPIEventHandler.h"

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
WXAPIEventHandler *wxEventHandler;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"mpay_plugin"
                                     binaryMessenger:[registrar messenger]];
    MpayPlugin* instance = [[MpayPlugin alloc] init:channel];
    payHandler = [[MPayHandler alloc] init];
    wxEventHandler = [[WXAPIEventHandler alloc] initWithChannel:channel];
    [registrar addApplicationDelegate:instance];
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
        [wxEventHandler startPaymentWithPayReq:call result:result];
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
    
    _isRunning = isWeChatRegistered;
    result(@(isWeChatRegistered));
}

// WechatPay HongKong
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
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    NSString *resultStatus = [resultDic objectForKey:@"resultStatus"];
    NSString *memo = [resultDic objectForKey:@"memo"];
    NSString *result = [resultDic objectForKey:@"result"];
    
    [map setObject:resultStatus forKey:@"resultStatus"];
    [map setObject:result forKey:@"result"];
    [map setObject:memo forKey:@"memo"];
    [map setObject:@"AliPay" forKey:@"type"];
    [payHandler processMapValue:map];
}

-(void)AliPaymentResult:(NSURL *)url {
    NSLog(@"AliPaymentResult---->%@",url);
    [self handleOpenURL:url];
}

-(BOOL)handleOpenURL:(NSURL*)url{
    if ([url.host isEqualToString:@"safepay"]) {
        NSLog(@"safepay%@",url);
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

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    NSLog(@"支付結果--->%@",url);
    [[OpenSDK sharedInstance] ProcessOrderWithPaymentResult:url];
    [self handleOpenURL:url];
    if (_isRunning) {
        return [WXApi handleOpenURL:url delegate:self];
    } else {
        __weak typeof(self) weakSelf = self;
        _cachedOpenUrlRequest = ^() {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [WXApi handleOpenURL:url delegate:strongSelf];
        };
        return NO;
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nonnull))restorationHandler{
    NSLog(@"application----restorationHandler",@"111");
    return [WXApi handleOpenUniversalLink:userActivity delegate:self];
}

- (void)scene:(UIScene *)scene continueUserActivity:(NSUserActivity *)userActivity  API_AVAILABLE(ios(13.0)){
    NSLog(@"application----scene",@"111");
    [WXApi handleOpenUniversalLink:userActivity delegate:self];
}

- (void)onReq:(BaseReq *)req {
    NSLog(@"onReq---->%@",@"OnReq調用了");
    [wxEventHandler onReq:req];
}

- (void)onResp:(BaseResp *)resp {
    NSLog(@"onResp--->%@",@"onResp調用了");
    [wxEventHandler onResp:resp];
}

@end
