//
//  NetworkUtil.m
//  MyApp
//
//  Created by huxinguang on 2018/9/28.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "NetworkUtil.h"

static NSString *const baseReleaseUrl = @"http://478ddfb0.ngrok.io/";
static NSString *const baseDebugUrl = @"http://127.0.0.1:8080/";

@implementation NetworkUtil

+ (NSString *)getBaseUrl{
#if TARGET_IPHONE_SIMULATOR //模拟器
    return baseDebugUrl;
#elif TARGET_OS_IPHONE //真机
    return baseReleaseUrl;
#endif
}

+ (NSString *)getStatusListUrl{
    return [NSString stringWithFormat:@"%@%@",[self getBaseUrl],@"status/getStatusList"];
}

+ (NSString *)getStatusCommentsUrl{
    return [NSString stringWithFormat:@"%@%@",[self getBaseUrl],@"status/getStatusComments"];
}

+ (NSString *)getCommentRepliesUrl{
    return [NSString stringWithFormat:@"%@%@",[self getBaseUrl],@"status/getCommentReplies"];
}


@end
