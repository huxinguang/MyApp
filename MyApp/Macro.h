//
//  Macro.h
//  MyApp
//
//  Created by huxinguang on 2018/9/10.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#ifndef Macro_h
#define Macro_h

//=========================================通用宏==============================================
#define kAppScreenWidth ([UIScreen mainScreen].bounds.size.width)//屏幕宽度
#define kAppScreenHeight ([UIScreen mainScreen].bounds.size.height)//屏幕高度
#define IS_Pad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) //判断是否是ipad
#define IS_iPhoneX_Or_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)//判断是否iPhone X/Xs
#define IS_iPhoneXr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !IS_Pad : NO)//判断iPHoneXr
#define IS_iPhoneXs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !IS_Pad : NO)//判断iPhoneXs Max
#define IS_X_Series (IS_iPhoneX_Or_Xs || IS_iPhoneXr || IS_iPhoneXs_Max) //判断是否为带刘海的iPhone

#define kAppStatusBarHeight ((IS_iPhoneX_Or_Xs || IS_iPhoneXr || IS_iPhoneXs_Max) ? 44.f : 20.f) //状态栏高度
#define kAppNavigationBarHeight 44.f //Navigation bar height.
#define kAppTabbarHeight ((IS_iPhoneX_Or_Xs || IS_iPhoneXr || IS_iPhoneXs_Max) ? (49.f+34.f) : 49.f)// Tabbar 高度.
#define kAppTabbarSafeBottomMargin ((IS_iPhoneX_Or_Xs || IS_iPhoneXr || IS_iPhoneXs_Max) ? 34.f : 0.f)// Tabbar 底部安全高度.
#define kAppStatusBarAndNavigationBarHeight ((IS_iPhoneX_Or_Xs || IS_iPhoneXr || IS_iPhoneXs_Max) ? 88.f : 64.f)// 状态栏和导航栏总高度.

//=========================================导航栏(自定义部分)=====================================
#define kAppNavigationTitleViewTitleFontSize 16
#define kAppNavigationTitleViewMaxWidth 220.f
#define kAppNavigationTitleViewHeight 44.f

//===========================================颜色===============================================
#define kAppThemeColor [UIColor colorWithRed:36/255.0 green:160/255.0 blue:252/255.0 alpha:1] //app主题色  0x24A0FC
#define kAppNavigationTopPageTitleColor [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] //一级页面导航栏标题颜色
#define kAppNavigationSubPageTitleColor [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] //二三级页面导航栏标题颜色

#endif /* Macro_h */
