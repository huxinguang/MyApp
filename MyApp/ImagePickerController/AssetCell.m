//
//  AssetCell.m
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "AssetCell.h"
#import "AssetModel.h"
#import "UIView+ScaleAnimation.h"
#import "AssetPickerManager.h"

@interface AssetCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *timeLength;

@end

@implementation AssetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.timeLength.font = [UIFont boldSystemFontOfSize:11];
}

- (void)setModel:(AssetModel *)model {
    _model = model;
    if (model.isPlaceholder) {
        self.type = AssetCellTypeCamera;
    }else{
        switch (model.asset.mediaType) {
            case PHAssetMediaTypeUnknown:
                self.type = AssetCellTypeUnknown;
                break;
            case PHAssetMediaTypeImage:
                self.type = AssetCellTypeImage;
                break;
            case PHAssetMediaTypeVideo:
                self.type = AssetCellTypeVideo;
                break;
            case PHAssetMediaTypeAudio:
                self.type = AssetCellTypeAudio;
                break;
            default:
                break;
        }
    }

    if (self.type != AssetCellTypeCamera) {
        [[AssetPickerManager manager] getPhotoWithAsset:model.asset photoWidth:self.width completion:^(UIImage *photo, NSDictionary *info) {
            self.imageView.image = photo;
        }];
        self.selectPhotoButton.selected = model.picked;
        self.selectImageView.image = model.picked ? [UIImage imageNamed:@"picker_selected"] : [UIImage imageNamed:@"picker_unselected"];
        self.numberLabel.text = self.selectPhotoButton.selected ? [NSString stringWithFormat:@"%d",self.model.number] : @"";
        self.numberLabel.hidden = NO;
    }else{
        self.imageView.image = [UIImage imageNamed:@"picker_camera"];
        self.numberLabel.hidden = YES;
    }
    
}

- (void)setType:(AssetCellType)type {
    _type = type;
    if (type == AssetCellTypeImage || type == AssetCellTypeVideo) {
        _selectImageView.hidden = NO;
        _selectPhotoButton.hidden = NO;
        _bottomView.hidden = YES;
    } else {
        _selectImageView.hidden = YES;
        _selectPhotoButton.hidden = YES;
        if (type == AssetCellTypeCamera) {
            _bottomView.hidden = YES;
        }else{
            _bottomView.hidden = NO;
        }
    }
}

- (IBAction)selectPhotoButtonClick:(UIButton *)sender {
    if (self.didSelectPhotoBlock) {
        self.didSelectPhotoBlock(sender.isSelected);
    }
    self.selectImageView.image = sender.isSelected ? [UIImage imageNamed:@"picker_selected"] : [UIImage imageNamed:@"picker_unselected"];
    if (sender.isSelected) {
        [UIView showScaleAnimationWithLayer:_selectImageView.layer type:ScaleAnimationToBigger];
    }
}

@end

