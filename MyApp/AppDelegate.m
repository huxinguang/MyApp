//
//  AppDelegate.m
//  MyApp
//
//  Created by huxinguang on 2018/9/10.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "AppDelegate.h"
#import "TabBarController.h"
#import "HomeViewController.h"
#import "PersonalViewController.h"
#import "MyApp-Swift.h"//OC 引用Swift类需要导入 "工程名-Swift.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 继承CYTabBar的控制器， 你可以自定定义 或 不继承直接使用
    TabBarController * tabbar = [[TabBarController alloc]init];
    
    // 配置
    [CYTabBarConfig shared].selectedTextColor = [UIColor colorWithRGB:0x24A0FC];
    [CYTabBarConfig shared].textColor = [UIColor colorWithRGB:0x999999];
    [CYTabBarConfig shared].backgroundColor = [UIColor whiteColor];
    [CYTabBarConfig shared].selectIndex = 0;
    [CYTabBarConfig shared].centerBtnIndex = 1;
    [CYTabBarConfig shared].HidesBottomBarWhenPushedOption = HidesBottomBarWhenPushedAlone;
    
    // 中间按钮不突出 ， 设为控制器 ,底部无文字  , 微博
    [self style2:tabbar];

    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.window.rootViewController = tabbar;
    [self.window makeKeyAndVisible];
    return YES;
    return YES;
}

- (void)style2:(CYTabBarController *)tabbar {
    CBNavigationController *nav1 = [[CBNavigationController alloc]initWithRootViewController:[HomeViewController new]];
    [tabbar addChildController:nav1 title:@"首页" imageName:@"home_normal" selectedImageName:@"home_selected"];
    CBNavigationController *nav2 = [[CBNavigationController alloc]initWithRootViewController:[PersonalViewController new]];
    [tabbar addChildController:nav2 title:@"我" imageName:@"me_normal" selectedImageName:@"me_selected"];
    [tabbar addCenterController:nil bulge:NO title:nil imageName:@"release" selectedImageName:@"release"];
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


@end
