//
//  CRTCPCallback.h
//

#import <NetworkExtension/NetworkExtension.h>

@interface CRTCPCallback : NSObject

/// 在 NEPacketTunnelProvider 子类中调用
- (void)handleTcpFlow:(NWProtocolTCP.Metadata *)metadata
                 data:(NSData *)data;

@end