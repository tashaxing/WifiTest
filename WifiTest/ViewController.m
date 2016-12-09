//
//  ViewController.m
//  WifiTest
//
//  Created by yxhe on 16/12/9.
//  Copyright © 2016年 tashaxing. All rights reserved.
//

// ---- 调用系统服务 wifi 打电话 短信 ---- //

//#import <LSApplicationWorkspace.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <arpa/inet.h>
#import <netinet/in.h>
#import <ifaddrs.h>
#import "getgateway.h"

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

// 跳转到各种系统页面，打电话，发短信，设置页面 http://blog.csdn.net/imanapple/article/details/50161297
- (IBAction)openBtn:(id)sender
{
    // 打电话
//    NSURL *url = [NSURL URLWithString:@"tel:10010"];
    
    // 发短信
//    NSURL *url = [NSURL URLWithString:@"sms:10010"];
    
    // wallet
//    NSURL *url = [NSURL URLWithString:@"shoebox://"];
    
    // 也可以用浏览器承载打开
//    UIWebView *callWebview =[[UIWebView alloc] init];
//    [callWebview loadRequest:[NSURLRequest requestWithURL:url]];
    
//    //记得添加到view上
//    [self.view addSubview:callWebview];
    
    
    // 打开系统设置页面
    NSURL *url = [NSURL URLWithString:@"Prefs:root=WIFI"];
    
//    if ([[UIApplication sharedApplication] canOpenURL:url])
//    {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]; // 可以打开自己的控制
//        [[UIApplication sharedApplication] openURL:url];
//    }
    
    
    // 用这种私有方法吧
//    NSURL *url=[NSURL URLWithString:@"Prefs:root=Privacy&path=LOCATION"];
    Class LSApplicationWorkspace = NSClassFromString(@"LSApplicationWorkspace");
    [[LSApplicationWorkspace performSelector:@selector(defaultWorkspace)] performSelector:@selector(openSensitiveURL:withOptions:)
                                                                               withObject:url withObject:nil];
}

// 获取wifi各种信息
- (IBAction)wifiInfoBtn:(id)sender
{
//    NSLog(@"wifi info: %@", [self getCurrentWifiInfo]);
//    NSLog(@"router ip: %@", [self getGatewayIpForCurrentRouter]);
//    NSLog(@"local ip: %@", [self getLocalInfoForCurrentWiFi]);
    
    NSLog(@"signal strength: %d", [self getSignalStrength]);
    NSLog(@"network type: %@", [self getNetworkType]);
}


#pragma mark - wifi相关

// 获取当前所连接的wifi信息
- (NSDictionary *)getCurrentWifiInfo
{
    NSArray *ifs = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
    if (!ifs)
    {
        return nil;
    }
    
    NSDictionary *info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) { break; }
    }
    
    return info; // Bssid是物理地址，其中ssid字段是wifi名字
}

// 网关IP
- (NSString *)getGatewayIpForCurrentRouter {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        //*/
        while(temp_addr != NULL) {
            /*/
             int i=255;
             while((i--)>0)
             //*/
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String //ifa_addr
                    //ifa->ifa_dstaddr is the broadcast address, which explains the "255's"
                    //                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];
                    
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                    //routerIP----192.168.1.255 广播地址
                    NSLog(@"broadcast address--%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)]);
                    //--192.168.1.106 本机地址
                    NSLog(@"local device ip--%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]);
                    //--255.255.255.0 子网掩码地址
                    NSLog(@"netmask--%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)]);
                    //--en0 端口地址
                    NSLog(@"interface--%@",[NSString stringWithUTF8String:temp_addr->ifa_name]);
                    
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    in_addr_t i = inet_addr([address cStringUsingEncoding:NSUTF8StringEncoding]);
    in_addr_t* x = &i;
    
    unsigned char *s = getdefaultgateway(x);
    NSString *ip=[NSString stringWithFormat:@"%d.%d.%d.%d",s[0],s[1],s[2],s[3]];
    free(s);
    return ip;
}

// 获取网卡Ip
- (NSMutableDictionary *)getLocalInfoForCurrentWiFi {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        //*/
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    //----192.168.1.255 广播地址
                    NSString *broadcast = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];
                    if (broadcast) {
                        [dict setObject:broadcast forKey:@"broadcast"];
                    }
                    NSLog(@"broadcast address--%@",broadcast);
                    //--192.168.1.106 本机地址
                    NSString *localIp = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    if (localIp) {
                        [dict setObject:localIp forKey:@"localIp"];
                    }
                    NSLog(@"local device ip--%@",localIp);
                    //--255.255.255.0 子网掩码地址
                    NSString *netmask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                    if (netmask) {
                        [dict setObject:netmask forKey:@"netmask"];
                    }
                    NSLog(@"netmask--%@",netmask);
                    //--en0 端口地址
                    NSString *interface = [NSString stringWithUTF8String:temp_addr->ifa_name];
                    if (interface) {
                        [dict setObject:interface forKey:@"interface"];
                    }
                    NSLog(@"interface--%@",interface);
                    return dict;
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    return dict;
}

// 获取信号强度
- (int)getSignalStrength
{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSString *dataNetworkItemView = nil;
    
    for (id subview in subviews)
    {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]])
        {
            dataNetworkItemView = subview;
            break;
        }
    }
    
    int signalStrength = [[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] intValue];
    
    return signalStrength;
}

// 获取网络类型
- (NSString *)getNetworkType
{
    NSString *type = [[NSString alloc] init];
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    for (id subview in subviews)
    {
        if ([subview isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")])
        {
            int networkType = [[subview valueForKeyPath:@"dataNetworkType"] intValue];
            switch (networkType)
            {
                case 0:
                    type = @"NONE";
                    break;
                case 1:
                    type = @"2G";
                    break;
                case 2:
                    type = @"3G";
                    break;
                case 3:
                    type = @"4G";
                    break;
                case 5:
                {
                    type = @"WIFI";
                }
                    break;
                default:
                    break;
            }
        }
    }
    
    return type;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
