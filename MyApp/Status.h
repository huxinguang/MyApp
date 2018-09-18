//
//  Status.h
//  MyApp
//
//  Created by huxinguang on 2018/8/28.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Media.h"

@interface Status : NSObject
@property (nonatomic,assign)NSInteger status_id;
@property (nonatomic,copy)NSString *user_name;
@property (nonatomic,copy)NSString *head_url;
@property (nonatomic,assign)NSInteger user_id;
@property (nonatomic,copy)NSString *create_time;
@property (nonatomic,copy)NSString *content;
@property (nonatomic,copy)NSString *topic_name;
@property (nonatomic,copy)NSString *topic_id;
@property (nonatomic,strong)NSArray<Media *> *medias;
@property (nonatomic,assign)int32_t comment_count;
@property (nonatomic,assign)int32_t popularity;
@property (nonatomic,assign)int32_t comment_popularity;
@property (nonatomic,copy)NSString *comment_content;
@property (nonatomic,strong)NSArray<Media *> *comment_medias;


@property (nonatomic,assign)CGFloat textHeight;                  //帖子文本高度
@property (nonatomic,assign)CGFloat imageContainerHeight;        //帖子图片容器高度
@property (nonatomic,assign)CGFloat commentTextHeight;           //帖子神评文本高度
@property (nonatomic,assign)CGFloat commentImageContainerHeight; //帖子神评图片容器高度
@property (nonatomic,assign)CGFloat commentBgHeight;             //神评背景高度
@property (nonatomic,assign)CGFloat height;                      //帖子总高度

@end
