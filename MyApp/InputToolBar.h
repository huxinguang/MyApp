//
//  InputToolBar.h
//  MyApp
//
//  Created by huxinguang on 2018/9/21.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputTextView.h"

#define kInputBarOriginalHeight 48                                                  //工具条初始高度
#define kVoiceEntryIconSize CGSizeMake(26, 26)                                      //声音按钮size
#define kImageEntryIconSize CGSizeMake(26, 26)                                      //图片按钮size
#define kVoiceImageEntryIconMaginLeftRight 20                                       //声音、图片按钮左右边距
#define kTextViewOriginalHeight 36                                                  //输入框初始高度
#define kTextViewMaginTopBottom (kInputBarOriginalHeight-kTextViewOriginalHeight)/2 //输入框顶部、底部边距
#define kInputBarMaxlHeight  90                                                     //输入框最大高度

@interface InputToolBar : UIView
@property (nonatomic, strong)InputTextView *inputView;
@property (nonatomic, strong)UIButton *voiceEntryBtn;
@property (nonatomic, strong)UIButton *imgEntryBtn;
@property (nonatomic, assign)CGFloat inputToolBarHeight;
@end


