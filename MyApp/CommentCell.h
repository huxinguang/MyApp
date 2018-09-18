//
//  CommentCell.h
//  MyApp
//
//  Created by huxinguang on 2018/9/3.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@protocol CommentCellDelegate <NSObject>

- (void)clickMoreReplyBtnAction:(int)comment_id;
- (void)clickReplyNameAction:(int)user_id;

@end

@interface CommentCell : UITableViewCell

@property (nonatomic,strong)UIImageView *avatarView;
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UILabel *contentLabel;
@property (nonatomic,strong)UILabel *timeLabel;
@property (nonatomic,strong)FLAnimatedImageView *contentImgView;
@property (nonatomic,strong)UIButton *replyBtn;
@property (nonatomic,strong)UIButton *praiseBtn;
@property (nonatomic,strong)UILabel *praiseCountLabel;
@property (nonatomic,strong)UIView *replyBgView;
@property (nonatomic,strong)YYLabel *replayLabel1;
@property (nonatomic,strong)YYLabel *replayLabel2;
@property (nonatomic,strong)YYLabel *replayLabel3;
@property (nonatomic,strong)UIView *thinLine;

@property (nonatomic, strong) MASConstraint *contentImgSizeConstraint;
@property (nonatomic, strong) MASConstraint *replyBgViewHeightConstraint;
@property (nonatomic, strong) MASConstraint *replyLabel1BottomConstraint;
@property (nonatomic, strong) MASConstraint *replyLabel2BottomConstraint;
@property (nonatomic, strong) MASConstraint *replyLabel3BottomConstraint;


@property (nonatomic, strong) Comment *comment;
@property (nonatomic, weak) id<CommentCellDelegate> delegate;


- (void)fillCellData:(Comment *)comment;




@end
