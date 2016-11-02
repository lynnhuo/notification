//
//  AppDelegate.m
//  notification
//
//  Created by 刘炎 on 2016/10/26.
//  Copyright © 2016年 Lynn. All rights reserved.
//
#define JPUSH_appkey @"123"

#import "AppDelegate.h"
#import "JPUSHService.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate ()<UNUserNotificationCenterDelegate,JPUSHRegisterDelegate>
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //系统方法
    /*
    //注册通知
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        //iOS10版本
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                //点击允许
                NSLog(@"注册成功");
            } else {
                //点击允许
                NSLog(@"注册失败");
            }
        }];
    } else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
        //iOS8和9的方法
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
    } else {
        //iOS8以下
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    //注册
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    */
    
    //jpush
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max 
        JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
#endif
    } else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        [JPUSHService registerForRemoteNotificationTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil];
    }
    [JPUSHService setupWithOption:launchOptions appKey:JPUSH_appkey channel:@"Publish channel" apsForProduction:YES];
    
    return YES;
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //获取deviceToken
    NSLog(@"deviceToken是 -- %@",[NSString stringWithFormat:@"%@",deviceToken]);
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //获取deviceToken失败
    NSLog(@"获取deviceToken失败 -- %@",error);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSLog(@"前台 -- willPresentNotification ");
    //iOS 10收到通知
    UNNotificationRequest *request = notification.request;//收到推送的请求
    NSDictionary *userInfo = request.content.userInfo;
    UNNotificationContent *content = request.content;//收到推送的消息内容
    NSNumber *badge = content.badge;//角标
    NSString *body = content.body;//
    UNNotificationSound *sound = content.sound;//
    NSString *subtitle = content.subtitle;//
    NSString *title = content.title;//
    
    if ([request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS 10 前台收到远程通知 ： %@",[self logDic:userInfo]);
    } else {
        NSLog(@"iOS10 前台收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge | UNAuthorizationOptionSound | UNNotificationPresentationOptionAlert);//需要执行这个方法，选择是否提醒用户，有badge、sound、alert三种类型可以设置
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSLog(@" 后台 -- didReceiveNotificationResponse ");
    //iOS 10收到通知
    UNNotificationRequest *request = response.notification.request;//收到推送的请求
    NSDictionary *userInfo = request.content.userInfo;
    UNNotificationContent *content = request.content;//收到推送的消息内容
    NSNumber *badge = content.badge;//角标
    NSString *body = content.body;//
    UNNotificationSound *sound = content.sound;//
    NSString *subtitle = content.subtitle;//
    NSString *title = content.title;//
    
    if ([request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS 10 前台收到远程通知 ： %@",[self logDic:userInfo]);
    } else {
        NSLog(@"iOS10 前台收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge | UNAuthorizationOptionSound | UNNotificationPresentationOptionAlert);//需要执行这个方法，选择是否提醒用户，有badge、sound、alert三种类型可以设置
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"iOS7及以上系统，收到通知：%@",[self logDic:userInfo]);

    //jpush
    [JPUSHService handleRemoteNotification:userInfo];
    
    //系统要求
    completionHandler(UIBackgroundFetchResultNewData);
    
}

#pragma mark jpushDelegate
-(void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    //系统要求
    completionHandler(UNNotificationPresentationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound);
}
-(void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSDictionary *useInfo = response.notification.request.content.userInfo;
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:useInfo];
    }
    //系统要求
    completionHandler(UNNotificationPresentationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 = [[dic description] stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str = [NSPropertyListSerialization propertyListFromData:tempData mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
    return str;
}


@end
