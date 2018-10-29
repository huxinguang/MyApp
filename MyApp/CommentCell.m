//
//  CommentCell.m
//  MyApp
//
//  Created by huxinguang on 2018/9/3.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "CommentCell.h"
#import "UIImageView+CornerRadius.h"

@implementation CommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
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
    [self.contentView addSubview:_timeLabel];
    
    self.replyBgView = [UIView new];
    self.replyBgView.backgroundColor = [UIColor colorWithRGB:0xF5F5F7];
    self.replyBgView.layer.cornerRadius = 5;
    self.replyBgView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.replyBgView];
    
    self.replyLabel1 = [YYLabel new];
    self.replyLabel1.font = [UIFont systemFontOfSize:kReplyLabelFont];
    self.replyLabel1.numberOfLines = 0;
    self.replyLabel1.preferredMaxLayoutWidth = kAppScreenWidth - 2*kCommentCellPaddingLeftRight - kCommentAvatarViewSize.width - kCommentNameMarginLeft - 2*kStatusCommentBackgroundPadding;
    self.replyLabel1.lineBreakMode = NSLineBreakByCharWrapping;
    [self.contentView addSubview:self.replyLabel1];

    self.replyLabel2 = [YYLabel new];
    self.replyLabel2.font = [UIFont systemFontOfSize:kReplyLabelFont];
    self.replyLabel2.numberOfLines = 0;
    self.replyLabel2.preferredMaxLayoutWidth = kAppScreenWidth - 2*kCommentCellPaddingLeftRight - kCommentAvatarViewSize.width - kCommentNameMarginLeft - 2*kStatusCommentBackgroundPadding;
    self.replyLabel2.lineBreakMode = NSLineBreakByCharWrapping;
    [self.contentView addSubview:self.replyLabel2];

    self.replyLabel3 = [YYLabel new];
    self.replyLabel3.font = [UIFont systemFontOfSize:kReplyLabelFont];
    [self.contentView addSubview:self.replyLabel3];
    
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
    
    if (status.replies_count > 2) {
        Status *reply1 = status.replies[0];
        NSMutableAttributedString *reply1_text = nil;
        if (reply1.medias.count > 0) {
            reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：[图片]%@",reply1.user_name,reply1.content]];
        }else{
            reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply1.user_name,reply1.content]];
        }

        reply1_text.font = [UIFont systemFontOfSize:kReplyLabelFont];
        [reply1_text setColor:[UIColor colorWithRGB:0x666666] range:NSMakeRange(reply1.user_name.length, reply1_text.length-reply1.user_name.length)];
        [reply1_text setTextHighlightRange:NSMakeRange(0, reply1.user_name.length) color:kAppThemeColor backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSLog(@"+++++++++++reply1_username");
        }];

        self.replyLabel1.attributedText = reply1_text;


        Status *reply2 = status.replies[1];
        NSMutableAttributedString *reply2_text = nil;
        if (reply2.medias.count > 0) {
            reply2_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：[图片]%@",reply2.user_name,reply2.content]];
        }else{
            reply2_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply2.user_name,reply2.content]];
        }
        
        reply2_text.font = [UIFont systemFontOfSize:kReplyLabelFont];
        [reply2_text setColor:[UIColor colorWithRGB:0x666666] range:NSMakeRange(reply2.user_name.length, reply2_text.length-reply2.user_name.length)];
        [reply2_text setTextHighlightRange:NSMakeRange(0, reply2.user_name.length) color:kAppThemeColor backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSLog(@"+++++++++++reply2_username");
        }];
        
        self.replyLabel2.attributedText = reply2_text;


        NSMutableAttributedString *reply3_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"查看%d条评论",status.replies_count]];
        reply3_text.font = [UIFont systemFontOfSize:kReplyLabelFont];
        @weakify(self)
        [reply3_text setTextHighlightRange:NSMakeRange(0, reply3_text.length) color:kAppThemeColor backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            @strongify(self)
            if (!self) return;
            NSLog(@"+++++++++++reply3");
            if (self.delegate && [self.delegate respondsToSelector:@selector(clickMoreReplyBtnAction:)]) {
                [self.delegate clickMoreReplyBtnAction:status];
            }
        }];
        self.replyLabel3.attributedText = reply3_text;

    }else if (status.replies_count == 2){
        Status *reply1 = status.replies[0];
        NSMutableAttributedString *reply1_text = nil;
        if (reply1.medias.count > 0) {
            reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：[图片]%@",reply1.user_name,reply1.content]];
        }else{
            reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply1.user_name,reply1.content]];
        }
        
        reply1_text.font = [UIFont systemFontOfSize:kReplyLabelFont];
        [reply1_text setColor:[UIColor colorWithRGB:0x666666] range:NSMakeRange(reply1.user_name.length, reply1_text.length-reply1.user_name.length)];
        [reply1_text setTextHighlightRange:NSMakeRange(0, reply1.user_name.length) color:kAppThemeColor backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSLog(@"+++++++++++reply1_username");
        }];
        
        self.replyLabel1.attributedText = reply1_text;
        
        
        Status *reply2 = status.replies[1];
        NSMutableAttributedString *reply2_text = nil;
        if (reply2.medias.count > 0) {
            reply2_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：[图片]%@",reply2.user_name,reply2.content]];
        }else{
            reply2_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply2.user_name,reply2.content]];
        }
        
        reply2_text.font = [UIFont systemFontOfSize:kReplyLabelFont];
        [reply2_text setColor:[UIColor colorWithRGB:0x666666] range:NSMakeRange(reply2.user_name.length, reply2_text.length-reply2.user_name.length)];
        [reply2_text setTextHighlightRange:NSMakeRange(0, reply2.user_name.length) color:kAppThemeColor backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSLog(@"+++++++++++reply2_username");
        }];
        
        self.replyLabel2.attributedText = reply2_text;
        
    }else if (status.replies_count == 1){
        Status *reply1 = status.replies[0];
        NSMutableAttributedString *reply1_text = nil;
        if (reply1.medias.count > 0) {
            reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：[图片]%@",reply1.user_name,reply1.content]];
        }else{
            reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply1.user_name,reply1.content]];
        }
        
        reply1_text.font = [UIFont systemFontOfSize:kReplyLabelFont];
        [reply1_text setColor:[UIColor colorWithRGB:0x666666] range:NSMakeRange(reply1.user_name.length, reply1_text.length-reply1.user_name.length)];
        [reply1_text setTextHighlightRange:NSMakeRange(0, reply1.user_name.length) color:kAppThemeColor backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSLog(@"+++++++++++reply1_username");
        }];
        
        self.replyLabel1.attributedText = reply1_text;
        
    }else{

    }
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
    
    [self.replyBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-kCommentCellPaddingBottom);
        make.left.and.right.equalTo(self.picsContainer);
        make.height.mas_equalTo(self.sts.commentBgHeight);
    }];

    if (self.sts.replies_count > 2) {
        [self.replyLabel1 mas_remakeConstraints:^(MASConstraintMaker *make) {
            @strongify(self)
            if (!self) return;
            make.top.equalTo(self.replyBgView.mas_top).with.offset(kReplyBackgroundPadding);
            make.left.equalTo(self.replyBgView.mas_left).with.offset(kReplyBackgroundPadding);
            make.right.equalTo(self.replyBgView.mas_right).with.offset(-kReplyBackgroundPadding);
        }];

        [self.replyLabel2 mas_remakeConstraints:^(MASConstraintMaker *make) {
            @strongify(self)
            if (!self) return;
            make.top.equalTo(self.replyLabel1.mas_bottom).with.offset(kReplyLabelDistance);
            make.left.and.right.equalTo(self.replyLabel1);
        }];

        [self.replyLabel3 mas_remakeConstraints:^(MASConstraintMaker *make) {
            @strongify(self)
            if (!self) return;
            make.top.equalTo(self.replyLabel2.mas_bottom).with.offset(kReplyLabelDistance);
            make.left.and.right.equalTo(self.replyLabel2);
        }];


    }else if (self.sts.replies_count == 2){
        [self.replyLabel1 mas_remakeConstraints:^(MASConstraintMaker *make) {
            @strongify(self)
            if (!self) return;
            
            make.top.equalTo(self.replyBgView.mas_top).with.offset(kReplyBackgroundPadding);
            make.left.equalTo(self.replyBgView.mas_left).with.offset(kReplyBackgroundPadding);
            make.right.equalTo(self.replyBgView.mas_right).with.offset(-kReplyBackgroundPadding);
        }];

        [self.replyLabel2 mas_remakeConstraints:^(MASConstraintMaker *make) {
            @strongify(self)
            if (!self) return;
            make.top.equalTo(self.replyLabel1.mas_bottom).with.offset(kReplyLabelDistance);
            make.left.and.right.equalTo(self.replyLabel1);
        }];

    }else if (self.sts.replies_count == 1){
        [self.replyLabel1 mas_remakeConstraints:^(MASConstraintMaker *make) {
            @strongify(self)
            if (!self) return;
            make.top.equalTo(self.replyBgView.mas_top).with.offset(kReplyBackgroundPadding);
            make.left.equalTo(self.replyBgView.mas_left).with.offset(kReplyBackgroundPadding);
            make.right.equalTo(self.replyBgView.mas_right).with.offset(-kReplyBackgroundPadding);
        }];
    }else{

    }
    
    [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.left.and.bottom.and.right.equalTo(self.contentView);
        make.height.mas_equalTo(kCommentCellBottomLineHeight);
    }];

    [super updateConstraints];
}

- (void)layoutSubviews{
    if (self.sts.replies_count > 2) {
        self.replyLabel1.hidden = NO;
        self.replyLabel2.hidden = NO;
        self.replyLabel3.hidden = NO;
        self.replyBgView.hidden = NO;

    }else if (self.sts.replies_count == 2){
        self.replyLabel1.hidden = NO;
        self.replyLabel2.hidden = NO;
        self.replyLabel3.hidden = YES;
        self.replyBgView.hidden = NO;

    }else if (self.sts.replies_count == 1){
        self.replyLabel1.hidden = NO;
        self.replyLabel2.hidden = YES;
        self.replyLabel3.hidden = YES;
        self.replyBgView.hidden = NO;
    }else{
        self.replyLabel1.hidden = YES;
        self.replyLabel2.hidden = YES;
        self.replyLabel3.hidden = YES;
        self.replyBgView.hidden = YES;
    }

    if (self.sts.medias.count == 0) {
        self.picsContainer.hidden = YES;
    }else{
        self.picsContainer.hidden = NO;
    }
    
    [super layoutSubviews];
}

- (void)prepareForReuse{
    [super prepareForReuse];
    //如果出现复用错误，那一定是约束加的不对
    self.sts = nil;
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
