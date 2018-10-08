//
//  AlbumCell.m
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "AlbumCell.h"
#import "AssetPickerManager.h"

@implementation AlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(AlbumModel *)model{
    _model = model;
    self.albumNameLabel.text = [NSString stringWithFormat:@"%@(%ld)",model.name,model.count];
    self.selectedCountLabel.text = model.selectedCount > 0 ? [NSString stringWithFormat:@"已选%ld",model.selectedCount] : @"";
    [[AssetPickerManager manager] getPostImageWithAlbumModel:model completion:^(UIImage *postImage) {
        self.imgView.image = postImage;
    }];
    if (model.isSelected) {
        self.contentView.backgroundColor = [UIColor colorWithRGB:0xF0FCFF];
    }else{
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
