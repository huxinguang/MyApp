//
//  AlbumCell.m
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "AlbumCell.h"
#import "TZImageManager.h"

@implementation AlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
}

- (void)setModel:(TZAlbumModel *)model{
    _model = model;
    self.albumNameLabel.text = [NSString stringWithFormat:@"%@(%ld)",model.name,model.count];
    [[TZImageManager manager] getPostImageWithAlbumModel:model completion:^(UIImage *postImage) {
        self.imgView.image = postImage;
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end