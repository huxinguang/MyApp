//
//  AssetCell.h
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AssetCellType) {
    AssetCellTypeUnknown = 0,
    AssetCellTypeImage   = 1,
    AssetCellTypeVideo   = 2,
    AssetCellTypeAudio   = 3,
    AssetCellTypeCamera  = 4  //相机占位
};


@class AssetModel;
@interface AssetCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *selectPhotoButton;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (nonatomic, strong) AssetModel *model;
@property (nonatomic, copy) void (^didSelectPhotoBlock)(BOOL);
@property (nonatomic, assign) AssetCellType type;

@end


