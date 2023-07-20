#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <OpenSDK/OpenSDK.h>
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    
    //回调方法，必調
    [[OpenSDK sharedInstance] ProcessOrderWithPaymentResult:url];
    return true;
}

@end
