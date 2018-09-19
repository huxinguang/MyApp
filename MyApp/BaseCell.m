//
//  BaseCell.m
//  MyApp
//
//  Created by huxinguang on 2018/9/18.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "BaseCell.h"
#import "UIImageView+CornerRadius.h"

@implementation BaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.avatarView = [[UIImageView alloc]initWithRoundingRectImageView];
        [self.contentView addSubview:self.avatarView];
        
        self.nameLabel = [UILabel new];
        [self.contentView addSubview:self.nameLabel];
        
        self.contentLabel = [UILabel new];
        self.contentLabel.numberOfLines = 0;
        [self.contentView addSubview:self.contentLabel];
        
        self.picsContainer = [[PicsContainerView alloc]init];
        [self.contentView addSubview:self.picsContainer];
        
        self.likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:self.likeBtn];
        
        self.dislikeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:self.dislikeBtn];
        
        self.popularityLabel = [UILabel new];
        [self.contentView addSubview:self.popularityLabel];
        
        self.bottomLine = [[UIView alloc]init];
        [self.contentView addSubview:self.bottomLine];
        
    }
    return self;
}

- (void)fillCellData:(Status *)status{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
