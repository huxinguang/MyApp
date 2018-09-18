//
//  ReplyCell.h
//  MyApp
//
//  Created by huxinguang on 2018/9/6.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@interface ReplyCell : UITableViewCell
@property (nonatomic,strong)UIImageView *avatarView;
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)YYLabel *contentLabel;
@property (nonatomic,strong)UILabel *timeLabel;
@property (nonatomic,strong)UIImageView *contentImgView;
@property (nonatomic,strong)UIButton *replyBtn;
@property (nonatomic,strong)UIButton *praiseBtn;
@property (nonatomic,strong)UILabel *praiseCountLabel;
@property (nonatomic,strong)UIView *thinLine;

@property (nonatomic, strong) MASConstraint *contentImgSizeConstraint;
@property (nonatomic, strong) Comment *comment;


- (void)fillCellData:(Comment *)comment;
@end
