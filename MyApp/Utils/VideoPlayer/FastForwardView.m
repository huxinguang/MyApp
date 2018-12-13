//
//  FastForwardView.m
//  MyApp
//
//  Created by huxinguang on 2018/10/19.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "FastForwardView.h"

@implementation FastForwardView
- (instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0/256.0f green:0/256.0f blue:0/256.0f alpha:0.8];
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        
        self.stateImageView = [UIImageView new];
        self.stateImageView.image = [UIImage imageNamed:@"progress_icon_r"];
        [self addSubview:self.stateImageView];
        [self.stateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.centerX.mas_equalTo(self);
        }];
        
        self.timeLabel = [UILabel new];
        self.timeLabel.font = [UIFont systemFontOfSize:15.f];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.timeLabel];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-10);
            make.centerX.mas_equalTo(self);
        }];
    }
    return self;
}
@end
