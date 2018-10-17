//
//  InputToolBar.h
//  MyApp
//
//  Created by huxinguang on 2018/9/21.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputTextView.h"

#define kInputBarOriginalHeight 48                                                  //工具条初始高度
#define kVoiceEntryIconSize CGSizeMake(26, 26)                                      //声音按钮size
#define kImageEntryIconSize CGSizeMake(26, 26)                                      //图片按钮size
#define kVoiceImageEntryIconMaginLeftRight 20                                       //声音、图片按钮左右边距
#define kTextViewOriginalHeight 36                                                  //输入框初始高度
#define kTextViewMaginTopBottom (kInputBarOriginalHeight-kTextViewOriginalHeight)/2 //输入框顶部、底部边距
#define kInputBarMaxlHeight  90                                                     //输入框最大高度
#define kAssetsContainerHeight 100                                                  //图片容器高度
#define kSelectedAssetItemSize CGSizeMake(70, 70)                                   //选中图片的size
#define kSelectedAssetItemSpacing 15                                                //选中图片间距
#define kSelectedAssetItemCornerRadius 3                                            //圆角半径

@class AssetModel;
@class SelectedAssetsContainer;

@interface InputToolBar : UIView
@property (nonatomic, strong)InputTextView *inputView;
@property (nonatomic, strong)UIButton *voiceEntryBtn;
@property (nonatomic, strong)UIButton *imgEntryBtn;
@property (nonatomic, strong)SelectedAssetsContainer *assetsContainer;
@property (nonatomic, strong)NSArray<AssetModel *> *assets;
@property (nonatomic, assign)CGFloat inputToolBarHeight;
@property (nonatomic, assign)CGFloat containerHeight;


@end

@interface SelectedAssetsContainer: UIView
@property (nonatomic, strong)NSArray<AssetModel *> *assets;
@property (nonatomic, strong)UICollectionView *collectionView;
@end

@interface SelectedAssetCell: UICollectionViewCell
@property (nonatomic, strong)UIImageView *imgView;
@property (nonatomic, strong)UILabel *numberLabel;

@end


