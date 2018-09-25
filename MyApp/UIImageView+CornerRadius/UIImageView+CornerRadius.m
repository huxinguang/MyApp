//
//  UIImageView+CornerRadius.m
//  MyApp
//
//  Created by huxinguang on 2018/9/21.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "UIImageView+CornerRadius.h"
#import <objc/runtime.h>

const char kProcessedImage;

@interface UIImageView ()

@property (assign, nonatomic) CGFloat xgRadius;
@property (assign, nonatomic) UIRectCorner roundingCorners;
@property (assign, nonatomic) CGFloat xgBorderWidth;
@property (strong, nonatomic) UIColor *xgBorderColor;
@property (assign, nonatomic) BOOL xgHadAddObserver;
@property (assign, nonatomic) BOOL xgIsRounding;

@end


@implementation UIImageView (CornerRadius)
/**
 * @brief init the Rounding UIImageView, no off-screen-rendered
 */
- (instancetype)initWithRoundingRectImageView {
    self = [super init];
    if (self) {
        [self xg_cornerRadiusRoundingRect];
    }
    return self;
}

/**
 * @brief init the UIImageView with cornerRadius, no off-screen-rendered
 */
- (instancetype)initWithCornerRadiusAdvance:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType {
    self = [super init];
    if (self) {
        [self xg_cornerRadiusAdvance:cornerRadius rectCornerType:rectCornerType];
    }
    return self;
}

/**
 * @brief attach border for UIImageView with width & color
 */
- (void)xg_attachBorderWidth:(CGFloat)width color:(UIColor *)color {
    self.xgBorderWidth = width;
    self.xgBorderColor = color;
}

#pragma mark - Kernel
/**
 * @brief clip the cornerRadius with image, UIImageView must be setFrame before, no off-screen-rendered
 */
- (void)xg_cornerRadiusWithImage:(UIImage *)image cornerRadius:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType {
    CGSize size = self.bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cornerRadii = CGSizeMake(cornerRadius, cornerRadius);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    if (nil == currentContext) {
        return;
    }
    UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCornerType cornerRadii:cornerRadii];
    [cornerPath addClip];
    [self.layer renderInContext:currentContext];
    [self drawBorder:cornerPath];
    UIImage *processedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (processedImage) {
        objc_setAssociatedObject(processedImage, &kProcessedImage, @(1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    self.image = processedImage;
}

/**
 * @brief clip the cornerRadius with image, draw the backgroundColor you want, UIImageView must be setFrame before, no off-screen-rendered, no Color Blended layers
 */
- (void)xg_cornerRadiusWithImage:(UIImage *)image cornerRadius:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType backgroundColor:(UIColor *)backgroundColor {
    CGSize size = self.bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cornerRadii = CGSizeMake(cornerRadius, cornerRadius);
    
    UIGraphicsBeginImageContextWithOptions(size, YES, scale);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    if (nil == currentContext) {
        return;
    }
    UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCornerType cornerRadii:cornerRadii];
    UIBezierPath *backgroundRect = [UIBezierPath bezierPathWithRect:self.bounds];
    [backgroundColor setFill];
    [backgroundRect fill];
    [cornerPath addClip];
    [self.layer renderInContext:currentContext];
    [self drawBorder:cornerPath];
    UIImage *processedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (processedImage) {
        objc_setAssociatedObject(processedImage, &kProcessedImage, @(1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    self.image = processedImage;
}

/**
 * @brief set cornerRadius for UIImageView, no off-screen-rendered
 */
- (void)xg_cornerRadiusAdvance:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType {
    self.xgRadius = cornerRadius;
    self.roundingCorners = rectCornerType;
    self.xgIsRounding = NO;
    if (!self.xgHadAddObserver) {
        [[self class] swizzleDealloc];
        [self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
        self.xgHadAddObserver = YES;
    }
    //Xcode 8 xib 删除了控件的Frame信息，需要主动创造
    [self layoutIfNeeded];
}

/**
 * @brief become Rounding UIImageView, no off-screen-rendered
 */
- (void)xg_cornerRadiusRoundingRect {
    self.xgIsRounding = YES;
    if (!self.xgHadAddObserver) {
        [[self class] swizzleDealloc];
        [self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
        self.xgHadAddObserver = YES;
    }
    //Xcode 8 xib 删除了控件的Frame信息，需要主动创造
    [self layoutIfNeeded];
}

#pragma mark - Private
- (void)drawBorder:(UIBezierPath *)path {
    if (0 != self.xgBorderWidth && nil != self.xgBorderColor) {
        [path setLineWidth:2 * self.xgBorderWidth];
        [self.xgBorderColor setStroke];
        [path stroke];
    }
}

- (void)xg_dealloc {
    if (self.xgHadAddObserver) {
        [self removeObserver:self forKeyPath:@"image"];
    }
    [self xg_dealloc];
}

- (void)validateFrame {
    if (self.frame.size.width == 0) {
        [self.class swizzleLayoutSubviews];
    }
}

+ (void)swizzleMethod:(SEL)oneSel anotherMethod:(SEL)anotherSel {
    Method oneMethod = class_getInstanceMethod(self, oneSel);
    Method anotherMethod = class_getInstanceMethod(self, anotherSel);
    method_exchangeImplementations(oneMethod, anotherMethod);
}

+ (void)swizzleDealloc {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:NSSelectorFromString(@"dealloc") anotherMethod:@selector(xg_dealloc)];
    });
}

+ (void)swizzleLayoutSubviews {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(layoutSubviews) anotherMethod:@selector(xg_layoutSubviews)];
    });
}

- (void)xg_layoutSubviews {
    [self xg_layoutSubviews];
    if (self.xgIsRounding) {
        [self xg_cornerRadiusWithImage:self.image cornerRadius:self.frame.size.width/2 rectCornerType:UIRectCornerAllCorners];
    } else if (0 != self.xgRadius && 0 != self.roundingCorners && nil != self.image) {
        [self xg_cornerRadiusWithImage:self.image cornerRadius:self.xgRadius rectCornerType:self.roundingCorners];
    }
}

#pragma mark - KVO for .image
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"image"]) {
        UIImage *newImage = change[NSKeyValueChangeNewKey];
        if ([newImage isMemberOfClass:[NSNull class]]) {
            return;
        } else if ([objc_getAssociatedObject(newImage, &kProcessedImage) intValue] == 1) {
            return;
        }
        [self validateFrame];
        if (self.xgIsRounding) {
            [self xg_cornerRadiusWithImage:newImage cornerRadius:self.frame.size.width/2 rectCornerType:UIRectCornerAllCorners];
        } else if (0 != self.xgRadius && 0 != self.roundingCorners && nil != self.image) {
            [self xg_cornerRadiusWithImage:newImage cornerRadius:self.xgRadius rectCornerType:self.roundingCorners];
        }
    }
}

#pragma mark property
- (CGFloat)xgBorderWidth {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setXgBorderWidth:(CGFloat)xgBorderWidth {
    objc_setAssociatedObject(self, @selector(xgBorderWidth), @(xgBorderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)xgBorderColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setXgBorderColor:(UIColor *)xgBorderColor {
    objc_setAssociatedObject(self, @selector(xgBorderColor), xgBorderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)xgHadAddObserver {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setXgHadAddObserver:(BOOL)xgHadAddObserver {
    objc_setAssociatedObject(self, @selector(xgHadAddObserver), @(xgHadAddObserver), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)xgIsRounding {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setXgIsRounding:(BOOL)xgIsRounding {
    objc_setAssociatedObject(self, @selector(xgIsRounding), @(xgIsRounding), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIRectCorner)roundingCorners {
    return [objc_getAssociatedObject(self, _cmd) unsignedLongValue];
}

- (void)setRoundingCorners:(UIRectCorner)roundingCorners {
    objc_setAssociatedObject(self, @selector(roundingCorners), @(roundingCorners), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)xgRadius {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setXgRadius:(CGFloat)xgRadius {
    objc_setAssociatedObject(self, @selector(xgRadius), @(xgRadius), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end








//xgCornerRadius is available under the MIT license.
//Please visit https://github.com/liuzhiyi1992/xgCornerRadius for details.
