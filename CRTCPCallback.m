//by阿甘科技

//这里的逻辑是：
//1. 判断是否是连接请求
//2. 判断是否是断开连接
//3. 将数据喂给包解析器

#import "CRTCPCallback.h"
#import "CRPacketParser.h"
#import <Network/Network.h>

@implementation CRTCPCallback

- (void)handleTcpFlow:(NWProtocolTCP.Metadata *)metadata
                 data:(NSData *)data {
    if (metadata.isConnect) {
        return;
    }
    if (metadata.isDisconnect) {
        return;
    }
    [[CRPacketParser shared] appendTcpStream:data];
}

@end