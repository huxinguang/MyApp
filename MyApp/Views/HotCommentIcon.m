//
//  HotCommentIcon.m
//  MyApp
//
//  Created by huxinguang on 2018/9/14.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "HotCommentIcon.h"

@implementation HotCommentIcon

-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(18, 0, 30, contentRect.size.height);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    return CGRectMake(0, 0, 18, 18);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
