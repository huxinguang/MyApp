//
//  PicsContainerView.h
//  MyApp
//
//  Created by huxinguang on 2018/9/15.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Media.h"

#define kStatusCellTopMargin 8                                                                                  // cell 顶部灰色留白
#define kStatusCellBottomMargin 2                                                                               // cell 底部部灰色留白
#define kStatusCellPadding 15                                                                                   // cell 内边距
#define kStatusAvatarViewPaddingTop 10                                                                          // 头像 顶部留白
#define kStatusAvatarViewSize CGSizeMake(40, 40)                                                                // 头像 size
#define kStatusNamePaddingLeft 10                                                                               // 名字 左部留白
#define kStatusTextPaddingTop 15                                                                                // 帖子文本 顶部留白
#define kStatusTopicPaddingTop 10                                                                               // 帖子话题 顶部留白
#define kStatusTopicLabelHeight 20                                                                              // 帖子话题 高度
#define kStatusImagePaddingTop 10                                                                               // 帖子图片 顶部留白
#define kStatusCommentBackgroundPaddingTop 10                                                                   // 帖子神评背景 顶部留白
#define kStatusCommentBackgroundPadding 10                                                                      // 帖子神评背景 内边距
#define kStatusCommentHotIconHeight 18                                                                          // 帖子神评icon 高度
#define kStatusCommentHotIconWidth 45                                                                           // 帖子神评icon 宽度
#define kStatusCommentTextPaddingTop 10                                                                         // 帖子神评文本 顶部留白
#define kStatusCommentImagePaddingTop 10                                                                        // 帖子神评图片 顶部留白
#define kStatusCellPaddingPic 4                                                                                 // cell 多张图片中间留白
#define kStatusToolbarButtonPaddingTop 10                                                                       // cell 底部按钮顶部留白
#define kStatusToolbarButtonItemWidth 30                                                                        // cell 底部按钮宽度
#define kStatusToolbarButtonItemHeight 30                                                                       // cell 底部按钮高度
#define kStatusToolbarButtonPaddingBottom 10                                                                    // cell 底部按钮底部留白
#define kStatusToolbarMargin 30                                                                                 // 工具条左右外边距
#define kStatusToolbarButtonDistance (kAppScreenWidth-2*kStatusToolbarMargin-4*kStatusToolbarButtonItemWidth)/3 // 底部按钮距离
#define kStatusNameFont 14                                                                                      // 名字 字体大小
#define kStatusTextFont 16                                                                                      // 帖子文本 字体大小
#define kStatusTopicFont 14                                                                                     // 帖子话题 字体大小
#define kStatusCommentTextFont 14                                                                               // 帖子评论文本 字体大小
#define kStatusPicHW (kAppScreenWidth-2*kStatusCellPadding-2*kStatusCellPaddingPic)/3                           // 帖子方形图片格子大小
#define kStatusCommentPicHW (kAppScreenWidth-2*kStatusCellPadding-2*kStatusCommentBackgroundPadding-2*kStatusCellPaddingPic)/3 // 帖子评论方形图片格子大小

typedef NS_ENUM(NSUInteger, PicsContainerType) {
    PicsContainerTypeStatus,
    PicsContainerTypeStatusComment
};


@interface PicsContainerView : UIView

@property (nonatomic, assign)PicsContainerType type;
@property (nonatomic, strong)NSArray <Media *> *pics;
@property (nonatomic, strong)NSArray <UIButton *> *picViews;

- (instancetype)initWithType:(PicsContainerType)type;

@end
