//
//  CommentCell.h
//  MyApp
//
//  Created by huxinguang on 2018/9/3.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCell.h"

@interface CommentCell : BaseCell

@property (nonatomic,strong) UILabel *timeLabel;    //时间
@property (nonatomic,strong) UIView *replyBgView;   //回复背景
@property (nonatomic,strong) YYLabel *replyLabel1;  //回复1
@property (nonatomic,strong) YYLabel *replyLabel2;  //回复2
@property (nonatomic,strong) YYLabel *replyLabel3;  //查看xx条回复

@end
