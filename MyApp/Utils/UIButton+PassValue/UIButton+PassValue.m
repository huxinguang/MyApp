//
//  UIButton+PassValue.m
//  MyApp
//
//  Created by huxinguang on 2018/9/20.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "UIButton+PassValue.h"

@implementation UIButton (PassValue)

-(NSDictionary *)paramDic{
    return objc_getAssociatedObject(self, _cmd);
}
-(void)setParamDic:(NSDictionary *)paramDic{
    objc_setAssociatedObject(self, @selector(paramDic), paramDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
