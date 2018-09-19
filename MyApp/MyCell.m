//
//  MyCell.m
//  MyApp
//
//  Created by huxinguang on 2018/9/11.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "MyCell.h"

@implementation MyCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildSubViews];
    }
    return self;
}

- (void)buildSubViews{
    self.iconView = [UIImageView new];
    [self.contentView addSubview:self.iconView];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).with.offset(15);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.iconView.mas_right).with.offset(20);
    }];
    
    self.arrowView = [UIImageView new];
    self.arrowView.image = [UIImage imageNamed:@"mine_accessory"];
    [self.contentView addSubview:self.arrowView];
    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).with.offset(-10);
        make.size.mas_equalTo(CGSizeMake(13, 13));
    }];
    
    self.countLabel = [UILabel new];
    self.countLabel.font = [UIFont systemFontOfSize:16];
    self.countLabel.textColor = [UIColor colorWithRGB:0x999EAC];
    self.countLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.countLabel];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.arrowView.mas_left).with.offset(-10);
        make.width.mas_equalTo(100);
    }];
    
    self.thinLine = [UIView new];
    self.thinLine.backgroundColor = [UIColor colorWithRGB:0xEFF0F7];
    [self.contentView addSubview:self.thinLine];
    [self.thinLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(CGFloatFromPixel(1));
    }];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
