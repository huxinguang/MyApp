//
//  StatusCell.h
//  MyApp
//
//  Created by huxinguang on 2018/8/28.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "HotCommentIcon.h"
#import "PicsContainerView.h"

@interface StatusCell : UITableViewCell
@property (nonatomic,strong)UIImageView *avatarView;                //头像
@property (nonatomic,strong)UILabel *nameLabel;                     //名字
@property (nonatomic,strong)UILabel *contentLabel;                  //帖子文本
@property (nonatomic,strong)UILabel *topicLabel;                    //话题
@property (nonatomic,strong)PicsContainerView *picsContainer;       //帖子图片容器
@property (nonatomic,strong)UIView *commentBgView;                  //神评背景
@property (nonatomic,strong)HotCommentIcon *commentTagIcon;         //神评标识
@property (nonatomic,strong)UIButton *commentLikeBtn;               //神评赞
@property (nonatomic,strong)UILabel *commentLikeCountLabel;         //神评赞踩数
@property (nonatomic,strong)UIButton *commentDislikeBtn;            //神评踩
@property (nonatomic,strong)UILabel *commentTextLabel;              //神评文本
@property (nonatomic,strong)PicsContainerView *commentPicsContainer;//神评图片容器
@property (nonatomic,strong)UIButton *shareBtn;                     //分享按钮
@property (nonatomic,strong)UIButton *commentBtn;                   //评论按钮
@property (nonatomic,strong)UIButton *likeBtn;                      //赞按钮
@property (nonatomic,strong)UIButton *dislikeBtn;                   //踩按钮
@property (nonatomic,strong)UILabel *shareLabel;                    //分享数
@property (nonatomic,strong)UILabel *commentLabel;                  //评论数
@property (nonatomic,strong)UILabel *likeLabel;                     //赞踩数
@property (nonatomic,strong)Status *sts;

- (void)fillCellData:(Status *)status;


@end
