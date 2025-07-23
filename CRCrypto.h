//
//  CRCrypto.h
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRCrypto : NSObject

/// 初始化 CRC 表（自动调用）
+ (void)initialize;

/// 计算 CRC32
+ (uint32_t)crc32:(NSData *)data;

/// 文明重启 AES-128-ECB + 异或加密
+ (NSData *)crEncrypt:(NSData *)plain key:(NSData *)key;

/// 文明重启 AES-128-ECB + 异或解密
+ (NSData *)crDecrypt:(NSData *)cipher key:(NSData *)key;

@end

NS_ASSUME_NONNULL_END