//
//  InputToolBar.m
//  MyApp
//
//  Created by huxinguang on 2018/9/21.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "InputToolBar.h"
#import "UIImageView+CornerRadius.h"

@interface InputToolBar()
@property (nonatomic, strong)UIView *topLine;
@end

@implementation InputToolBar

- (instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.inputToolBarHeight = kInputBarOriginalHeight;
        self.containerHeight = 0;
        [self buildSubViews];
    }
    return self;
}

-(NSArray<AssetModel *> *)assets{
    if (_assets == nil) _assets = @[];
    return _assets;
}

-(SelectedAssetsContainer *)assetsContainer{
    if (_assetsContainer == nil) {
        _assetsContainer = [[SelectedAssetsContainer alloc]init];
        _assetsContainer.backgroundColor = [UIColor redColor];
        [self addSubview:_assetsContainer];
        @weakify(self)
        [_assetsContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            @strongify(self)
            make.top.equalTo(self.mas_top);
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.height.mas_equalTo(kAssetsContainerHeight);
        }];
    }
    return _assetsContainer;
}

- (void)buildSubViews{
    self.topLine = [UIView new];
    self.topLine.backgroundColor = [UIColor colorWithRGB:0xE0E0E0];
    [self addSubview:self.topLine];
    @weakify(self)
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.mas_equalTo(CGFloatFromPixel(1));
    }];
    
    self.voiceEntryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.voiceEntryBtn setImage:[UIImage imageNamed:@"input_micphone"] forState:UIControlStateNormal];
    [self.voiceEntryBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    [self addSubview:self.voiceEntryBtn];
    [self.voiceEntryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.bottom.equalTo(self.mas_bottom).with.offset(-(kInputBarOriginalHeight-kVoiceEntryIconSize.height)/2);
        make.left.equalTo(self.mas_left).with.offset(kVoiceImageEntryIconMaginLeftRight);
        make.size.mas_equalTo(kVoiceEntryIconSize);
    }];
    
    self.imgEntryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.imgEntryBtn setImage:[UIImage imageNamed:@"input_image"] forState:UIControlStateNormal];
    [self.imgEntryBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    [self addSubview:self.imgEntryBtn];
    [self.imgEntryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).with.offset(-(kInputBarOriginalHeight-kImageEntryIconSize.height)/2);
        make.right.equalTo(self.mas_right).with.offset(-kVoiceImageEntryIconMaginLeftRight);
        make.size.mas_equalTo(kImageEntryIconSize);
    }];
    
    self.inputView = [[InputTextView alloc]init];
    self.inputView.pLabel.text = @"评一下，看看谁最皮";
    self.inputView.layer.cornerRadius = kTextViewOriginalHeight/2;
    [self addSubview:self.inputView];
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.mas_top).with.offset(kTextViewMaginTopBottom);
        make.bottom.equalTo(self.mas_bottom).with.offset(-kTextViewMaginTopBottom);
        make.left.equalTo(self.voiceEntryBtn.mas_right).with.offset(kVoiceImageEntryIconMaginLeftRight);
        make.right.equalTo(self.imgEntryBtn.mas_left).with.offset(-kVoiceImageEntryIconMaginLeftRight);
    }];
    
}

// tell UIKit that you are using AutoLayout
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

-(void)updateConstraints{
    @weakify(self)
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.height.mas_equalTo(self.inputToolBarHeight);
    }];
    
    [self.topLine mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.top.equalTo(self.mas_top).with.offset(self.containerHeight);
    }];
    
    [self.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.top.equalTo(self.mas_top).with.offset(self.containerHeight + kTextViewMaginTopBottom);
    }];
    
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


@interface SelectedAssetsContainer()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@end

@implementation SelectedAssetsContainer
@synthesize assets = _assets;

-(NSArray<AssetModel *> *)assets{
    if (_assets == nil) _assets = @[];
    return _assets;
}

-(void)setAssets:(NSArray<AssetModel *> *)assets{
    _assets = assets;
    [self.collectionView reloadData];
}

-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = kSelectedAssetItemSize;
        layout.minimumLineSpacing = kSelectedAssetItemSpacing;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_collectionView];
        [_collectionView registerClass:[SelectedAssetCell class] forCellWithReuseIdentifier:NSStringFromClass([SelectedAssetCell class])];
        @weakify(self)
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            @strongify(self)
            if (!self) return;
            make.edges.equalTo(self);
        }];
        _collectionView.layer.shadowColor = [UIColor redColor].CGColor;
        _collectionView.layer.shadowOffset = CGSizeMake(30, 10);
    }
    return _collectionView;
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.assets.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SelectedAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SelectedAssetCell class]) forIndexPath:indexPath];
    cell.numberLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row+1];
    [cell setNeedsUpdateConstraints];
    //对使用Masonry的控件设置圆角，此步很关键
    [cell layoutIfNeeded];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%ld",indexPath.item);
}


@end

@implementation SelectedAssetCell
//代码自定义 UICollectionViewCell,只能重写initWithFrame方法，而不能重写init方法
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.imgView = [[UIImageView alloc]initWithCornerRadiusAdvance:kSelectedAssetItemCornerRadius rectCornerType:UIRectCornerAllCorners];
        self.imgView.backgroundColor = [UIColor greenColor];
        [self.contentView addSubview:self.imgView];
        
        self.numberLabel = [UILabel new];
        self.numberLabel.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.6];
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        self.numberLabel.textColor = [UIColor whiteColor];
        self.numberLabel.font = [UIFont systemFontOfSize:11];
        [self.contentView addSubview:self.numberLabel];
    }
    return self;
}

// tell UIKit that you are using AutoLayout
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints{
    @weakify(self)
    [self.imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.edges.equalTo(self);
    }];
    
    [self.numberLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.right.and.bottom.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    [super updateConstraints];
    
}

/*
 使用Masonry自动布局的View，在添加/更新约束后并不能获取到其frame，所以设置圆角无效，需要调用layoutIfNeeded后才能获取到frame
 
 Masonry is a wrapper for autolayouts, and autolayouts calculate itself frame in - (void)layoutSubviews; method, and only after that u can get frames of all views.
 
 masonry methods mas_makeConstraints and similar just setups Constraints no more.
 
 And if you need update constraints you must call mas_remakeConstraints: its just update constraits, for update Frames of views, we must call method setNeedsLayout for setup a flag about recalculation in next Display cycle, and if we want update frames immediately we must call layoutIfNeeded method.
 */

-(void)layoutIfNeeded{
    [super layoutIfNeeded];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.numberLabel.bounds
                                                   byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomRight)
                                                         cornerRadii:CGSizeMake(3.0f, 3.0f)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.numberLabel.bounds;
    maskLayer.path = maskPath.CGPath;
    self.numberLabel.layer.mask = maskLayer;
}

@end


