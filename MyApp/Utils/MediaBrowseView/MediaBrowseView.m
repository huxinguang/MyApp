//
//  MediaBrowseView.m
//  MyApp
//
//  Created by huxinguang on 2018/10/30.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "MediaBrowseView.h"
#import "MediaCell.h"

@interface MediaBrowseView()<UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate,UIScrollViewDelegate,VideoPlayerDelegate>
@property (nonatomic, weak) UIView *fromView;
@property (nonatomic, weak) UIView *toContainerView;
@property (nonatomic, strong) UIImageView *blackBackground;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pager;
@property (nonatomic, assign) NSInteger fromItemIndex;
@property (nonatomic, assign) BOOL isPresented;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) CGPoint panGestureBeginPoint;
@property (nonatomic, assign) BOOL fromNavigationBarHidden;

@end

@implementation MediaBrowseView

- (instancetype)initWithItems:(NSArray<MediaItem *> *)items{
    self = [super init];
    if (items.count == 0) return nil;
    self.backgroundColor = [UIColor clearColor];
    self.frame = [UIScreen mainScreen].bounds;
    self.clipsToBounds = YES;
    
    _items = [items copy];
    
    [self setupSubViews];
    [self addGesture];
    
    return self;
}

- (void)setupSubViews{
    [self addSubview:self.blackBackground];
    [self addSubview:self.collectionView];
    [self addSubview:self.pager];
}

#pragma mark - Getter & Setter

- (UIImageView *)blackBackground{
    if (!_blackBackground) {
        _blackBackground = UIImageView.new;
        _blackBackground.frame = self.bounds;
        _blackBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _blackBackground;
}

-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = [UIScreen mainScreen].bounds.size;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[MediaCell class] forCellWithReuseIdentifier:NSStringFromClass([MediaCell class])];
    }
    return _collectionView;
}

- (UIPageControl *)pager{
    if (!_pager) {
        _pager = [[UIPageControl alloc] init];
        _pager.hidesForSinglePage = YES;
        _pager.userInteractionEnabled = NO;
        _pager.width = self.width - 36;
        _pager.height = 10;
        _pager.center = CGPointMake(self.width / 2, self.height - (IS_X_Series ? kAppTabbarSafeBottomMargin : 18));
        _pager.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    return _pager;
}

- (NSInteger)currentPage{
    NSInteger page = self.collectionView.contentOffset.x / self.collectionView.width + 0.5;
    if (page >= _items.count) page = (NSInteger)_items.count - 1;
    if (page < 0) page = 0;
    return page;
}

#pragma mark - Gesture

- (void)addGesture{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap)];
    singleTap.delegate = self;
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
    doubleTap.delegate = self;
    doubleTap.numberOfTapsRequired = 2;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:doubleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress)];
    longPress.delegate = self;
    [self addGestureRecognizer:longPress];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    [self addGestureRecognizer:pan];
    _panGesture = pan;
}


- (void)onSingleTap{
    if ([self currentCell].item.mediaType == MediaItemTypeVideo) {
        return;
    }
    [self dismissAnimated:YES completion:nil];
}

- (void)onDoubleTap:(UITapGestureRecognizer *)gesture{
    if (!_isPresented) return;
    MediaCell *cell = [self currentCell];
    if (cell.item.mediaType == MediaItemTypeVideo) {
        return;
    }
    if (cell.scrollView.zoomScale > 1) {
        [cell.scrollView setZoomScale:1 animated:YES];
    } else {
        CGPoint touchPoint = [gesture locationInView:cell.imageView];
        CGFloat newZoomScale = cell.scrollView.maximumZoomScale;
        CGFloat xsize = self.width / newZoomScale;
        CGFloat ysize = self.height / newZoomScale;
        [cell.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)onLongPress{
    
}

- (void)onPan:(UIPanGestureRecognizer *)gesture{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            if (_isPresented) {
                _panGestureBeginPoint = [gesture locationInView:self];
            } else {
                _panGestureBeginPoint = CGPointZero;
            }
        } break;
        case UIGestureRecognizerStateChanged: {
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            CGPoint p = [gesture locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            self.collectionView.top = deltaY;

            CGFloat alphaDelta = 160;
            CGFloat alpha = (alphaDelta - fabs(deltaY) + 50) / alphaDelta;
            alpha = YY_CLAMP(alpha, 0, 1);
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
                self.blackBackground.alpha = alpha;
                self.pager.alpha = alpha;
            } completion:nil];

        } break;
        case UIGestureRecognizerStateEnded: {
            if (self.panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            CGPoint v = [gesture velocityInView:self];
            CGPoint p = [gesture locationInView:self];
            CGFloat deltaY = p.y - self.panGestureBeginPoint.y;

            if (fabs(v.y) > 1000 || fabs(deltaY) > 120) {
                [self cancelAllImageLoad];
                self.isPresented = NO;
                [[UIApplication sharedApplication] setStatusBarHidden:self.fromNavigationBarHidden withAnimation:UIStatusBarAnimationFade];

                BOOL moveToTop = (v.y < - 50 || (v.y < 50 && deltaY < 0));
                CGFloat vy = fabs(v.y);
                if (vy < 1) vy = 1;
                CGFloat duration = (moveToTop ? self.collectionView.bottom : self.height - self.collectionView.top) / vy;
                duration *= 0.8;
                duration = YY_CLAMP(duration, 0.05, 0.3);
                
                NSInteger currentPage = self.currentPage;
                MediaItem *item = self.items[currentPage];
                UIView *fromView = nil;
                if (self.fromItemIndex == currentPage) {
                    fromView = self.fromView;
                } else {
                    fromView = item.thumbView;
                    self.fromView.alpha = 1.0;
                }

                [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    self.blackBackground.alpha = 0;
                    self.pager.alpha = 0;
                    fromView.alpha = 1.0;
                    if (moveToTop) {
                        self.collectionView.bottom = 0;
                    } else {
                        self.collectionView.top = self.height;
                    }
                } completion:^(BOOL finished) {
                    [self removeFromSuperview];
                }];

            } else {
                [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:v.y / 1000 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    self.collectionView.top = 0;
                    self.blackBackground.alpha = 1;
                    self.pager.alpha = 1;
                } completion:^(BOOL finished) {

                }];
            }

        } break;
        case UIGestureRecognizerStateCancelled : {
            self.collectionView.top = 0;
            self.blackBackground.alpha = 1;
        }
        default:break;
    }
}

- (void)presentFromImageView:(UIView *)fromView
                 toContainer:(UIView *)toContainer
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion {
    if (!toContainer) return;
    
    _fromView = fromView;
    _fromView.alpha = 0;
    _toContainerView = toContainer;
    
    NSInteger page = -1;
    for (NSUInteger i = 0; i < self.items.count; i++) {
        if (fromView == ((MediaItem *)self.items[i]).thumbView) {
            page = (int)i;
            break;
        }
    }
    if (page == -1) page = 0;
    _fromItemIndex = page;
    
    self.blackBackground.image = [UIImage imageWithColor:[UIColor blackColor]];

    self.size = _toContainerView.size;
    self.blackBackground.alpha = 0;
    self.pager.alpha = 0;
    self.pager.numberOfPages = self.items.count;
    self.pager.currentPage = page;
    [_toContainerView addSubview:self];

    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.pager.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
    [self.collectionView layoutIfNeeded];//关键，否则下面获取的cell是nil
    
    [UIView setAnimationsEnabled:YES];
    _fromNavigationBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
    
    MediaCell *cell = [self currentCell];
    MediaItem *item = self.items[self.currentPage];
    
    if (!item.thumbClippedToTop) {
        NSString *imageKey = [[YYWebImageManager sharedManager] cacheKeyForURL:item.largeMediaURL];
        if ([[YYWebImageManager sharedManager].cache getImageForKey:imageKey withType:YYImageCacheTypeMemory]) {
            cell.item = item;
        }
    }
    
    if (item.thumbClippedToTop) {
        CGRect fromFrame = [_fromView convertRect:_fromView.bounds toView:cell];
        CGRect originFrame = cell.mediaContainerView.frame;
        CGFloat scale = fromFrame.size.width / cell.mediaContainerView.width;
        
        cell.mediaContainerView.centerX = CGRectGetMidX(fromFrame);
        cell.mediaContainerView.height = fromFrame.size.height / scale;
        cell.mediaContainerView.layer.transformScale = scale;
        cell.mediaContainerView.centerY = CGRectGetMidY(fromFrame);
        
        float oneTime = animated ? 0.25 : 0;
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            self.blackBackground.alpha = 1;
        }completion:NULL];
        
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            cell.mediaContainerView.layer.transformScale = 1;
            cell.mediaContainerView.frame = originFrame;
            self.pager.alpha = 1;
        }completion:^(BOOL finished) {
            self.isPresented = YES;
            self.collectionView.userInteractionEnabled = YES;
            [self hidePager];
            //如果打开的是视频，则创建播放器并播放
            if (item.mediaType == MediaItemTypeVideo) {
                cell.player.frame = cell.imageView.bounds;
                cell.player.delegate = self;
                [cell.mediaContainerView addSubview:cell.player];
                [cell.player play];
            }
            if (completion) completion();
        }];
        
    } else {
        CGRect fromFrame = [_fromView convertRect:_fromView.bounds toView:cell.mediaContainerView];
        
        cell.mediaContainerView.clipsToBounds = NO;
        cell.imageView.frame = fromFrame;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        float oneTime = animated ? 0.18 : 0;
        [UIView animateWithDuration:oneTime*2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            self.blackBackground.alpha = 1;
        }completion:NULL];
        
        self.collectionView.userInteractionEnabled = NO;
        [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            cell.imageView.frame = cell.mediaContainerView.bounds;
            cell.imageView.layer.transformScale = 1.01;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:oneTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
                cell.imageView.layer.transformScale = 1.0;
                self.pager.alpha = 1;
            }completion:^(BOOL finished) {
                cell.mediaContainerView.clipsToBounds = YES;
                self.isPresented = YES;
                self.collectionView.userInteractionEnabled = YES;
                [self hidePager];
                //如果打开的是视频，则创建播放器并播放
                if (item.mediaType == MediaItemTypeVideo) {
                    cell.player.frame = cell.imageView.bounds;
                    cell.player.delegate = self;
                    [cell.mediaContainerView addSubview:cell.player];
                    [cell.player layoutIfNeeded];
                    [cell.player play];
                }
                if (completion) completion();
            }];
        }];
    }
}


- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [UIView setAnimationsEnabled:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:self.fromNavigationBarHidden withAnimation:animated ? UIStatusBarAnimationFade : UIStatusBarAnimationNone];
    NSInteger currentPage = self.currentPage;
    MediaCell *cell = [self currentCell];
    MediaItem *item = self.items[currentPage];
    
    UIView *fromView = nil;
    if (self.fromItemIndex == currentPage) {
        fromView = self.fromView;
    } else {
        fromView = item.thumbView;
        fromView.alpha = 0;
        self.fromView.alpha = 1.0;
    }
    
    [self cancelAllImageLoad];
    self.isPresented = NO;
    BOOL isFromImageClipped = fromView.layer.contentsRect.size.height < 1;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (isFromImageClipped) {
        CGRect frame = cell.mediaContainerView.frame;
        cell.mediaContainerView.layer.anchorPoint = CGPointMake(0.5, 0);
        cell.mediaContainerView.frame = frame;
    }
    cell.progressLayer.hidden = YES;
    [CATransaction commit];
    
    if (fromView == nil) {
        [UIView animateWithDuration:animated ? 0.25 : 0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = 0.0;
            self.collectionView.layer.transformScale = 0.95;
            self.collectionView.alpha = 0;
            self.pager.alpha = 0;
            self.blackBackground.alpha = 0;
        }completion:^(BOOL finished) {
            self.collectionView.layer.transformScale = 1;
            [self removeFromSuperview];
            [self cancelAllImageLoad];
            if (completion) completion();
        }];
        return;
    }
    
    if (isFromImageClipped) {
        [cell.scrollView scrollToTopAnimated:NO];
    }
    
    [UIView animateWithDuration:animated ? 0.2 : 0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
        self.pager.alpha = 0.0;
        self.blackBackground.alpha = 0.0;
        
        if (isFromImageClipped) {
            
            CGRect fromFrame = [fromView convertRect:fromView.bounds toView:cell];
            CGFloat scale = fromFrame.size.width / cell.mediaContainerView.width * cell.scrollView.zoomScale;
            CGFloat height = fromFrame.size.height / fromFrame.size.width * cell.mediaContainerView.width;
            if (isnan(height)) height = cell.mediaContainerView.height;
            
            cell.mediaContainerView.height = height;
            cell.mediaContainerView.center = CGPointMake(CGRectGetMidX(fromFrame), CGRectGetMinY(fromFrame));
            cell.mediaContainerView.layer.transformScale = scale;
            
        } else {
            CGRect fromFrame = [fromView convertRect:fromView.bounds toView:cell.mediaContainerView];
            cell.mediaContainerView.clipsToBounds = NO;
            cell.imageView.contentMode = fromView.contentMode;
            cell.imageView.frame = fromFrame;
        }
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:animated ? 0.15 : 0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.alpha = 0;
            fromView.alpha = 1.0;
        } completion:^(BOOL finished) {
            cell.mediaContainerView.layer.anchorPoint = CGPointMake(0.5, 0.5);
            [self removeFromSuperview];
            
            if (completion) completion();
        }];
    }];
    
    
}

- (void)cancelAllImageLoad {
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(MediaCell *cell, NSUInteger idx, BOOL *stop){
        [cell.imageView cancelCurrentImageRequest];
    }];
}

- (MediaCell *)currentCell{
    return (MediaCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0]];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MediaCell class]) forIndexPath:indexPath];
    cell.item = self.items[indexPath.row];
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat floatPage = self.collectionView.contentOffset.x / self.collectionView.width;
    NSInteger intPage = floatPage + 0.5;
    intPage = intPage < 0 ? 0 : intPage >= self.items.count ? (int)self.items.count - 1 : intPage;
    self.pager.currentPage = intPage;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        self.pager.alpha = 1;
    }completion:^(BOOL finish) {
    }];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [self hidePager];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self hidePager];
}

- (void)hidePager {
    [UIView animateWithDuration:0.3 delay:0.8 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        self.pager.alpha = 0;
    }completion:^(BOOL finish) {
    }];
}

#pragma mark - VideoPlayerDelegate

// 点击播放暂停按钮代理方法
-(void)videoPlayer:(VideoPlayer *)player clickedPlayOrPauseButton:(UIButton *)playOrPauseBtn{
    
}
// 点击关闭按钮代理方法
-(void)videoPlayer:(VideoPlayer *)player clickedCloseButton:(UIButton *)backBtn{
    MediaCell *cell = [self currentCell];
    [cell.player pause];
    [cell.player removeFromSuperview];
    cell.player = nil;
    [self dismissAnimated:YES completion:nil];
}
// 点击全屏按钮代理方法
-(void)videoPlayer:(VideoPlayer *)player clickedFullScreenButton:(UIButton *)fullScreenBtn{
    
}
// 点击锁定按钮的方法
-(void)videoPlayer:(VideoPlayer *)player clickedLockButton:(UIButton *)lockBtn{
    
}
// 单击VideoPlayer的代理方法
-(void)videoPlayer:(VideoPlayer *)player singleTaped:(UITapGestureRecognizer *)singleTap{
    
}
// 双击VideoPlayer的代理方法
-(void)videoPlayer:(VideoPlayer *)player doubleTaped:(UITapGestureRecognizer *)doubleTap{
    
}
// VideoPlayer的的操作栏隐藏和显示
-(void)videoPlayer:(VideoPlayer *)player isHiddenTopAndBottomView:(BOOL )isHidden{
    
}
// 播放失败的代理方法
-(void)videoPlayerFailedPlay:(VideoPlayer *)player playerStatus:(VideoPlayerState)state{
    
}
// 准备播放的代理方法
-(void)videoPlayerReadyToPlay:(VideoPlayer *)player playerStatus:(VideoPlayerState)state{
    
}
// 播放器已经拿到视频的尺寸大小
-(void)videoPlayerGotVideoSize:(VideoPlayer *)player videoSize:(CGSize )presentationSize{
    
}
// 播放完毕的代理方法
-(void)videoPlayerFinishedPlay:(VideoPlayer *)player{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
