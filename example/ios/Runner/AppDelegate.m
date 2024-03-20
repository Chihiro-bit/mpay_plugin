#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <WXApi.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    NSLog(@"支付結果--->%@",url);
    [[OpenSDK sharedInstance] ProcessOrderWithPaymentResult:url];
    [[MpayPlugin sharedInstance] AliPaymentResult:url];
//    [[MpayPlugin sharedInstance] WeChatPaymentResult:url ]
    return true;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
    NSLog(@"--->",@"微信支付，进入了application continueSserActivty");
    return [WXApi handleOpenUniversalLink:userActivity delegate:self];
}
- (void)scene:(UIApplication *)scene continueUserActivity:(NSUserActivity *)userActivity {
    NSLog(@"--->",@"微信支付，进入了application continueSserActivty");
    [WXApi handleOpenUniversalLink:userActivity delegate:self];
}
@end
