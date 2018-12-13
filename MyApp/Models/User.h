//
//  User.h
//  MyApp
//
//  Created by huxinguang on 2018/9/13.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (nonatomic, assign) NSInteger user_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) short gender; // 1:男 2:女
@property (nonatomic, copy) NSString *desc; //个人简介
@property (nonatomic, assign) int32_t followersCount;//粉丝数
@property (nonatomic, assign) int32_t followingCount;//关注数
@property (nonatomic, assign) int32_t statusesCount; //帖子数
@property (nonatomic, assign) int32_t topicsCount;//话题数
@property (nonatomic, assign) int32_t collectCount;//收藏数
@property (nonatomic, assign) int32_t blockedCount;//屏蔽数
@property (nonatomic, assign) BOOL followMe;//是否关注了我
@property (nonatomic, assign) BOOL following;//我是否关注了
@property (nonatomic, copy) NSString *province;//省
@property (nonatomic, copy) NSString *city;//市
@property (nonatomic, copy) NSString *profileImageURL; //头像 50x50
@property (nonatomic, copy) NSString *avatarLarge;// 头像 180*180
@property (nonatomic, copy) NSString *avatarHD;  // 头像 原图
@property (nonatomic, copy) NSString *coverImage; // 封面图 920x300
@property (nonatomic, copy) NSString *create_time;

@end
