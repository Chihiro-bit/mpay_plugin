#import <Foundation/Foundation.h>

@interface WeChatPayDelegateHeader : NSObject

@property (strong,nonatomic)NSString *extMsg;

@property (strong,nonatomic)NSString *extData;

+ (instancetype)defaultManager;

- (void)registerWxAPI:(NSString *)appId universalLink:(NSString *)universalLink;
@end
