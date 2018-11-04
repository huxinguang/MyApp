//
//  MediaCell.h
//  MyApp
//
//  Created by huxinguang on 2018/10/30.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayer.h"

@class MediaItem;

@interface MediaCell : UICollectionViewCell
@property (nonatomic, strong) MediaItem *item;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *mediaContainerView;//用于动画
@property (nonatomic, strong) YYAnimatedImageView *imageView;
@property (nonatomic, strong) VideoPlayer *player;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) CAShapeLayer *progressLayer;

- (void)resizeSubviewSize;

@end

