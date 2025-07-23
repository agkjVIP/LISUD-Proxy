//by阿甘科技
//这个是启动代理的代码
//这里的逻辑是：
//1. 获取已存在的 NETunnelProviderManager 或新建
//2. 设置代理地址
//3. 设置代理端口
//4. 设置代理协议
//5. 设置代理模式
//6. 启动代理

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>
#import <Security/Security.h>

- (void)startSunnyProxy {
    // 获取已存在的 NETunnelProviderManager 或新建
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> *managers, NSError *error) {
        NETunnelProviderManager *mgr = nil;
        if (managers.count > 0) {
            mgr = managers.firstObject;
        } else {
            mgr = [[NETunnelProviderManager alloc] init];
        }
        mgr.localizedDescription = @"文明重启代理";

        NETunnelProviderProtocol *proto = [[NETunnelProviderProtocol alloc] init];
        proto.serverAddress = @"127.0.0.1"; // 本地回环即可
        proto.providerBundleIdentifier = @"你的NetworkExtension的BundleID"; // 必须设置
        mgr.protocolConfiguration = proto;
        mgr.enabled = YES;

        [mgr saveToPreferencesWithCompletionHandler:^(NSError *error) {
            if (error) { NSLog(@"save error:%@", error); return; }
            [mgr loadFromPreferencesWithCompletionHandler:^(NSError *error) {
                if (error) { NSLog(@"load error:%@", error); return; }
                NSError *startError = nil;
                [mgr.connection startVPNTunnelWithOptions:nil error:&startError];
                if (startError) {
                    NSLog(@"start error:%@", startError);
                } else {
                    NSLog(@"VPN 启动成功");
                }
            }];
        }];
    }];
}

// 首次运行调用
- (void)installCaCert {
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"sunny_ca" ofType:@"der"];
    NSData *der = [NSData dataWithContentsOfFile:certPath];
    if (!der) {
        NSLog(@"证书文件未找到");
        return;
    }
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)der);
    if (!cert) {
        NSLog(@"证书创建失败");
        return;
    }
    // 添加到用户信任设置
    OSStatus status = SecTrustSettingsSetTrustSettings(cert, kSecTrustSettingsDomainUser, NULL);
    if (status != errSecSuccess) {
        NSLog(@"证书信任设置失败: %d", (int)status);
    } else {
        NSLog(@"证书已安装并信任");
    }
    CFRelease(cert);
}