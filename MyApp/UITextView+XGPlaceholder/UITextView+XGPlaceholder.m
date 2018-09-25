//
//  UITextView+XGPlaceholder.m
//  MyApp
//
//  Created by huxinguang on 2018/9/21.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "UITextView+XGPlaceholder.h"

#import <objc/runtime.h>

@interface UITextView ()

@property (nonatomic, readonly) UILabel *xg_placeholderLabel;

@end

@implementation UITextView (XGPlaceholder)

+(void)load{
    [super load];
    method_exchangeImplementations(class_getInstanceMethod(self.class, NSSelectorFromString(@"layoutSubviews")),
                                   class_getInstanceMethod(self.class, @selector(xgPlaceholder_swizzled_layoutSubviews)));
    method_exchangeImplementations(class_getInstanceMethod(self.class, NSSelectorFromString(@"dealloc")),
                                   class_getInstanceMethod(self.class, @selector(xgPlaceholder_swizzled_dealloc)));
    method_exchangeImplementations(class_getInstanceMethod(self.class, NSSelectorFromString(@"setText:")),
                                   class_getInstanceMethod(self.class, @selector(xgPlaceholder_swizzled_setText:)));
}

#pragma mark - swizzled
- (void)xgPlaceholder_swizzled_dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self xgPlaceholder_swizzled_dealloc];
}

- (void)xgPlaceholder_swizzled_layoutSubviews {
    if (self.xg_placeholder) {
        UIEdgeInsets textContainerInset = self.textContainerInset;
        CGFloat lineFragmentPadding = self.textContainer.lineFragmentPadding;
        CGFloat x = lineFragmentPadding + textContainerInset.left + self.layer.borderWidth;
        CGFloat y = textContainerInset.top + self.layer.borderWidth;
        CGFloat width = CGRectGetWidth(self.bounds) - x - textContainerInset.right - 2*self.layer.borderWidth;
        CGFloat height = [self.xg_placeholderLabel sizeThatFits:CGSizeMake(width, 0)].height;
        self.xg_placeholderLabel.frame = CGRectMake(x, y, width, height);
    }
    [self xgPlaceholder_swizzled_layoutSubviews];
}

- (void)xgPlaceholder_swizzled_setText:(NSString *)text{
    [self xgPlaceholder_swizzled_setText:text];
    if (self.xg_placeholder) {
        [self updatePlaceholder];
    }
}
#pragma mark - associated
-(NSString *)xg_placeholder{
    return objc_getAssociatedObject(self, _cmd);
}
-(void)setXg_placeholder:(NSString *)xg_placeholder{
    objc_setAssociatedObject(self, @selector(xg_placeholder), xg_placeholder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updatePlaceholder];
}
-(UIColor *)xg_placeholderColor{
    return self.xg_placeholderLabel.textColor;
}
-(void)setXg_placeholderColor:(UIColor *)xg_placeholderColor{
    self.xg_placeholderLabel.textColor = xg_placeholderColor;
}

#pragma mark - update
- (void)updatePlaceholder{
    if (self.text.length > 0) {
        [self.xg_placeholderLabel removeFromSuperview];
        return;
    }
    self.xg_placeholderLabel.font = self.font?self.font:self.cacutDefaultFont;
    self.xg_placeholderLabel.textAlignment = self.textAlignment;
    self.xg_placeholderLabel.text = self.xg_placeholder;
    [self insertSubview:self.xg_placeholderLabel atIndex:0];
}
#pragma mark - lazzing
-(UILabel *)xg_placeholderLabel{
    UILabel *placeholderLabel = objc_getAssociatedObject(self, @selector(xg_placeholderLabel));
    if (!placeholderLabel) {
        placeholderLabel = [UILabel new];
        placeholderLabel.numberOfLines = 0;
        placeholderLabel.textColor = [UIColor lightGrayColor];
        objc_setAssociatedObject(self, @selector(xg_placeholderLabel), placeholderLabel, OBJC_ASSOCIATION_RETAIN);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlaceholder) name:UITextViewTextDidChangeNotification object:self];
    }
    return placeholderLabel;
}
- (UIFont *)cacutDefaultFont{
    static UIFont *font = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UITextView *textview = [[UITextView alloc] init];
        textview.text = @" ";
        font = textview.font;
    });
    return font;
}
@end
