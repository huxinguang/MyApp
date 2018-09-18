//
//  PicsContainerView.m
//  MyApp
//
//  Created by huxinguang on 2018/9/15.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "PicsContainerView.h"

@implementation PicsContainerView

- (instancetype)initWithType:(PicsContainerType)type{
    if (self = [super init]) {
        self.type = type;
        NSMutableArray *array = [NSMutableArray new];
        for (int i=0; i<9; i++) {
            UIButton *imgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self addSubview:imgBtn];
            [array addObject:imgBtn];
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
        }else{
            picSize = CGSizeMake(kStatusCommentPicHW, kStatusCommentPicHW);
        }
        
        for (int i=0; i<9; i++) {
            UIImageView *imageView = self.picViews[i];
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
                                width = kAppScreenWidth - 2*kStatusCellPadding;
                            }else{
                                width = (kAppScreenWidth - 2*kStatusCellPadding)*0.667;
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
                int width = m.media_width;
                int height = m.media_height;
                CGFloat scale = (height / width) / (imageView.height / imageView.width);
                if (scale < 0.99 || isnan(scale)) {
                    // 宽图把左右两边裁掉
                    imageView.contentMode = UIViewContentModeScaleAspectFill;
                } else {
                    // 高图只保留顶部
                    imageView.contentMode = UIViewContentModeScaleToFill;
                }
                //这里后期需要改一下
                [imageView sd_setImageWithURL:[NSURL URLWithString:m.media_url]];
                imageView.clipsToBounds = YES;
                
            }
            
        }
        
    }
    
    [super layoutSubviews];
}

- (void)updateConstraints{
    
    [super updateConstraints];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
