//
//  UITextView+XGPlaceholder.h
//  MyApp
//
//  Created by huxinguang on 2018/9/21.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (XGPlaceholder)
/**
 *  placeholder
 */
@property (nonatomic, copy) NSString *xg_placeholder;
/**
 *  placeholder颜色
 */
@property (nonatomic, strong) UIColor *xg_placeholderColor;


@end
