//
//  CBOCDataGlobal.h
//  CombOffice
//
//  Created by kunpan on 2017/2/21.
//  Copyright © 2017年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//@interface CBOCDataGlobal : NSObject
//
//@end

// 屏幕的高度，宽度
#define kNavigationBarVerHeight         44.f
#define kSystemStatusBarHeight          20.f

#define kAppScreenHeight CGRectGetHeight([[UIScreen mainScreen] bounds])
#define kAppScreenWidth  CGRectGetWidth([[UIScreen mainScreen] bounds])
#define DPW(size) (size*(kAppScreenWidth)/(720/2))    // (750/2)
#define DPH(size) (size *(kAppScreenHeight/(1280/2))) // (1334/2)

#define DPW_IOS(size) (size*(kAppScreenWidth)/(750/2))
#define DPH_IOS(size) (size *(kAppScreenHeight/(1334/2))) // (1334/2)
//电池栏高度
#define kStatusBarHeight            kSystemStatusBarHeight
//导航栏高度
#define kNavigationBarHeight        kNavigationBarVerHeight
//页面上顶栏的高度
#define kTopBarHeight               (kStatusBarHeight + kNavigationBarHeight)
//页面tab栏的高度
#define kTabBarHeight               49.f

// 所有内部接口加密、解密分隔符
#define kSeparativeSign                            @"=comblive="
// 区分一下哪些接口不需要加密
#define kServerUrlNotSecurity                   @"file_server";//@"fileUpload"

// 加密公钥
#define kPublicKey                                                  @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCUiSOxzkzENGgjn3F86wJL2JRZNZZeMIgK1turJzSU+sURhPREP5RCDA6963U5QTd6BIyEPVr4GgeXiKIxOwen+00yrHhr1Aa3OIy8W9eFc2IPnLjSZbhng+/t5KdKkmlN4Ega+Gynq/gieJ/dzAB6N4cxcNMP1T6v3KHkdrensQIDAQAB"

//static NSString *Server_Addr_Port                 = @"8887";//@"8887";

#define PROD_SERVER_ADDR_PORT                        @"hrapp" //@"hrapp"

#define TEST_SERVER_ADDR_PORT                         @"hrapp"//8887

#if DEBUG
static NSString *Server_Addr_Port                 = TEST_SERVER_ADDR_PORT;
#else
static NSString *Server_Addr_Port                 = PROD_SERVER_ADDR_PORT;

#endif

#define PROD_SERVER_ADDR                               @"http://hrapp.combplus.com"
#define TEST_SERVER_ADDR                                @"http://hrapp.combplus.com"//http://192.168.1.213:8887
//#define TEST_SERVER_ADDR                                @"http://192.168.20.252:8080"

#if DEBUG
static NSString *Server_Addr                 = TEST_SERVER_ADDR;
#else
static NSString *Server_Addr                 =  PROD_SERVER_ADDR;

#endif


// 区分一下哪些接口不需要加密
//#define kServerUrlNotSecurity                   @"fileName"//fileUpload

#define CHECK_VALID_DELEGATE(d, s)                  (d && [d respondsToSelector:s])

#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}


