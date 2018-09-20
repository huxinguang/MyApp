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

    _topicLabel = [UILabel new];
    _topicLabel.font = [UIFont systemFontOfSize:kStatusTopicFont];
    _topicLabel.textColor = kAppThemeColor;
    [self.contentView addSubview:_topicLabel];

    self.picsContainer.type = PicsContainerTypeStatus;
    
    _commentBgView = [UIView new];
    _commentBgView.backgroundColor = [UIColor colorWithRGB:0xF5F5F7];
    _commentBgView.layer.cornerRadius = 5;
    _commentBgView.layer.masksToBounds = YES;
    [self.contentView addSubview:_commentBgView];
    
    _commentTagIcon = [HotCommentIcon buttonWithType:UIButtonTypeCustom];
    _commentTagIcon.backgroundColor = [UIColor colorWithRGB:0xFC5D7F];
    [_commentTagIcon setImage:[UIImage imageNamed:@"hot_comment"] forState:UIControlStateNormal];
    [_commentTagIcon setTitle:@"神评" forState:UIControlStateNormal];
    [_commentTagIcon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _commentTagIcon.titleLabel.font = [UIFont systemFontOfSize:11];
    _commentTagIcon.layer.cornerRadius = 9;
    _commentTagIcon.layer.masksToBounds = YES;
    [self.contentView addSubview:_commentTagIcon];
    
    _commentLikeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_commentLikeBtn setImage:[UIImage imageNamed:@"comment_dislike"] forState:UIControlStateNormal];
    _commentLikeBtn.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [self.contentView addSubview:_commentLikeBtn];
    
    _commentPopularityLabel = [UILabel new];
    _commentPopularityLabel.font = [UIFont systemFontOfSize:13];
    _commentPopularityLabel.textColor = kAppThemeColor;
    _commentPopularityLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_commentPopularityLabel];
    
    _commentDislikeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_commentDislikeBtn setImage:[UIImage imageNamed:@"comment_dislike"] forState:UIControlStateNormal];
    [self.contentView addSubview:_commentDislikeBtn];
    
    _commentTextLabel = [UILabel new];
    _commentTextLabel.font = [UIFont systemFontOfSize:kStatusHotCommentTextFont];
    _commentTextLabel.numberOfLines = 0;
    [self.contentView addSubview:_commentTextLabel];
    
    _commentPicsContainer = [[PicsContainerView alloc]init];
    _commentPicsContainer.type = PicsContainerTypeStatusHotComment;
    [self.contentView addSubview:_commentPicsContainer];
    
    _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shareBtn setImage:[UIImage imageNamed:@"repost"] forState:UIControlStateNormal];
    [self.contentView addSubview:_shareBtn];

    _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_commentBtn setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
    [self.contentView addSubview:_commentBtn];

    [self.likeBtn setImage:[UIImage imageNamed:@"dislike"] forState:UIControlStateNormal];
    self.likeBtn.transform = CGAffineTransformMakeRotation(-M_PI);
    
    [self.dislikeBtn setImage:[UIImage imageNamed:@"dislike"] forState:UIControlStateNormal];
    
    _shareLabel = [UILabel new];
    _shareLabel.font = [UIFont systemFontOfSize:13];
    _shareLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_shareLabel];
    
    _commentLabel = [UILabel new];
    _commentLabel.font = [UIFont systemFontOfSize:13];
    _commentLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_commentLabel];

    self.popularityLabel.font = [UIFont systemFontOfSize:13];
    self.popularityLabel.textColor = [UIColor lightGrayColor];

    self.bottomLine.backgroundColor = [UIColor colorWithRGB:0xEEEEEE];

}

- (void)clickImage:(UITapGestureRecognizer *)gesture{
    NSInteger tag = gesture.view.tag;
    Media *m = self.sts.medias[tag - 100];
    
}

- (void)fillCellData:(Status *)status{
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
    [self.avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(kStatusAvatarViewPaddingTop);
        make.left.equalTo(self.contentView.mas_left).with.offset(kStatusCellPaddingLeftRight);
        make.size.mas_equalTo(kStatusAvatarViewSize);
    }];
    
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.avatarView.mas_centerY);
        make.left.equalTo(self.avatarView.mas_right).with.offset(kStatusNamePaddingLeft);
        make.right.equalTo(self.contentView.mas_right).with.offset(-50);
    }];
    
    [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarView.mas_bottom).with.offset(kStatusTextPaddingTop);
        make.left.equalTo(self.contentView.mas_left).with.offset(kStatusCellPaddingLeftRight);
        make.right.equalTo(self.contentView.mas_right).with.offset(-kStatusCellPaddingLeftRight);
    }];
    
    [self.topicLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLabel.mas_bottom).with.offset(kStatusTopicPaddingTop);
        make.left.equalTo(self.contentView.mas_left).with.offset(kStatusCellPaddingLeftRight);
        make.right.equalTo(self.contentView.mas_right).with.offset(-kStatusCellPaddingLeftRight);
        make.height.mas_equalTo(kStatusTopicLabelHeight);
    }];
    
    [self.picsContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topicLabel.mas_bottom).with.offset(kStatusImagePaddingTop);
        make.left.equalTo(self.contentView.mas_left).with.offset(kStatusCellPaddingLeftRight);
        make.right.equalTo(self.contentView.mas_right).with.offset(-kStatusCellPaddingLeftRight);
        make.height.mas_equalTo(self.sts.imageContainerHeight);
    }];
    
    [self.commentBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.picsContainer.mas_bottom).with.offset(kStatusCommentBackgroundPaddingTop);
        make.left.equalTo(self.contentView.mas_left).with.offset(kStatusCellPaddingLeftRight);
        make.right.equalTo(self.contentView.mas_right).with.offset(-kStatusCellPaddingLeftRight);
        make.height.mas_equalTo(self.sts.commentBgHeight);
    }];
    
    [self.commentTagIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.commentBgView.mas_top).with.offset(kStatusCommentBackgroundPadding);
        make.left.equalTo(self.commentBgView.mas_left).with.offset(kStatusCommentBackgroundPadding);
        make.size.mas_equalTo(CGSizeMake(kStatusCommentHotIconWidth, kStatusCommentHotIconHeight));
    }];
    
    [self.commentTextLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.commentTagIcon.mas_bottom).with.offset(kStatusCommentTextPaddingTop);
        make.left.equalTo(self.commentBgView.mas_left).with.offset(kStatusCommentBackgroundPadding);
        make.right.equalTo(self.commentBgView.mas_right).with.offset(-kStatusCommentBackgroundPadding);
    }];
    
    [self.commentPicsContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.commentTextLabel.mas_bottom).with.offset(kStatusCommentImagePaddingTop);
        make.left.equalTo(self.commentBgView.mas_left).with.offset(kStatusCommentBackgroundPadding);
        make.right.equalTo(self.commentBgView.mas_right).with.offset(-kStatusCommentBackgroundPadding);
        make.height.mas_equalTo(self.sts.commentImageContainerHeight);
    }];
    
    [self.shareBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-(kStatusToolbarButtonPaddingBottom + kStatusCellBottomLineHeight));
        make.left.equalTo(self.contentView.mas_left).with.offset(kStatusToolbarMargin);
        make.size.mas_equalTo(CGSizeMake(kStatusToolbarButtonItemWidth, kStatusToolbarButtonItemHeight));
    }];
    
    [self.commentBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-(kStatusToolbarButtonPaddingBottom + kStatusCellBottomLineHeight));
        make.left.equalTo(self.shareBtn.mas_right).with.offset(kStatusToolbarButtonDistance);
        make.size.mas_equalTo(CGSizeMake(kStatusToolbarButtonItemWidth, kStatusToolbarButtonItemHeight));
    }];
    
    [self.likeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-(kStatusToolbarButtonPaddingBottom + kStatusCellBottomLineHeight));
        make.left.equalTo(self.commentBtn.mas_right).with.offset(kStatusToolbarButtonDistance);
        make.size.mas_equalTo(CGSizeMake(kStatusToolbarButtonItemWidth, kStatusToolbarButtonItemHeight));
    }];
    [self.dislikeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-(kStatusToolbarButtonPaddingBottom + kStatusCellBottomLineHeight));
        make.left.equalTo(self.likeBtn.mas_right).with.offset(kStatusToolbarButtonDistance);
        make.size.mas_equalTo(CGSizeMake(kStatusToolbarButtonItemWidth, kStatusToolbarButtonItemHeight));
    }];
    
    [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
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
