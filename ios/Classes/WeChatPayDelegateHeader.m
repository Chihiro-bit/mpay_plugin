#import <Foundation/Foundation.h>
#import "public/WeChatPayDelegateHeader.h"
#import "WXApi.h"

@implementation WeChatPayDelegateHeader

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static WeChatPayDelegateHeader *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WeChatPayDelegateHeader alloc] init];
    });
    return instance;
}

- (void) registerWxAPI:(NSString *)appId universalLink:(NSString *)universalLink {
    [WXApi registerApp:appId universalLink:universalLink];
}


@end
