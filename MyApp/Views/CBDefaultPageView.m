//
//  CBDefaultPageView.m
//  CombProject
//
//  Created by kunpan on 16/10/20.
//  Copyright © 2016年 __MyCompanyName__. All rights reserved.
//

#import "CBDefaultPageView.h"
#import "CBOCDataGlobal.h"

@interface CUtil : NSObject

+(UIColor * )colorWithRGB:(NSUInteger)rgb;
@end

@implementation CUtil

+(UIColor * )colorWithRGB:(NSUInteger)rgb
{
    NSUInteger red = ( (rgb&0xff0000) >> 16 );
    NSUInteger green = ( (rgb&0xff00) >> 8 );
    NSUInteger blue = ( rgb & 0xFF );
    CGFloat r = (CGFloat)red / 255.0f;
    CGFloat g = (CGFloat)green  / 255.0f;
    CGFloat b = (CGFloat)blue / 255.0f;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0f];
}

@end


//==================================================
#define kDesLabelFontSize    (15.f)
#define kDefaultPageDescDefaultColor       0x666666//0xa6a6a6
#define kQCDefaultpageDescWidthMax         200.f
#define kQCDefaultpageDescHeightMax         60.f
#define kQCDefaultPagePicAndDescSpace       15.f

@interface CBDefaultPageView ()

@property (nonatomic, strong) UIImageView * defaultImageView;
@property (nonatomic, strong) UILabel * desLabel;

@property (nonatomic,   copy) NSString * defaultImageName;
@property (nonatomic,   copy) NSString * defaultDescString;

@end

@implementation CBDefaultPageView

#pragma  mark -- 外部接口区
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        _defaultImageName   = @"";
        _defaultDescString  = @"";
        [self buildView];
        [self setBackgroupType:CBDefaultPageBackgroupType_Default];
        
        UITapGestureRecognizer * tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestClick)];
        [self addGestureRecognizer:tapGest];
    }
    
    return self;
}

+(id)defaultPageViewWithType:(CBDefaultPageType)type
{
    CBDefaultPageView * defaultView = [[CBDefaultPageView alloc] initWithFrame:CGRectZero];
    defaultView.backgroundColor = [UIColor whiteColor];
    defaultView.defaultType = type;
    
    
    return defaultView;
}

-(id)initWithFrameAndType:(CGRect)frame type:(CBDefaultPageType)type
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setDefaultType:type];
    }
    
    return self;
}

#pragma  mark -- 内部接口区
-(void)buildView
{
    _defaultImageView = [[UIImageView alloc] init];
    _defaultImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_defaultImageView];
    
    _desLabel = [[UILabel alloc] init];
    _desLabel.font = [UIFont systemFontOfSize:kDesLabelFontSize];
    _desLabel.textAlignment = NSTextAlignmentCenter;
    _desLabel.backgroundColor = [UIColor clearColor];
    _desLabel.numberOfLines = 3;
    [self addSubview:_desLabel];
}

-(void)getDefaultInfo
{
    switch (_defaultType) {
        case CBDefaultPageType_NOData:
        {
            _defaultImageName = @"ic_no_network_night@2x.png";//@"ic_no_data_night@2x.png";
            _defaultDescString = @"暂无数据，请您稍后再试";
        }
            break;
            // TO DO: 继续添加其他的type(其他的defaultView 类型)
        case CBDefaultPageType_PaySuccessFinsh:
        {
            _defaultImageName = @"paySuccessImage@2x.png";
            _defaultDescString = @"支付成功";
        }
            break;
        case CBDefaultPageType_PaySuccessFail:
        {
            _defaultImageName = @"payFailImage@2x.png";
            _defaultDescString = @"支付失败";
        }
            break;
        case CBDefaultPageType_NODataAddress:
        {
            _defaultImageName = @"noOrderData@2x.png";
            _defaultDescString = @"您还没有订单呐";
        }
            break;
        case CBDefaultPageType_NOWiFiAddress:
        {
            _defaultImageName = @"address_default@2x.png";
            _defaultDescString = @"当前网络不好,刷新后重试.";
        }
            break;
        case CBDefaultPageType_NOSearchResult:
        {
            _defaultImageName = @"icon_search_NOResult@2x.png";
            _defaultDescString = @"没有找到相关的搜索";
        }
            break;
        case CBDefaultPageType_NoNetwork:
        {
            _defaultImageName = @"ic_no_network_night@2x.png";
            _defaultDescString  = @"暂无网络，请检查网络设置后重试";
        }
            break;
        case CBDefaultPageType_NOOrderData:             // 没有订单数据
        {
            _defaultImageName = @"ic_no_orderdata_night@2x.png";
            _defaultDescString  = @"抱歉, 暂无数据, 请您稍后再试";
        }
            break;
        case CBDefaultPageType_NOMessageData:
        {
            _defaultImageName = @"ic_no_messdata_night@2x.png";
            _defaultDescString  = @"您还没有消息哦!";
        }
            break;
        default:
            break;
    }
}

-(void)adjuestFrame
{
    if(_desLabel.text.length <=0 || _defaultImageView.image == nil)
        return;
    
    // 得到defaultView的width、height
    CGRect frame = self.bounds;
    CGFloat defaultWidth   = frame.size.width;
    CGFloat defaultHeight  = frame.size.height;
    if(defaultWidth == 0)
    {
        defaultWidth = kQCDefaultpageDescWidthMax;
    }
    
    
    CGSize desLabelSize = [_desLabel.text boundingRectWithSize:CGSizeMake(defaultWidth, defaultHeight) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kDesLabelFontSize]} context:nil].size;
    
    // 得到imageView.height + label.height
    CGFloat contentHeight = desLabelSize.height + kQCDefaultPagePicAndDescSpace + _defaultImageView.image.size.height;
    if(defaultHeight == 0)
    {
        defaultHeight = contentHeight;
    }
    
    // 设置imageView.frame
    CGRect imageFrame = _defaultImageView.frame;
    imageFrame.origin.x = (defaultWidth - _defaultImageView.image.size.width)/2;
    imageFrame.origin.y = (defaultHeight - contentHeight )/2;
    imageFrame.size.width = _defaultImageView.image.size.width;
    imageFrame.size.height = _defaultImageView.image.size.height;
    _defaultImageView.frame = imageFrame;
    
    // 设置label.frame
    CGRect labelFrame = _desLabel.frame;
    labelFrame.origin.x = (defaultWidth - desLabelSize.width)/2;
    labelFrame.origin.y = CGRectGetMaxY(_defaultImageView.frame) + kQCDefaultPagePicAndDescSpace;
    labelFrame.size = desLabelSize;
    _desLabel.frame = labelFrame;
    _desLabel.textColor = [CUtil colorWithRGB:kDefaultPageDescDefaultColor];
    
    // 设置self.frame
    CGRect defaultFrame = self.frame;
    defaultFrame.size = CGSizeMake(defaultWidth, defaultHeight);
    [super setFrame:defaultFrame];
    
}

#pragma  mark -- set/get
-(void)setBackgroupType:(CBDefaultPageBackgroupType)backgroupType
{
    if(!backgroupType || _backgroupType == backgroupType)
        return;
    
    _backgroupType = backgroupType;
    
    switch (backgroupType) {
        case CBDefaultPageBackgroupType_Default:
        {
            self.backgroundColor = [UIColor whiteColor];
            _desLabel.textColor = [CUtil colorWithRGB:kDefaultPageDescDefaultColor];
        }
            break;
            // TO DO: 继续添加其他的type(夜间模式.)
            
        default:
            _desLabel.textColor = [CUtil colorWithRGB:kDefaultPageDescDefaultColor];
            break;
    }
}

-(void)setDefaultType:(CBDefaultPageType)defaultType
{
    _defaultType = defaultType;
    
    [self getDefaultInfo];
    if(_defaultDescString.length <= 0)
        return;
    
    _defaultImageView.image = [UIImage imageNamed:_defaultImageName];//[[CBStaticImage shareStaticImage] getLittlePicture:_defaultImageName];
    _desLabel.text = _defaultDescString;
    
    [self adjuestFrame];
}

-(void)setInfo:(NSString *)info
{
    _info = info;
    _desLabel.text = info;
    [self adjuestFrame];
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self adjuestFrame];
}

#pragma  mark -- 按钮回调区
-(void)tapGestClick
{
    if(CHECK_VALID_DELEGATE(self.delegate, @selector(onDefaultTapClick:)))
    {
        [self.delegate onDefaultTapClick:self];
    }
}

@end
