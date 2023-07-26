#import <Flutter/Flutter.h>
#import <OpenSDK/OpenSDK.h>
@interface MpayPlugin : NSObject<FlutterPlugin>

+ (instancetype)sharedInstance; // 單例方法

- (void)AliPaymentResult:(NSURL *)url;

@end
