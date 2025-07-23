//by阿甘科技    

//这里的逻辑是：
//1. 将收到的数据喂给包解析器
//2. 包解析器会进行粘包、组包、校验、动态计次
//3. 包解析器会进行解密
//4. 包解析器会进行加密
//5. 包解析器会进行发送

#import "CRPacketParser.h"
#import "CRCrypto.h"
#import "SunnyProxy.h"

@interface CRPacketParser () {
    NSMutableData *_buffer;
    uint32_t _packetSeq;
}
- (void)tryParse;
- (void)handleOnePacket:(NSData *)raw;
@end

@implementation CRPacketParser

+ (instancetype)shared {
    static CRPacketParser *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _buffer = [NSMutableData data];
        _packetSeq = 0;
    }
    return self;
}

- (void)appendTcpStream:(NSData *)data {
    [_buffer appendData:data];
    [self tryParse];
}

- (void)tryParse {
    while (_buffer.length >= 28) {
        uint32_t bodyLen;
        [_buffer getBytes:&bodyLen range:NSMakeRange(24, 4)];
        bodyLen = OSSwapLittleToHostInt32(bodyLen);

        NSUInteger total = bodyLen + 28;
        if (_buffer.length < total) break;

        NSData *oneRaw = [_buffer subdataWithRange:NSMakeRange(0, total)];
        [_buffer replaceBytesInRange:NSMakeRange(0, total) withBytes:NULL length:0];

        [self handleOnePacket:oneRaw];
    }
}

- (void)handleOnePacket:(NSData *)raw {
    uint8_t keyByte;
    [raw getBytes:&keyByte range:NSMakeRange(6, 1)];
    NSData *key = [NSData dataWithBytes:&keyByte length:1];

    NSData *cipher = [raw subdataWithRange:NSMakeRange(28, raw.length - 28)];
    NSData *plain = [CRCrypto crDecrypt:cipher key:key];

    _packetSeq++;
    NSData *reCipher = [CRCrypto crEncrypt:plain
                                         key:[NSData dataWithBytes:&_packetSeq length:4]];

    NSMutableData *out = [NSMutableData data];
    [out appendData:[raw subdataWithRange:NSMakeRange(0, 28)]];
    [out appendData:reCipher];

    [[SunnyProxy shared] sendTcpData:out];
}

@end