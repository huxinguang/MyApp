//
//  RootViewController.h
//  MyApp
//
//  Created by huxinguang on 2018/9/11.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBDefaultPageView.h"
#import "MyApp-Swift.h"//OC 引用Swift类需要导入 "工程名-Swift.h"
#import "CBBarButton.h"
#import "CBTitleView.h"
#import "CBDefaultPageView.h"
#import "UIKit+AFNetworking.h"
#import "InputToolBar.h"
#import "UIViewController+Helper.h"

@class WindowMaskView;

@interface RootViewController : UIViewController<UITextViewDelegate>
@property (nonatomic, strong)CBTitleView *titleView;
@property (nonatomic, strong)CBBarButton *leftBarButton;
@property (nonatomic, strong)CBBarButton *rightBarButton;
@property (nonatomic, assign)BOOL isStatusBarHidden;
@property (nonatomic, strong)CBDefaultPageView *defaultPageView;
@property (nonatomic, assign)CBDefaultPageType defaultPageType;
@property (nonatomic, strong)InputToolBar *inputToolbar; //多个控制器都有InputToolbar,所以这里将其抽到父类中来
@property (nonatomic, strong)WindowMaskView *maskView;  //用于点击空白处收起键盘
@property (nonatomic, assign)CGFloat currentKeyboardHeight;


- (void)configTitleView;

- (void)configLeftBarButtonItem;

- (void)configRightBarButtonItem;

- (void)onLeftBarButtonClick;

- (CGFloat)heightForYYLabelDisplayedString:(NSMutableAttributedString *)attributedString font:(UIFont *)font maxWidth:(CGFloat)width;

-(void)onImgEntryBtnClick;


@end

@interface WindowMaskView: UIControl
@property (nonatomic, assign)CGFloat marginBottom;
@end



