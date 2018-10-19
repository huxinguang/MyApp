//
//  Status.h
//  MyApp
//
//  Created by huxinguang on 2018/8/28.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Media.h"

@interface Status : NSObject<NSCopying>
@property (nonatomic,assign) NSInteger status_id;                //帖子、评论、评论回复 的id
@property (nonatomic,copy) NSString *user_name;
@property (nonatomic,copy) NSString *head_url;
@property (nonatomic,assign) NSInteger user_id;
@property (nonatomic,copy) NSString *create_time;
@property (nonatomic,copy) NSString *content;                    //帖子、评论、评论回复 的文本
@property (nonatomic,copy) NSString *topic_name;
@property (nonatomic,assign) int32_t topic_id;
@property (nonatomic,strong) NSArray<Media *> *medias;           //帖子、评论、评论回复 的图片
@property (nonatomic,assign) int32_t comment_count;
@property (nonatomic,assign) int32_t repost_count;
@property (nonatomic,assign) int32_t popularity;                 //帖子、评论、评论回复 的受欢迎度
@property (nonatomic,assign) int32_t comment_popularity;         //帖子神评欢迎度
@property (nonatomic,copy) NSString *comment_content;            //帖子神评文本
@property (nonatomic,strong) NSArray<Media *> *comment_medias;   //帖子神评图片
@property (nonatomic,assign) BOOL is_hot;                        //是否为神评

@property (nonatomic,assign) NSInteger reply_user_id;
@property (nonatomic,copy) NSString *reply_user_name;
@property (nonatomic,strong) NSArray<Status *> *replies;          //评论的回复
@property (nonatomic,assign) int32_t replies_count;               //评论的回复数


@property (nonatomic,assign) CGFloat textHeight;                  //帖子文本高度
@property (nonatomic,assign) CGFloat imageContainerHeight;        //帖子图片容器高度
@property (nonatomic,assign) CGFloat commentTextHeight;           //帖子神评文本高度 (当为帖子详情的Model时表示评论文本高度)
@property (nonatomic,assign) CGFloat commentImageContainerHeight; //帖子神评图片容器高度 (当为帖子详情的Model时表示评论图片容器高度)
@property (nonatomic,assign) CGFloat commentBgHeight;             //神评背景高度 (当为帖子详情的Model时表示评论最热回复的高度)
@property (nonatomic,assign) CGFloat height;                      //帖子总高度 (当为帖子详情的Model时表示评论总高度)

@end
