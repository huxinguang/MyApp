//
//  AssetCell.h
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    AssetCellTypePhoto = 0,
    AssetCellTypeLivePhoto,
    AssetCellTypeVideo,
    AssetCellTypeAudio,
} AssetCellType;

@class AssetModel;
@interface AssetCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *selectPhotoButton;
@property (nonatomic, strong) AssetModel *model;
@property (nonatomic, copy) void (^didSelectPhotoBlock)(BOOL);
@property (nonatomic, assign) AssetCellType type;

@end


@class AlbumModel;

@interface TZAlbumCell : UITableViewCell

@property (nonatomic, strong) AlbumModel *model;

@end
