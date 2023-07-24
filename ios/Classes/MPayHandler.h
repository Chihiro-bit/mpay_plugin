#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <OpenSDK/OpenSDK.h>
@interface MPayHandler : NSObject <OpenSDKDelegate>
@property NSMutableString *payChannel;
/**
 @param data 支付信息
 @param channel 支付渠道（ 0->mPay  ,  1-> alipay  ,  2->wechatPay ）
 */
- (void)pay:(NSString *)data param2:(NSNumber *)channel param3:(FlutterResult)result;

// Mpay
- (void) mPay:(NSString *)data;
// AliPay
- (void) aliPay:(NSString *)data;
// WeChatPay
- (void) wechatPay:(NSString *)data;

#pragma mark - SDK Delegate 回調代理
/**
 支付結果成功回調
 @param status 訂單状态
 @param order 訂單信息
 */
-(void)OpenSDK_WithPayStatus:(bool)status WithOrder:(NSDictionary *)order;
/**
 異常報錯
 @param errorInfo 異常信息
 */
-(void)OpenSDK_WithFailed:(NSString *)errorInfo withErrorCode:(NSString *)errorCode;


@end
