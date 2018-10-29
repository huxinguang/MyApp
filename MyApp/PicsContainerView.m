//
//  PicsContainerView.m
//  MyApp
//
//  Created by huxinguang on 2018/9/15.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "PicsContainerView.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "VideoPlayer.h"
#import "BaseCell.h"


@implementation PicsContainerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSMutableArray *array = [NSMutableArray new];
        @weakify(self)
        for (int i=0; i<9; i++) {
            YYControl *imageView = [YYControl new];
            imageView.backgroundColor = [UIColor colorWithRGB:0xF0F0F2];
            imageView.clipsToBounds = YES;
            imageView.exclusiveTouch = YES;
            imageView.touchBlock = ^(YYControl *view, YYGestureRecognizerState state, NSSet *touches, UIEvent *event) {
                @strongify(self)
                if (!self) return;
                if (state == YYGestureRecognizerStateEnded) {
                    UITouch *touch = touches.anyObject;
                    CGPoint p = [touch locationInView:view];
                    if (CGRectContainsPoint(view.bounds, p)) {
                        switch (self.type) {
                            case PicsContainerTypeStatus:{
                                if (self.cell.delegate && [self.cell.delegate respondsToSelector:@selector(didClickImageAtIndex: inCell:isInSubPicContainer:)]) {
                                    [self.cell.delegate didClickImageAtIndex:i inCell:self.cell isInSubPicContainer:NO];
                                }
                            }
                                break;
                            case PicsContainerTypeStatusHotComment:{
                                if (self.cell.delegate && [self.cell.delegate respondsToSelector:@selector(didClickImageAtIndex: inCell:isInSubPicContainer:)]) {
                                    [self.cell.delegate didClickImageAtIndex:i inCell:self.cell isInSubPicContainer:YES];
                                }
                            }
                                break;
                            case PicsContainerTypeCommentOrReply:{
                                if (self.cell.delegate && [self.cell.delegate respondsToSelector:@selector(didClickImageAtIndex: inCell:isInSubPicContainer:)]) {
                                    [self.cell.delegate didClickImageAtIndex:i inCell:self.cell isInSubPicContainer:NO];
                                }
                            }
                                break;
                            default:
                                break;
                        }
                        
                    }
                }
            };
            [self addSubview:imageView];
            [array addObject:imageView];
        }
        self.picViews = array;
    }
    return self;
}

- (void)setPics:(NSArray<Media *> *)pics{
    _pics = pics;
    [self setNeedsLayout];
}

-(void)layoutSubviews{
    if (self.pics && self.pics.count > 0) {
        CGSize picSize = CGSizeZero;
        if (self.type == PicsContainerTypeStatus) {
            picSize = CGSizeMake(kStatusPicHW, kStatusPicHW);
        }else if(self.type == PicsContainerTypeStatusHotComment) {
            picSize = CGSizeMake(kStatusCommentPicHW, kStatusCommentPicHW);
        }else{
            picSize = CGSizeMake(kCommentPicHW, kCommentPicHW);
        }
        
        for (int i=0; i<9; i++) {
            YYControl *imageView = self.picViews[i];
            if (i >= self.pics.count) {
                imageView.hidden = YES;
            }else{
                CGPoint origin = CGPointMake(0, 0);
                switch (self.pics.count) {
                    case 1:
                    {
                        CGFloat width = 0;
                        CGFloat height = 0;
                        if (self.type == PicsContainerTypeStatus) {
                            if (self.pics[0].media_width > self.pics[0].media_height) {
                                width = kAppScreenWidth - 2*kStatusCellPaddingLeftRight;
                            }else{
                                width = (kAppScreenWidth - 2*kStatusCellPaddingLeftRight)*0.667;
                            }
                            height = width*self.pics[0].media_height/self.pics[0].media_width;
                        }else{
                            width = picSize.width;
                            height = picSize.height;
                        }
                        imageView.frame = CGRectMake(0, 0, width, height);
                    }
                        
                        break;
                    case 4:
                    {
                        if (self.type == PicsContainerTypeStatus) {
                            //帖子图片如果是4个，则以2+2形式展示
                            origin.x = (i % 2) * (picSize.width + kStatusCellPaddingPic);
                            origin.y = (int)(i / 2) * (picSize.height + kStatusCellPaddingPic);
                        }else{
                            //评论图片如果是4个，则按3+1形式展示
                            origin.x = (i % 3) * (picSize.width + kStatusCellPaddingPic);
                            origin.y = (int)(i / 3) * (picSize.height + kStatusCellPaddingPic);
                        }
                        imageView.frame = (CGRect){.origin = origin, .size = picSize};
                    }
                        break;
                    default:
                    {
                        origin.x = (i % 3) * (picSize.width + kStatusCellPaddingPic);
                        origin.y = (int)(i / 3) * (picSize.height + kStatusCellPaddingPic);
                        imageView.frame = (CGRect){.origin = origin, .size = picSize};
                    }
                        break;
                }
                
                imageView.hidden = NO;
                
                
                Media *m = self.pics[i];
                
                @weakify(imageView);
                [imageView.layer setImageWithURL:[NSURL URLWithString:m.cover_url]
                                     placeholder:nil
                                         options:YYWebImageOptionAvoidSetImage
                                      completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                  @strongify(imageView);
                  if (!imageView) return;
                  if (image && stage == YYWebImageStageFinished) {
                      int width = m.media_width;
                      int height = m.media_height;
                      CGFloat scale = (height / width) / (imageView.height / imageView.width);
                      if (scale < 0.99 || isnan(scale)) { // 宽图把左右两边裁掉
//                          imageBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
//                          imageBtn.imageView.layer.contentsRect = CGRectMake(0, 0, 1, 1);
                          imageView.contentMode = UIViewContentModeScaleAspectFill;
                          imageView.layer.contentsRect = CGRectMake(0, 0, 1, 1);
                      } else { // 高图只保留顶部
                          imageView.contentMode = UIViewContentModeScaleToFill;
                          imageView.layer.contentsRect = CGRectMake(0, 0, 1, (float)width / height);
                      }
                      ((YYControl *)imageView).image = image;
                      if (from != YYWebImageFromMemoryCacheFast) {
                          CATransition *transition = [CATransition animation];
                          transition.duration = 0.15;
                          transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                          transition.type = kCATransitionFade;
                          [imageView.layer addAnimation:transition forKey:@"contents"];
                      }
                  }
              }];
                
                
                
                
                
                
                
                
                
                
                
                /*
                
                Media *m = self.pics[i];
                int width = m.media_width;
                int height = m.media_height;
                CGFloat scale = (height / width) / (imageBtn.height / imageBtn.width);

                if (scale < 0.99 || isnan(scale) || m.media_type == 2) {
                    // 宽图把左右两边裁掉 (注意： 应该设置imageBtn.imageView.contentMode 而不是imageBtn.contentMode)
                    imageBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
//                    imageBtn.imageView.layer.contentsRect = CGRectMake(0, 0, 1, 1);
                } else {
                    // 高图只保留顶部(视频例外)(注意：应该设置imageBtn.imageView.contentMode 而不是imageBtn.contentMode)
                    imageBtn.imageView.contentMode = UIViewContentModeScaleToFill;
                    imageBtn.imageView.layer.contentsRect = CGRectMake(0, 0, 1, width / height);
                }
//                if (m.media_type == 1) { //图片
                    [imageBtn sd_setImageWithURL:[NSURL URLWithString:m.cover_url] forState:UIControlStateNormal];
//                }else{ //视频
//                    //这里只是临时这么做，不能每次都去请求第一帧图片，而是要让服务端提供视频第一帧的图片
//                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                        UIImage *image = [VideoPlayer firstFrameImageForVideo:[NSURL URLWithString:m.media_url]];
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [imageBtn setImage:image forState:UIControlStateNormal];
//                        });
//                    });
//
//                }
                
                imageBtn.imageView.clipsToBounds = YES;
                */
            }
            
        }
        
    }
    
    [super layoutSubviews];
}

//- (void)updateConstraints{
//
//    [super updateConstraints];
//}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
