
#import <Foundation/Foundation.h>


@interface WeChatStringUtil : NSObject
+ (BOOL)isBlank:(NSString *)string;

+ (NSString *)nilToEmpty:(NSString *)string;
@end
