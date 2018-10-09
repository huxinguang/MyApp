//
//  NetworkUtil.m
//  MyApp
//
//  Created by huxinguang on 2018/9/28.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "NetworkUtil.h"

static NSString *const baseReleaseUrl = @"http://b23bad1a.ngrok.io/";
static NSString *const baseDebugUrl = @"http://127.0.0.1:8080/";

@implementation NetworkUtil

+ (NSString *)getBaseUrl{
    return baseDebugUrl;
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
