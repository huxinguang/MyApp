//
//  UIView+Layout.h
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TZScaleAnimationToBigger,
    TZScaleAnimationToSmaller,
} TZScaleAnimationType;

@interface UIView (ScaleAnimation)

+ (void)showScaleAnimationWithLayer:(CALayer *)layer type:(TZScaleAnimationType)type;

@end
