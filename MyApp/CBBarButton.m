//
//  CBBarButton.m
//  MyApp
//
//  Created by huxinguang on 2018/9/11.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "CBBarButton.h"
@implementation CBBarButtonConfiguration

@end

@implementation CBBarButton

- (instancetype)initWithConfiguration:(CBBarButtonConfiguration *)config{
    if (self = [super init]) {
        self.configuration = config;
    }
    return self;
}

- (void)setConfiguration:(CBBarButtonConfiguration *)configuration{
    if (!configuration) {
        return;
    }
    switch (configuration.type) {
        case CBBarButtonTypeBack:
            if (configuration.normalImageName) {
                [self setImage:[UIImage imageNamed:configuration.normalImageName] forState:UIControlStateNormal];
            }
            break;
        case CBBarButtonTypeImage:
            if (configuration.normalImageName) {
                [self setImage:[UIImage imageNamed:configuration.normalImageName] forState:UIControlStateNormal];
            }
            if (configuration.selectedImageName) {
                [self setImage:[UIImage imageNamed:configuration.selectedImageName] forState:UIControlStateSelected];
            }
            if (configuration.highlightedImageName) {
                [self setImage:[UIImage imageNamed:configuration.highlightedImageName] forState:UIControlStateHighlighted];
            }
            break;
        case CBBarButtonTypeText:
            [self setTitle:configuration.titleString ? configuration.titleString: @""forState:UIControlStateNormal];
            self.titleLabel.font = configuration.titleFont;
            if (configuration.normalColor) {
                [self setTitleColor:configuration.normalColor forState:UIControlStateNormal];
            }
            if (configuration.selectedColor) {
                [self setTitleColor:configuration.selectedColor forState:UIControlStateSelected];
            }
            if (configuration.highlightedColor) {
                [self setTitleColor:configuration.highlightedColor forState:UIControlStateHighlighted];
            }
            if (configuration.disabledColor) {
                [self setTitleColor:configuration.disabledColor forState:UIControlStateDisabled];
            }
            break;
            
        default:
            break;
    }
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
