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
#import "PickerImageManager.h"

@interface AssetCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;       // 照片
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
    switch (model.type) {
        case AssetModelMediaTypePhoto:
            self.type = AssetCellTypePhoto;
            break;
        case AssetModelMediaTypeLivePhoto:
            self.type = AssetCellTypeLivePhoto;
            break;
        case AssetModelMediaTypeVideo:
            self.type = AssetCellTypeVideo;
            self.timeLength.text = model.timeLength;
            break;
        case AssetModelMediaTypeAudio:
            self.type = AssetCellTypeAudio;
            break;
        case AssetModelMediaTypeCamera:
            self.type = AssetCellTypeCamera;
            break;
        default:
            break;
    }
    if (self.type != AssetCellTypeCamera) {
        [[PickerImageManager manager] getPhotoWithAsset:model.asset photoWidth:self.width completion:^(UIImage *photo, NSDictionary *info) {
            self.imageView.image = photo;
        }];
        self.selectPhotoButton.selected = model.isSelected;
        self.selectImageView.image = model.isSelected ? [UIImage imageNamed:@"picker_selected"] : [UIImage imageNamed:@"picker_unselected"];
        self.numberLabel.text = self.selectPhotoButton.selected ? [NSString stringWithFormat:@"%d",self.model.number] : @"";
        self.numberLabel.hidden = NO;
    }else{
        self.imageView.image = [UIImage imageNamed:@"picker_camera"];
        self.numberLabel.hidden = YES;
    }
    
}

- (void)setType:(AssetCellType)type {
    _type = type;
    if (type == AssetCellTypePhoto || type == AssetCellTypeLivePhoto) {
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
        [UIView showScaleAnimationWithLayer:_selectImageView.layer type:TZScaleAnimationToBigger];
    }
}

@end

