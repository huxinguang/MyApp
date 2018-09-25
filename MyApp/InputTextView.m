//
//  InputTextView.m
//  MyApp
//
//  Created by huxinguang on 2018/9/25.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "InputTextView.h"

#define InputTextViewFontSize 15
#define TextContainerInsetLeftRight 7

@interface InputTextView()

@end

@implementation InputTextView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.font = [UIFont systemFontOfSize:InputTextViewFontSize];
        self.layer.borderWidth = CGFloatFromPixel(1);
        self.layer.borderColor = [UIColor colorWithRGB:0xBFBFBF].CGColor;
        self.tintColor = kAppThemeColor;
        
        //光标距离输入框左边的距离是 textContainerInset.left + textContainer.lineFragmentPadding + layer.borderWidth
        UIEdgeInsets textContainerInset = self.textContainerInset;
        textContainerInset.left = TextContainerInsetLeftRight;
        textContainerInset.right = TextContainerInsetLeftRight;
        self.textContainerInset = textContainerInset;
        
        self.pLabel = [UILabel new];
        self.pLabel.textAlignment = NSTextAlignmentLeft;
        self.pLabel.font = [UIFont systemFontOfSize:InputTextViewFontSize];
        self.pLabel.textColor = [UIColor redColor];
        [self addSubview:self.pLabel];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePLabel) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}

- (void)updatePLabel{
    if (self.text.length > 0) {
        self.pLabel.hidden = YES;
    }else{
        self.pLabel.hidden = NO;
    }
}

- (void)setText:(NSString *)text{
    if (text.length > 0) {
        self.pLabel.hidden = YES;
    }else{
        self.pLabel.hidden = NO;
    }
}

- (void)layoutSubviews{
    UIEdgeInsets textContainerInset = self.textContainerInset;//textContainerInset系统默认是UIEdgeInsetsMake(8, 0, 8, 0)
    CGFloat lineFragmentPadding = self.textContainer.lineFragmentPadding;//lineFragmentPadding 默认是5
    CGFloat x = lineFragmentPadding + textContainerInset.left + self.layer.borderWidth;
    CGFloat y = textContainerInset.top + self.layer.borderWidth;
    CGFloat width = CGRectGetWidth(self.bounds) - x - textContainerInset.right - 2*self.layer.borderWidth;
    CGFloat height = [self.pLabel sizeThatFits:CGSizeMake(width, 0)].height;
    self.pLabel.frame = CGRectMake(x, y, width, height);
    [super layoutSubviews];

}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
