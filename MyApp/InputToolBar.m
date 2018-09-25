//
//  InputToolBar.m
//  MyApp
//
//  Created by huxinguang on 2018/9/21.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "InputToolBar.h"

@interface InputToolBar()

@end

@implementation InputToolBar
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.inputToolBarHeight = kInputBarOriginalHeight;
        [self buildSubViews];
    }
    return self;
}

- (void)buildSubViews{
    
    UIView *topLine = [UIView new];
    topLine.backgroundColor = [UIColor colorWithRGB:0xE0E0E0];
    [self addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.mas_equalTo(CGFloatFromPixel(1));
    }];
    
    self.voiceEntryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.voiceEntryBtn setImage:[UIImage imageNamed:@"input_micphone"] forState:UIControlStateNormal];
    [self.voiceEntryBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    [self addSubview:self.voiceEntryBtn];
    [self.voiceEntryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).with.offset(-(kInputBarOriginalHeight-kVoiceEntryIconSize.height)/2);
        make.left.equalTo(self.mas_left).with.offset(kVoiceImageEntryIconMaginLeftRight);
        make.size.mas_equalTo(kVoiceEntryIconSize);
    }];
    
    self.imgEntryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.imgEntryBtn setImage:[UIImage imageNamed:@"input_image"] forState:UIControlStateNormal];
    [self.imgEntryBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    [self addSubview:self.imgEntryBtn];
    [self.imgEntryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).with.offset(-(kInputBarOriginalHeight-kImageEntryIconSize.height)/2);
        make.right.equalTo(self.mas_right).with.offset(-kVoiceImageEntryIconMaginLeftRight);
        make.size.mas_equalTo(kImageEntryIconSize);
    }];
    
    self.inputView = [[InputTextView alloc]init];
    self.inputView.pLabel.text = @"皮一下，很开心";
    self.inputView.layer.cornerRadius = kTextViewOriginalHeight/2;
    [self addSubview:self.inputView];
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(kTextViewMaginTopBottom);
        make.bottom.equalTo(self.mas_bottom).with.offset(-kTextViewMaginTopBottom);
        make.left.equalTo(self.voiceEntryBtn.mas_right).with.offset(kVoiceImageEntryIconMaginLeftRight);
        make.right.equalTo(self.imgEntryBtn.mas_left).with.offset(-kVoiceImageEntryIconMaginLeftRight);
    }];
    
    
}

-(void)updateConstraints{
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.inputToolBarHeight > kInputBarMaxlHeight ? kInputBarMaxlHeight : self.inputToolBarHeight);
    }];
    [super updateConstraints];
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
