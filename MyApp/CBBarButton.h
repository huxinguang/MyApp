//
//  CBBarButton.h
//  MyApp
//
//  Created by huxinguang on 2018/9/11.
//  Copyright © 2018年 huxinguang. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,CBBarButtonType) {
    CBBarButtonTypeBack,
    CBBarButtonTypeImage,
    CBBarButtonTypeText
};

@interface CBBarButtonConfiguration : NSObject

@property (nonatomic, copy)NSString *normalImageName;
@property (nonatomic, copy)NSString *selectedImageName;
@property (nonatomic, copy)NSString *highlightedImageName;
@property (nonatomic, copy)NSString *titleString;
@property (nonatomic, strong)UIFont *titleFont;
@property (nonatomic, strong)UIColor *normalColor;
@property (nonatomic, strong)UIColor *selectedColor;
@property (nonatomic, strong)UIColor *disabledColor;
@property (nonatomic, strong)UIColor *highlightedColor;
@property (nonatomic, assign)CBBarButtonType type;

@end


@interface CBBarButton : UIButton

@property (nonatomic, strong)CBBarButtonConfiguration *configuration;

- (instancetype)initWithConfiguration:(CBBarButtonConfiguration *)config;

@end
