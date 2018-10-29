//
//  BaseStatusController.h
//  MyApp
//
//  Created by huxinguang on 2018/10/29.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "RootViewController.h"
#import "InputToolBar.h"
#import "BaseCell.h"
#import "StatusCell.h"
#import "CommentCell.h"
#import "ReplyCell.h"

@class WindowMaskView;
@interface BaseStatusController : RootViewController<CellDelegate>
@property (nonatomic, strong)InputToolBar *inputToolbar; //多个控制器都有InputToolbar,所以这里将其抽到父类中来
@property (nonatomic, strong)WindowMaskView *maskView;   //用于点击空白处收起键盘
@property (nonatomic, assign)CGFloat currentKeyboardHeight;

- (CGFloat)heightForYYLabelDisplayedString:(NSMutableAttributedString *)attributedString font:(UIFont *)font maxWidth:(CGFloat)width;

-(void)onImgEntryBtnClick;

@end

@interface WindowMaskView: UIControl
@property (nonatomic, assign)CGFloat marginBottom;
@end
