//
//  CRPacketParser.h
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRPacketParser : NSObject

+ (instancetype)shared;   // 单例

/// 从 NE 收到 TCP 流后喂进来
- (void)appendTcpStream:(NSData *)data;

@end

NS_ASSUME_NONNULL_END