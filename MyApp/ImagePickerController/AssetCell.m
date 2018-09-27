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
@property (weak, nonatomic) IBOutlet UIImageView *imageView;       // The photo / 照片
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
    [[PickerImageManager manager] getPhotoWithAsset:model.asset photoWidth:self.width completion:^(UIImage *photo, NSDictionary *info) {
        self.imageView.image = photo;
    }];
    self.selectPhotoButton.selected = model.isSelected;
    self.selectImageView.image = self.selectPhotoButton.isSelected ? [UIImage imageNamed:@"picker_selected"] : [UIImage imageNamed:@"picker_unselected"];
    self.numberLabel.text = self.selectPhotoButton.selected ? [NSString stringWithFormat:@"%d",self.model.number] : @"";
    self.type = AssetCellTypePhoto;
    if (model.type == AssetModelMediaTypeLivePhoto)      self.type = AssetCellTypeLivePhoto;
    else if (model.type == AssetModelMediaTypeAudio)     self.type = AssetCellTypeAudio;
    else if (model.type == AssetModelMediaTypeVideo) {
        self.type = AssetCellTypeVideo;
        self.timeLength.text = model.timeLength;
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
        _bottomView.hidden = NO;
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

