//
//  MediaGroupView.h
//  MyApp
//
//  Created by ibireme on 14/3/9.
//  Copyright (C) 2014 ibireme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaGroupItem : NSObject
@property (nonatomic, strong) UIView *thumbView;  // 缩略图, 用于动画坐标计算
@property (nonatomic, assign) CGSize largeMediaSize;
@property (nonatomic, strong) NSURL *largeMediaURL;
@end

@interface MediaGroupView : UIView
@property (nonatomic, readonly) NSArray<MediaGroupItem *> *groupItems;
@property (nonatomic, readonly) NSInteger currentPage;
@property (nonatomic, assign) BOOL blurEffectBackground;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithGroupItems:(NSArray *)groupItems;

- (void)presentFromImageView:(UIView *)fromView
                 toContainer:(UIView *)container
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion;

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismiss;
@end
