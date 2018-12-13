//
//  Status.m
//  MyApp
//
//  Created by huxinguang on 2018/8/28.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "Status.h"

@implementation Status

-(id)copyWithZone:(NSZone *)zone{
    Status *sta = [[Status alloc]init];
    sta.status_id = self.status_id;
    sta.user_name = self.user_name;
    sta.head_url = self.head_url;
    sta.user_id = self.user_id;
    sta.create_time = self.create_time;
    sta.content = self.content;
    sta.topic_name = self.topic_name;
    sta.topic_id = self.topic_id;
    sta.medias = self.medias;
    sta.comment_count = self.comment_count;
    sta.repost_count = self.repost_count;
    sta.popularity = self.popularity;
    sta.comment_popularity = self.comment_popularity;
    sta.comment_content = self.comment_content;
    sta.comment_medias = self.comment_medias;
    sta.is_hot = self.is_hot;
    sta.reply_user_id = self.reply_user_id;
    sta.reply_user_name = self.reply_user_name;
    sta.replies_count = self.replies_count;
    sta.textHeight = self.textHeight;
    sta.imageContainerHeight = self.imageContainerHeight;
    sta.commentTextHeight = self.commentTextHeight;
    sta.commentImageContainerHeight = self.commentImageContainerHeight;
    sta.commentBgHeight = self.commentBgHeight;
    sta.height = self.height;
    return sta;
    
}

@end
