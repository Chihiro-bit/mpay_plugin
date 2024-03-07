//
//  OpenSDK.h
//  OpenSDK
//
//  Created by OpenSDK on 2019/4/1.
//  Copyright © 2019 OpenSDK. All rights reserved.
//



////////////////////////////////////////////////////////
///////////////// OpenSDK ///////////////////
/////////// version:1.0.1 motify:2020.09.15///////////
////////////////////////////////////////////////////////
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum : NSUInteger {
    MPay_SIT,
    MPay_UAT,
    MPay_Prod,
} MPEnvironmentType;

@protocol OpenSDKDelegate <NSObject>
/**
 支付成功回调
 @param status 支付狀態標誌 true成功 false 失敗
 @param order 訂單信息
 */
-(void)OpenSDK_WithPayStatus:(bool)status WithOrder:(NSDictionary *)order;

/**
 支付失败回调
 @param errorInfo 錯誤信息
 @param errorCode 錯誤碼
 */
-(void)OpenSDK_WithFailed:(NSString *)errorInfo withErrorCode:(NSString *)errorCode;

@end

@interface OpenSDK : NSObject

/**
 环境变量
 0：MPay_SIT  1: MPay_UAT  2:MPay_Prod
 */
@property (nonatomic)MPEnvironmentType environmentType;


//MARK:单列
+(instancetype)sharedInstance;


/// 商戶使用(MPay)
/// @param jsonString 商戶簽名后的订單數據
/// @param schema 商戶APP的url schema
/// @param sender 當前控制器
/// @param delegate 實現協議方法的代理對象
-(void)MPayWithJsonString:(NSString *)jsonString withSchema:(NSString *)schema WithSender:(id)sender withDelegate:(id<OpenSDKDelegate>)delegate;

/**
 商户使用(支付宝)
 @param Scheme 商戶APP的url schema
 @param delegate 實現協議方法的代理對象
 */
-(void)AliPayWithJsonString:(NSString *)jsonString withScheme:(NSString *)Scheme with:(id<OpenSDKDelegate>)delegate;

/**
 商户使用(微信)
 @param params  商戶簽名后的訂單數據
 @param Scheme 商戶APP的url schema
 @param delegate 實現協議方法的代理對象
 */
-(void)WeChatPayWithJsonString:(NSString *)params withScheme:(NSString *)Scheme with:(id<OpenSDKDelegate>)delegate;

/**
 完成支付後會 調起AppDelegte 的系統方法 如下：
 application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
 application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
 在上述兩個方法中調用此方法並傳入收到的url
 @param url 支付回調URL
 */
-(void)ProcessOrderWithPaymentResult:(NSURL *)url;

/**
 *  獲取當前SDK版本號
 *  @return 當前SDK版本字符串
 */
- (NSString *)currentVersion;


@end

NS_ASSUME_NONNULL_END
