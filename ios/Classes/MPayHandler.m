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

FlutterResult _result;

//NSMutableString *payChannel = [NSMutableString stringWithString:@"MPay"];
- (void)pay:(NSString *)data param2:(NSNumber *)channel param3:(FlutterResult)result param4:(NSString *) withScheme{
    _result = result; // 将参数result赋值给实例变量self.result
    NSString *channelString = [channel stringValue];
    if([channelString isEqualToString:@"0"]){
        [self mPay:data param2:withScheme];
    }else if([channelString isEqualToString:@"1"]){
        [self aliPay:data param2:withScheme];
    }else if([channelString isEqualToString:@"2"]){
        [self wechatPay:data param2:withScheme];
    }
}

- (void) mPay:(NSString *)data param2:(NSString *) withScheme{
    [[OpenSDK sharedInstance]MPayWithJsonString:data withSchema:withScheme WithSender:self withDelegate:self];
    self.payChannel = [NSMutableString stringWithString:@"MPay"];
}

- (void) aliPay:(NSString *)data  param2:(NSString *) withScheme{
    [[OpenSDK sharedInstance]AliPayWithJsonString:data withScheme:withScheme with:self];
    self.payChannel = [NSMutableString stringWithString:@"AliPay"];
}

- (void) wechatPay:(NSString *)data param2:(NSString *) withScheme{
    [[OpenSDK sharedInstance]WeChatPayWithJsonString:data withScheme:withScheme with:self];
    self.payChannel = [NSMutableString stringWithString:@"WeChat Pay"];
}

- (void) processFlutterResult:(FlutterResult)result{
    _result = result; // 将参数result赋值给实例变量self.result
}
- (void) processMapValue:(NSDictionary *)mapValue{
    _result(mapValue);
}
-(void)OpenSDK_WithPayStatus:(bool)status WithOrder:(NSDictionary *)order{
    NSLog(@"Order Info: %@", order);
    NSMutableDictionary *map = [NSMutableDictionary dictionary];

    // 向map中添加键值对
    [map setObject:@"9000" forKey:@"resultStatus"];
    [map setObject:@"支付成功" forKey:@"result"];
    [map setObject:@"支付成功" forKey:@"memo"];
    [map setObject:self.payChannel forKey:@"type"];
    _result(map);
}

-(void)OpenSDK_WithFailed:(NSString *)errorInfo withErrorCode:(NSString *)errorCode{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    NSLog(@"ErrorInfo: %@", errorInfo);
    NSLog(@"errorCode: %@", errorCode);
    [map setObject:errorCode forKey:@"resultStatus"];
    [map setObject:errorInfo forKey:@"result"];
    [map setObject:errorInfo forKey:@"memo"];
    [map setObject:self.payChannel forKey:@"type"];
    _result(map);
}

@end
