//
//  CBDefaultPageView.h
//  CombProject
//
//  Created by kunpan on 16/10/20.
//  Copyright © 2016年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CBDefaultPageView;

typedef NS_ENUM(NSInteger,CBDefaultPageType)
{
    CBDefaultPageType_NOData = 0,           // 没有数据
    CBDefaultPageType_NoNetwork,            // 没有网络
    CBDefaultPageType_PaySuccessFinsh,  // 支付成功
    CBDefaultPageType_PaySuccessFail,    // 支付失败
    CBDefaultPageType_NOOrderData,      // 订单没有数据
    CBDefaultPageType_NOMessageData,  // 消息没有数据
    CBDefaultPageType_NODataAddress,    // 没数据
    CBDefaultPageType_NOWiFiAddress,    // 没网络
    CBDefaultPageType_NOSearchResult,   // 没有搜索结果页
};

typedef NS_ENUM(NSInteger,CBDefaultPageBackgroupType)
{
    CBDefaultPageBackgroupType_Default, //default while
};

@protocol CBDefaultPageViewDelegate <NSObject>
@optional
-(void)onDefaultTapClick:(CBDefaultPageView *)defaultView;

@end

@interface CBDefaultPageView : UIView

// 设置defaultType来去修改显示的表情
@property (nonatomic, assign) CBDefaultPageType defaultType;

@property (nonatomic,   copy) NSString * info;

@property (nonatomic, assign) CBDefaultPageBackgroupType  backgroupType;

@property (nonatomic,   weak) id<CBDefaultPageViewDelegate> delegate;

+(id)defaultPageViewWithType:(CBDefaultPageType)type;

-(id)initWithFrameAndType:(CGRect)frame type:(CBDefaultPageType)type;

@end
