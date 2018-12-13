//
//  NetworkUtil.h
//  MyApp
//
//  Created by huxinguang on 2018/9/28.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkUtil : NSObject

+ (NSString *)getBaseUrl;

+ (NSString *)getStatusListUrl;

+ (NSString *)getStatusCommentsUrl;

+ (NSString *)getCommentRepliesUrl;

@end
