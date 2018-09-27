//
//  TZAssetCell.m
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "TZAssetCell.h"
#import "AssetModel.h"
#import "UIView+ScaleAnimation.h"
#import "PickerImageManager.h"

@interface TZAssetCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;       // The photo / 照片
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *timeLength;

@end

@implementation TZAssetCell

- (void)awakeFromNib {
    self.timeLength.font = [UIFont boldSystemFontOfSize:11];
}

- (void)setModel:(AssetModel *)model {
    _model = model;
    [[PickerImageManager manager] getPhotoWithAsset:model.asset photoWidth:self.width completion:^(UIImage *photo, NSDictionary *info) {
        self.imageView.image = photo;
    }];
    self.selectPhotoButton.selected = model.isSelected;
    self.selectImageView.image = self.selectPhotoButton.isSelected ? [UIImage imageNamed:@"photo_sel_photoPickerVc"] : [UIImage imageNamed:@"photo_def_photoPickerVc"];
    self.type = TZAssetCellTypePhoto;
    if (model.type == AssetModelMediaTypeLivePhoto)      self.type = TZAssetCellTypeLivePhoto;
    else if (model.type == AssetModelMediaTypeAudio)     self.type = TZAssetCellTypeAudio;
    else if (model.type == AssetModelMediaTypeVideo) {
        self.type = TZAssetCellTypeVideo;
        self.timeLength.text = model.timeLength;
    }
}

- (void)setType:(TZAssetCellType)type {
    _type = type;
    if (type == TZAssetCellTypePhoto || type == TZAssetCellTypeLivePhoto) {
        _selectImageView.hidden = NO;
        _selectPhotoButton.hidden = NO;
        _bottomView.hidden = YES;
    } else {
        _selectImageView.hidden = YES;
        _selectPhotoButton.hidden = YES;
        _bottomView.hidden = NO;
    }
}

- (IBAction)selectPhotoButtonClick:(UIButton *)sender {
    if (self.didSelectPhotoBlock) {
        self.didSelectPhotoBlock(sender.isSelected);
    }
    self.selectImageView.image = sender.isSelected ? [UIImage imageNamed:@"photo_sel_photoPickerVc"] : [UIImage imageNamed:@"photo_def_photoPickerVc"];
    if (sender.isSelected) {
        [UIView showScaleAnimationWithLayer:_selectImageView.layer type:TZScaleAnimationToBigger];
    }
}

@end

