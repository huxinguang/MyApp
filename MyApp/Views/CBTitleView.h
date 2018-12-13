//
//  CBTitleView.h
//  MyApp
//
//  Created by huxinguang on 2018/9/11.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,CBTitleViewStyle) {
    CBTitleViewStyleNormal,
    CBTitleViewStyleSegement
};

@protocol CBTitleViewDelegate<NSObject>
- (void)onTitleClick;
@end

@interface CBTitleView : UIView
@property (nonatomic, weak) id<CBTitleViewDelegate> delegate;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, copy) NSString *titleString;


- (instancetype)initWithFrame:(CGRect)frame style:(CBTitleViewStyle)style;

@end
