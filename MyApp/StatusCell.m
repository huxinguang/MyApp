//
//  StatusCell.m
//  MyApp
//
//  Created by huxinguang on 2018/8/28.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "StatusCell.h"
#import "HotCommentIcon.h"

@implementation StatusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildSubviews];
    }
    return self;
}

- (void)buildSubviews{
    self.nameLabel.font = [UIFont systemFontOfSize:kStatusNameFont];
    self.nameLabel.textColor = [UIColor orangeColor];
    
    self.contentLabel.font = [UIFont systemFontOfSize:kStatusTextFont];
    self.contentLabel.preferredMaxLayoutWidth = kAppScreenWidth - 2*kStatusCellPaddingLeftRight;

    self.topicLabel = [UILabel new];
    self.topicLabel.font = [UIFont systemFontOfSize:kStatusTopicFont];
    self.topicLabel.textColor = kAppThemeColor;
    [self.contentView addSubview:self.topicLabel];

    self.picsContainer.type = PicsContainerTypeStatus;
    self.picsContainer.cell = self;
    
    self.commentBgView = [UIView new];
    self.commentBgView.backgroundColor = [UIColor colorWithRGB:0xF5F5F7];
    self.commentBgView.layer.cornerRadius = 5;
    self.commentBgView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.commentBgView];
    
    self.commentTagIcon = [HotCommentIcon buttonWithType:UIButtonTypeCustom];
    self.commentTagIcon.backgroundColor = [UIColor colorWithRGB:0xFC5D7F];
    [self.commentTagIcon setImage:[UIImage imageNamed:@"hot_comment"] forState:UIControlStateNormal];
    [self.commentTagIcon setTitle:@"神评" forState:UIControlStateNormal];
    [self.commentTagIcon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.commentTagIcon.titleLabel.font = [UIFont systemFontOfSize:11];
    self.commentTagIcon.layer.cornerRadius = 9;
    self.commentTagIcon.layer.masksToBounds = YES;
    [self.contentView addSubview:self.commentTagIcon];
    
    self.commentLikeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.commentLikeBtn setImage:[UIImage imageNamed:@"comment_dislike"] forState:UIControlStateNormal];
    self.commentLikeBtn.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [self.contentView addSubview:self.commentLikeBtn];
    
    self.commentPopularityLabel = [UILabel new];
    self.commentPopularityLabel.font = [UIFont systemFontOfSize:13];
    self.commentPopularityLabel.textColor = kAppThemeColor;
    self.commentPopularityLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.commentPopularityLabel];
    
    self.commentDislikeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.commentDislikeBtn setImage:[UIImage imageNamed:@"comment_dislike"] forState:UIControlStateNormal];
    [self.contentView addSubview:_commentDislikeBtn];
    
    self.commentTextLabel = [UILabel new];
    self.commentTextLabel.font = [UIFont systemFontOfSize:kStatusHotCommentTextFont];
    self.commentTextLabel.numberOfLines = 0;
    [self.contentView addSubview:self.commentTextLabel];
    
    self.commentPicsContainer = [[PicsContainerView alloc]init];
    self.commentPicsContainer.type = PicsContainerTypeStatusHotComment;
    self.commentPicsContainer.cell = self;
    [self.contentView addSubview:self.commentPicsContainer];
    
    self.shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareBtn setImage:[UIImage imageNamed:@"repost"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.shareBtn];

    self.commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.commentBtn setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.commentBtn];

    [self.likeBtn setImage:[UIImage imageNamed:@"dislike"] forState:UIControlStateNormal];
    self.likeBtn.transform = CGAffineTransformMakeRotation(-M_PI);
    
    [self.dislikeBtn setImage:[UIImage imageNamed:@"dislike"] forState:UIControlStateNormal];
    
    self.shareLabel = [UILabel new];
    self.shareLabel.font = [UIFont systemFontOfSize:13];
    self.shareLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:self.shareLabel];
    
    self.commentLabel = [UILabel new];
    self.commentLabel.font = [UIFont systemFontOfSize:13];
    self.commentLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:self.commentLabel];

    self.popularityLabel.font = [UIFont systemFontOfSize:13];
    self.popularityLabel.textColor = [UIColor lightGrayColor];

    self.bottomLine.backgroundColor = [UIColor colorWithRGB:0xEEEEEE];

}

- (void)fillCellData:(Status *)status{
    self.picsContainer.type = PicsContainerTypeStatus;
    if (status.comment_medias.count > 0) {
        self.commentPicsContainer.type = PicsContainerTypeStatusHotComment;
    }
    self.sts = status;
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:status.head_url]];
    self.nameLabel.text = status.user_name;
    self.contentLabel.text = status.content;
    self.topicLabel.text = status.topic_name;
    self.picsContainer.pics = status.medias;
    self.commentTextLabel.text = status.comment_content;
    self.commentPicsContainer.pics = status.comment_medias;

}

+ (BOOL)requiresConstraintBasedLayout{
    return YES;
}

- (void)updateConstraints{
    @weakify(self)
    [self.avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.top.equalTo(self.contentView.mas_top).with.offset(kStatusAvatarViewPaddingTop);
        make.left.equalTo(self.contentView.mas_left).with.offset(kStatusCellPaddingLeftRight);
        make.size.mas_equalTo(kStatusAvatarViewSize);
    }];
    
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.centerY.equalTo(self.avatarView.mas_centerY);
        make.left.equalTo(self.avatarView.mas_right).with.offset(kStatusNamePaddingLeft);
        make.right.equalTo(self.contentView.mas_right).with.offset(-50);
    }];
    
    [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.top.equalTo(self.avatarView.mas_bottom).with.offset(kStatusTextPaddingTop);
        make.left.equalTo(self.contentView.mas_left).with.offset(kStatusCellPaddingLeftRight);
        make.right.equalTo(self.contentView.mas_right).with.offset(-kStatusCellPaddingLeftRight);
    }];
    
    [self.topicLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.top.equalTo(self.contentLabel.mas_bottom).with.offset(kStatusTopicPaddingTop);
        make.left.equalTo(self.contentView.mas_left).with.offset(kStatusCellPaddingLeftRight);
        make.right.equalTo(self.contentView.mas_right).with.offset(-kStatusCellPaddingLeftRight);
        make.height.mas_equalTo(kStatusTopicLabelHeight);
    }];
    
    [self.picsContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.top.equalTo(self.topicLabel.mas_bottom).with.offset(kStatusImagePaddingTop);
        make.left.equalTo(self.contentView.mas_left).with.offset(kStatusCellPaddingLeftRight);
        make.right.equalTo(self.contentView.mas_right).with.offset(-kStatusCellPaddingLeftRight);
        make.height.mas_equalTo(self.sts.imageContainerHeight);
    }];
    
    [self.commentBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.top.equalTo(self.picsContainer.mas_bottom).with.offset(kStatusCommentBackgroundPaddingTop);
        make.left.equalTo(self.contentView.mas_left).with.offset(kStatusCellPaddingLeftRight);
        make.right.equalTo(self.contentView.mas_right).with.offset(-kStatusCellPaddingLeftRight);
        make.height.mas_equalTo(self.sts.commentBgHeight);
    }];
    
    [self.commentTagIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.top.equalTo(self.commentBgView.mas_top).with.offset(kStatusCommentBackgroundPadding);
        make.left.equalTo(self.commentBgView.mas_left).with.offset(kStatusCommentBackgroundPadding);
        make.size.mas_equalTo(CGSizeMake(kStatusCommentHotIconWidth, kStatusCommentHotIconHeight));
    }];
    
    [self.commentTextLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.top.equalTo(self.commentTagIcon.mas_bottom).with.offset(kStatusCommentTextPaddingTop);
        make.left.equalTo(self.commentBgView.mas_left).with.offset(kStatusCommentBackgroundPadding);
        make.right.equalTo(self.commentBgView.mas_right).with.offset(-kStatusCommentBackgroundPadding);
    }];
    
    [self.commentPicsContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.top.equalTo(self.commentTextLabel.mas_bottom).with.offset(kStatusCommentImagePaddingTop);
        make.left.equalTo(self.commentBgView.mas_left).with.offset(kStatusCommentBackgroundPadding);
        make.right.equalTo(self.commentBgView.mas_right).with.offset(-kStatusCommentBackgroundPadding);
        make.height.mas_equalTo(self.sts.commentImageContainerHeight);
    }];
    
    [self.shareBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-(kStatusToolbarButtonPaddingBottom + kStatusCellBottomLineHeight));
        make.left.equalTo(self.contentView.mas_left).with.offset(kStatusToolbarMargin);
        make.size.mas_equalTo(CGSizeMake(kStatusToolbarButtonItemWidth, kStatusToolbarButtonItemHeight));
    }];
    
    [self.commentBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-(kStatusToolbarButtonPaddingBottom + kStatusCellBottomLineHeight));
        make.left.equalTo(self.shareBtn.mas_right).with.offset(kStatusToolbarButtonDistance);
        make.size.mas_equalTo(CGSizeMake(kStatusToolbarButtonItemWidth, kStatusToolbarButtonItemHeight));
    }];
    
    [self.likeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-(kStatusToolbarButtonPaddingBottom + kStatusCellBottomLineHeight));
        make.left.equalTo(self.commentBtn.mas_right).with.offset(kStatusToolbarButtonDistance);
        make.size.mas_equalTo(CGSizeMake(kStatusToolbarButtonItemWidth, kStatusToolbarButtonItemHeight));
    }];
    [self.dislikeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-(kStatusToolbarButtonPaddingBottom + kStatusCellBottomLineHeight));
        make.left.equalTo(self.likeBtn.mas_right).with.offset(kStatusToolbarButtonDistance);
        make.size.mas_equalTo(CGSizeMake(kStatusToolbarButtonItemWidth, kStatusToolbarButtonItemHeight));
    }];
    
    [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.left.and.bottom.and.right.equalTo(self.contentView);
        make.height.mas_equalTo(kStatusCellBottomLineHeight);
    }];
    
    [super updateConstraints];
}

-(void)layoutSubviews{
    if (self.sts.comment_content.length == 0 && self.sts.comment_medias.count == 0) {
        self.commentBgView.hidden = YES;
        self.commentTagIcon.hidden = YES;
        self.commentTextLabel.hidden = YES;
        self.commentPicsContainer.hidden = YES;
    }else{
        self.commentBgView.hidden = NO;
        self.commentTagIcon.hidden = NO;
        if (self.sts.comment_content.length > 0) {
            self.commentTextLabel.hidden = NO;
        }
        if (self.sts.comment_medias.count > 0) {
            self.commentPicsContainer.hidden = NO;
        }
    }
    [super layoutSubviews];
}

-(void)prepareForReuse{
    //注意一定要调用父类方法[super prepareForReuse]
    [super prepareForReuse];
    self.sts = nil;
}




@end
