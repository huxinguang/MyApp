//
//  Comment.h
//  MyApp
//
//  Created by huxinguang on 2018/9/3.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject
@property (nonatomic,assign)NSInteger comment_id;
@property (nonatomic,assign)NSInteger news_id;
@property (nonatomic,assign)NSInteger user_id;
@property (nonatomic,assign)NSInteger reply_user_id;
@property (nonatomic,copy)NSString *user_name;
@property (nonatomic,copy)NSString *reply_user_name;
@property (nonatomic,copy)NSString *head_url;
@property (nonatomic,copy)NSString *content;
@property (nonatomic,assign)NSInteger img_width;
@property (nonatomic,assign)NSInteger img_height;
@property (nonatomic,copy)NSString *img_url;
@property (nonatomic,assign)NSInteger replies_count;
@property (nonatomic,strong)NSArray *latest_replies;
@property (nonatomic,copy)NSString *create_time;
@property (nonatomic,assign)NSInteger is_praised;

@property (nonatomic,assign)CGFloat content_height;
@property (nonatomic,assign)CGFloat image_width;
@property (nonatomic,assign)CGFloat image_height;
@property (nonatomic,assign)CGFloat reply_bgview_height;
@property (nonatomic,assign)CGFloat height;
@end
