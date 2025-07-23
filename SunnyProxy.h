//
//  SunnyProxy.h
//

#import <NetworkExtension/NetworkExtension.h>

NS_ASSUME_NONNULL_BEGIN

@interface SunnyProxy : NEPacketTunnelProvider

+ (instancetype)shared;

/// 发送处理后的 TCP 数据
- (void)sendTcpData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END