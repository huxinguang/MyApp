//
//  ReplyCell.m
//  MyApp
//
//  Created by huxinguang on 2018/9/6.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "ReplyCell.h"
#import "UIImageView+CornerRadius.h"

@implementation ReplyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildSubViews];
    }
    
    return self;
}

- (void)buildSubViews{
    _avatarView = [[UIImageView alloc]initWithRoundingRectImageView];
    [self.contentView addSubview:_avatarView];
    [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(7);
        make.left.equalTo(self.contentView.mas_left).with.offset(15);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];
    
    _nameLabel = [UILabel new];
    _nameLabel.font = [UIFont systemFontOfSize:13];
    _nameLabel.textColor = [UIColor orangeColor];
    [self.contentView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(10);
        make.left.equalTo(self.avatarView.mas_right).with.offset(10);
        make.right.equalTo(self.contentView.mas_right).with.offset(-20);
    }];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:11];
    _timeLabel.textColor = [UIColor colorWithRGB:0xB5B5B5];
    [self.contentView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(5);
        make.left.equalTo(self.nameLabel.mas_left);
        make.right.equalTo(self.nameLabel.mas_right);
    }];
    
    _contentLabel = [YYLabel new];
    _contentLabel.numberOfLines = 0;
    _contentLabel.preferredMaxLayoutWidth = kAppScreenWidth - 15 - 32 - 10 - 20;
    _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _contentLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_contentLabel];
    
    _contentImgView = [[UIImageView alloc]init];
    _contentImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_contentImgView];
    
    
    _thinLine = [[UIView alloc]init];
    _thinLine.backgroundColor = [UIColor colorWithRGB:0xE1E1E1];
    [self.contentView addSubview:_thinLine];
    [self.thinLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_bottom).with.offset(-0.5);
        make.left.equalTo(self.nameLabel.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.height.mas_equalTo(0.5);
    }];
    
}

- (void)fillCellData:(Comment *)comment{
    self.comment = comment;
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:comment.head_url]];
    self.nameLabel.text = comment.user_name;
    if (comment.content) {
        
        NSString *str = nil;
        if (comment.reply_user_name) {
            str = [NSString stringWithFormat:@"回复@%@：%@",comment.reply_user_name,comment.content];
        }else{
            str = comment.content;
        }
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:str];
        if (comment.reply_user_name) {
            [attributedString yy_setTextHighlightRange:NSMakeRange(2, comment.reply_user_name.length + 1) color:[UIColor colorWithRGB:0x496EA2] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                //
            }];
        }
        
        attributedString.yy_font = [UIFont systemFontOfSize:14];
        self.contentLabel.attributedText = attributedString;
    }
    if (comment.img_url) {
        [self.contentImgView sd_setImageWithURL:[NSURL URLWithString:comment.img_url]];
    }
    self.timeLabel.text = comment.create_time;
}

+ (BOOL)requiresConstraintBasedLayout{
    return YES;
}

- (void)updateConstraints{
    [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeLabel.mas_bottom).with.offset(8);
        make.left.equalTo(self.timeLabel.mas_left);
        make.right.equalTo(self.contentView.mas_right).with.offset(-20);
    }];
    
    [self.contentImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLabel.mas_bottom).with.offset(8);
        make.left.equalTo(self.nameLabel.mas_left);
        self.contentImgSizeConstraint = make.size.mas_equalTo(CGSizeMake(self.comment.image_width, self.comment.image_height));
    }];
    
    
    
    [super updateConstraints];
}



- (void)prepareForReuse{
    [super prepareForReuse];
    self.comment = nil;
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
