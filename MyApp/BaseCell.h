//
//  BaseCell.h
//  MyApp
//
//  Created by huxinguang on 2018/9/18.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "PicsContainerView.h"

@interface BaseCell : UITableViewCell
@property (nonatomic,strong) UIImageView *avatarView;                //头像
@property (nonatomic,strong) UILabel *nameLabel;                     //名字
@property (nonatomic,strong) YYLabel *contentLabel;                  //文本
@property (nonatomic,strong) PicsContainerView *picsContainer;       //图片容器
@property (nonatomic,strong) UIButton *likeBtn;                      //喜欢按钮
@property (nonatomic,strong) UIButton *dislikeBtn;                   //不喜欢按钮
@property (nonatomic,strong) UILabel *popularityLabel;               //受欢迎度
@property (nonatomic,strong) UIView *bottomLine;                     //底部灰色分隔线
@property (nonatomic,strong) Status *sts;                            //model

- (void)fillCellData:(Status *)status;

@end
