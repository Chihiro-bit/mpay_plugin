//
//  MPayHandler.m
//  mpay_plugin
//
//  Created by POP on 20/7/2023.
//
#import "MpayPlugin.h"
#import <Foundation/Foundation.h>
#import "MPayHandler.h"

#pragma mark - SDK


@implementation MPayHandler

- (void)pay:(NSString *)data param2:(NSNumber *)channel param3:(FlutterResult)result{
    self.result = result; // 将参数result赋值给实例变量self.result
    NSString *channelString = [channel stringValue];
    if([channelString isEqualToString:@"0"]){
        [self mPay:data];
    }else if([channelString isEqualToString:@"1"]){
        [self aliPay:data];
    }else if([channelString isEqualToString:@"2"]){
        [self wechatPay:data];
    }
}

- (void) mPay:(NSString *)data{
    [[OpenSDK sharedInstance]MPayWithJsonString:data withSchema:@"mpayPlugin" WithSender:self withDelegate:self];
}

- (void) aliPay:(NSString *)data{
    [[OpenSDK sharedInstance]AliPayWithJsonString:data withScheme:@"mpayPlugin" with:self];
}

- (void) wechatPay:(NSString *)data{
    [[OpenSDK sharedInstance]WeChatPayWithJsonString:data withScheme:@"mpayPlugin" with:self];
}

-(void)OpenSDK_WithPayStatus:(bool)status WithOrder:(NSDictionary *)order{
    NSLog(@"Order Info: %@", order);
    NSMutableDictionary *map = [NSMutableDictionary dictionary];

    // 向map中添加键值对
    [map setObject:@"9000" forKey:@"resultStatus"];
    [map setObject:@"支付成功" forKey:@"result"];
    [map setObject:@"支付成功" forKey:@"memo"];
    [map setObject:@"OpeSdk" forKey:@"type"];
    self.result(map);
}

-(void)OpenSDK_WithFailed:(NSString *)errorInfo withErrorCode:(NSString *)errorCode{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    NSLog(@"ErrorInfo: %@", errorInfo);
    NSLog(@"errorCode: %@", errorCode);
    [map setObject:errorCode forKey:@"resultStatus"];
    [map setObject:errorInfo forKey:@"result"];
    [map setObject:errorInfo forKey:@"memo"];
    [map setObject:@"OpeSdk" forKey:@"type"];
    self.result(map);
}

@end
