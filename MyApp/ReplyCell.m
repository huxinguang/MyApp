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
        self.contentView.backgroundColor = [UIColor colorWithRGB:0xF5F5F7];
        [self buildSubViews];
    }
    
    return self;
}

- (void)buildSubViews{
    self.nameLabel.font = [UIFont systemFontOfSize:kCommentNameFont];
    self.nameLabel.textColor = [UIColor orangeColor];
    
    self.contentLabel.font = [UIFont systemFontOfSize:kCommentTextFont];
    self.contentLabel.preferredMaxLayoutWidth = kAppScreenWidth - 2*kCommentCellPaddingLeftRight - kCommentAvatarViewSize.width - kCommentNameMarginLeft;
    
    self.picsContainer.type = PicsContainerTypeCommentOrReply;
    self.picsContainer.cell = self;
    
    self.timeLabel = [UILabel new];
    self.timeLabel.font = [UIFont systemFontOfSize:kCommentTimeLabelFont];
    self.timeLabel.textColor = [UIColor colorWithRGB:0xB5B5B5];
    [self.contentView addSubview:self.timeLabel];
    
    //    [self.likeBtn setImage:[UIImage imageNamed:@"dislike"] forState:UIControlStateNormal];
    //    self.likeBtn.transform = CGAffineTransformMakeRotation(-M_PI);
    //
    //    [self.dislikeBtn setImage:[UIImage imageNamed:@"dislike"] forState:UIControlStateNormal];
    //
    //    self.popularityLabel.font = [UIFont systemFontOfSize:13];
    //    self.popularityLabel.textColor = [UIColor lightGrayColor];
    
    self.bottomLine.backgroundColor = [UIColor colorWithRGB:0xEEEEEE];
}

- (void)fillCellData:(Status *)status{
    self.sts = status;
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:status.head_url]];
    self.nameLabel.text = status.user_name;
    if (status.content) {
        self.contentLabel.text = status.content;
    }
    self.picsContainer.pics = status.medias;
    self.timeLabel.text = status.create_time;
}

+ (BOOL)requiresConstraintBasedLayout{
    return YES;
}

- (void)updateConstraints{
    @weakify(self)
    [self.avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.top.equalTo(self.contentView.mas_top).with.offset(kCommentAvatarViewMarginTop);
        make.left.equalTo(self.contentView.mas_left).with.offset(kCommentCellPaddingLeftRight);
        make.size.mas_equalTo(kCommentAvatarViewSize);
    }];
    
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.top.equalTo(self.avatarView.mas_top);
        make.left.equalTo(self.avatarView.mas_right).with.offset(kCommentNameMarginLeft);
        make.right.equalTo(self.contentView.mas_right).with.offset(-kCommentCellPaddingLeftRight);
        make.height.mas_equalTo(kCommentNameLabelHeight);
    }];
    
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.bottom.equalTo(self.avatarView.mas_bottom);
        make.left.equalTo(self.avatarView.mas_right).with.offset(kCommentNameMarginLeft);
        make.right.equalTo(self.contentView.mas_right).with.offset(-kCommentCellPaddingLeftRight);
        make.height.mas_equalTo(kCommentTimeLabelHeight);
    }];
    
    [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.top.equalTo(self.avatarView.mas_bottom).with.offset(kCommentTextMarginTop);
        make.left.equalTo(self.nameLabel.mas_left);
        make.right.equalTo(self.contentView.mas_right).with.offset(-kCommentCellPaddingLeftRight);
    }];
    
    [self.picsContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.top.equalTo(self.contentLabel.mas_bottom).with.offset(kCommentImageMarginTop);
        make.left.equalTo(self.nameLabel.mas_left);
        make.right.equalTo(self.contentView.mas_right).with.offset(-kCommentCellPaddingLeftRight);
        make.height.mas_equalTo(self.sts.commentImageContainerHeight);
    }];
    
    [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.left.and.bottom.and.right.equalTo(self.contentView);
        make.height.mas_equalTo(kCommentCellBottomLineHeight);
    }];
    
    [super updateConstraints];
}

- (void)layoutSubviews{
    if (self.sts.medias.count == 0) {
        self.picsContainer.hidden = YES;
    }else{
        self.picsContainer.hidden = NO;
    }
    [super layoutSubviews];
}

- (void)prepareForReuse{
    [super prepareForReuse];
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
