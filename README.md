# 一、项目说明
## AppDelegate.m          // 负责启动代理、加载驱动、安装证书
## SunnyProxy.h/.m        // Sunny 中间件等价封装（基于 NetworkExtension + NEPacketTunnelProvider）
## CRCrypto.h/.m          // CRC32 + 文明重启加解密（AES-128-ECB / 自定义异或）
## CRPacketParser.h/.m    // 粘包、组包、校验、动态计次
# CRTCPCallback.h/.m     // 等价于易语言 TCP 回调使用步骤


# 二、使用步骤
## 新建 NetworkExtension Target → Packet Tunnel Provider。
## 把以上文件拖进去；在 PacketTunnelProvider.m 中调用 CRTCPCallback 相关方法。
## 使用 AppDelegate 中的 startSunnyProxy 启动 VPN。
## 首次运行调用 installCaCert。

