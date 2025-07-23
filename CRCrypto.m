//by阿甘科技    


/*
├─AppDelegate.m          // 负责启动代理、加载驱动、安装证书
├─SunnyProxy.h/.m        // Sunny 中间件等价封装（基于 NetworkExtension + NEPacketTunnelProvider）
├─CRCrypto.h/.m          // CRC32 + 文明重启加解密（AES-128-ECB / 自定义异或）
├─CRPacketParser.h/.m    // 粘包、组包、校验、动态计次
└─CRTCPCallback.h/.m     // 等价于易语言 TCP 回调
*/

//这里的逻辑是：
//1. 计算 CRC32
//2. 加密
//3. 解密

#import "CRCrypto.h"
#import <CommonCrypto/CommonCrypto.h> // 补充加密库头文件

static uint32_t crcTable[256];

@implementation CRCrypto // 补全类实现

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        for (uint32_t i = 0; i < 256; i++) {
            uint32_t crc = i;
            for (int j = 0; j < 8; j++) {
                if (crc & 1)
                    crc = (crc >> 1) ^ 0xEDB88320;
                else
                    crc >>= 1;
            }
            crcTable[i] = crc;
        }
    });
}

+ (uint32_t)crc32:(NSData *)data {
    if (data.length == 0) return 0;
    uint32_t crc = 0xFFFFFFFF;
    const uint8_t *bytes = (const uint8_t *)data.bytes;
    for (NSUInteger i = 0; i < data.length; i++) {
        uint32_t index = (crc ^ bytes[i]) & 0xFF;
        crc = (crc >> 8) ^ crcTable[index];
    }
    return ~crc;
}

// 加密：AES-128-ECB + 自定义异或（与易语言 DLL 逻辑一致）
+ (NSData *)crEncrypt:(NSData *)plain key:(NSData *)key {
    // AES-128-ECB
    size_t outLen = plain.length + kCCBlockSizeAES128;
    NSMutableData *out = [NSMutableData dataWithLength:outLen];
    CCCryptorStatus status = CCCrypt(kCCEncrypt,
                                     kCCAlgorithmAES,
                                     kCCOptionECBMode | kCCOptionPKCS7Padding,
                                     key.bytes, kCCKeySizeAES128,
                                     NULL,
                                     plain.bytes, plain.length,
                                     out.mutableBytes, outLen,
                                     &outLen);
    if (status != kCCSuccess) {
        return nil;
    }
    [out setLength:outLen];

    // 额外异或
    uint8_t *bytes = (uint8_t *)out.mutableBytes;
    uint8_t k = ((const uint8_t *)key.bytes)[0];
    for (NSUInteger i = 0; i < out.length; i++) {
        bytes[i] ^= k;
    }
    return out;
}

+ (NSData *)crDecrypt:(NSData *)cipher key:(NSData *)key {
    NSMutableData *tmp = [cipher mutableCopy];
    uint8_t *bytes = (uint8_t *)tmp.mutableBytes;
    uint8_t k = ((const uint8_t *)key.bytes)[0];
    for (NSUInteger i = 0; i < tmp.length; i++) {
        bytes[i] ^= k;
    }

    size_t outLen = tmp.length + kCCBlockSizeAES128;
    NSMutableData *out = [NSMutableData dataWithLength:outLen];
    CCCryptorStatus status = CCCrypt(kCCDecrypt,
                                     kCCAlgorithmAES,
                                     kCCOptionECBMode | kCCOptionPKCS7Padding,
                                     key.bytes, kCCKeySizeAES128,
                                     NULL,
                                     tmp.bytes, tmp.length,
                                     out.mutableBytes, outLen,
                                     &outLen);
    if (status != kCCSuccess) {
        return nil;
    }
    [out setLength:outLen];
    return out;
}

@end // 补全类实现结束