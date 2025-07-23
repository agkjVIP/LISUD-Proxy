//
//  AppDelegate.h
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/// 启动 Sunny 代理
- (void)startSunnyProxy;

/// 安装 CA 证书到系统钥匙串
- (void)installCaCert;

@end