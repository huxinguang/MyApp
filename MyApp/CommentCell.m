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
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildSubViews];
    }
    
    return self;
}

- (void)buildSubViews{
    _avatarView = [[UIImageView alloc]initWithRoundingRectImageView];
    [self.contentView addSubview:_avatarView];
    [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(10);
        make.left.equalTo(self.contentView.mas_left).with.offset(10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    _nameLabel = [UILabel new];
    _nameLabel.font = [UIFont systemFontOfSize:15];
    _nameLabel.textColor = [UIColor orangeColor];
    [self.contentView addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarView.mas_top);
        make.left.equalTo(self.avatarView.mas_right).with.offset(10);
        make.right.equalTo(self.contentView.mas_right).with.offset(-10);
    }];
    

    _contentLabel = [UILabel new];
    _contentLabel.font = [UIFont systemFontOfSize:15];
    _contentLabel.numberOfLines = 0;
    _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self.contentView addSubview:_contentLabel];
    
    _contentImgView = [[FLAnimatedImageView alloc]init];
    _contentImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_contentImgView];
    
    _replyBgView = [UIView new];
    _replyBgView.backgroundColor = [UIColor colorWithRGB:0xF5F5F5];
    [self.contentView addSubview:_replyBgView];
    
    _replayLabel1 = [YYLabel new];
    _replayLabel1.font = [UIFont systemFontOfSize:14];
    _replayLabel1.numberOfLines = 0;
    _replayLabel1.preferredMaxLayoutWidth = kAppScreenWidth - 2*10 - 40 - 10 - 2*5;
    _replayLabel1.lineBreakMode = NSLineBreakByCharWrapping;
    [self.contentView addSubview:_replayLabel1];
    
    _replayLabel2 = [YYLabel new];
    _replayLabel2.font = [UIFont systemFontOfSize:14];
    _replayLabel2.numberOfLines = 0;
    _replayLabel2.preferredMaxLayoutWidth = kAppScreenWidth - 2*10 - 40 - 10 - 2*5;
    _replayLabel2.lineBreakMode = NSLineBreakByCharWrapping;
    [self.contentView addSubview:_replayLabel2];
    
    _replayLabel3 = [YYLabel new];
    _replayLabel3.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_replayLabel3];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:11];
    _timeLabel.textColor = [UIColor colorWithRGB:0xB5B5B5];
    [self.contentView addSubview:_timeLabel];
    
    _thinLine = [[UIView alloc]init];
    _thinLine.backgroundColor = [UIColor colorWithRGB:0xE1E1E1];
    [self.contentView addSubview:_thinLine];
}

- (void)fillCellData:(Comment *)comment{
    self.comment = comment;
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:comment.head_url]];
    self.nameLabel.text = comment.user_name;
    if (comment.content) {
        self.contentLabel.text = comment.content;
    }
    if (comment.img_url) {
        if ([comment.img_url hasSuffix:@".gif"]) {
            FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:comment.img_url]]];
            self.contentImgView.animatedImage = image;
        }else{
           [self.contentImgView sd_setImageWithURL:[NSURL URLWithString:comment.img_url]];
        }
        
    }
    
    if (comment.replies_count > 2) {
        
        Comment *reply1 = comment.latest_replies[0];
        NSMutableAttributedString *reply1_text = nil;
        if (reply1.img_url) {
            reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@ 查看图片",reply1.user_name,reply1.content]];
        }else{
            reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply1.user_name,reply1.content]];
        }
        
        reply1_text.yy_font = [UIFont systemFontOfSize:14];
        [reply1_text yy_setColor:[UIColor colorWithRGB:0x666666] range:NSMakeRange(reply1.user_name.length, reply1.content.length + 1)];
    
        [reply1_text yy_setTextHighlightRange:NSMakeRange(0, reply1.user_name.length) color:[UIColor colorWithRGB:0x496EA2] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSLog(@"+++++++++++reply1_username");
        }];
        
        if (reply1.img_url) {
            [reply1_text yy_setTextHighlightRange:NSMakeRange(reply1.user_name.length + 1 + reply1.content.length + 1, 4) color:[UIColor colorWithRGB:0x496EA2] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                NSLog(@"+++++++++++查看图片");
            }];
        }
        
        self.replayLabel1.attributedText = reply1_text;
        
        
        Comment *reply2 = comment.latest_replies[1];
        NSMutableAttributedString *reply2_text = nil;
        if (reply2.img_url) {
            reply2_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@ 查看图片",reply2.user_name,reply2.content]];
        }else{
            reply2_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply2.user_name,reply2.content]];
        }
        
        reply2_text.yy_font = [UIFont systemFontOfSize:14];
        [reply2_text yy_setColor:[UIColor colorWithRGB:0x666666] range:NSMakeRange(reply2.user_name.length, reply2.content.length + 1)];
        
        [reply2_text yy_setTextHighlightRange:NSMakeRange(0, reply2.user_name.length) color:[UIColor colorWithRGB:0x496EA2] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSLog(@"+++++++++++reply1_username");
        }];
        
        if (reply2.img_url) {
            [reply2_text yy_setTextHighlightRange:NSMakeRange(reply2.user_name.length + 1 + reply2.content.length + 1, 4) color:[UIColor colorWithRGB:0x496EA2] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                NSLog(@"+++++++++++查看图片");
            }];
        }
        
        self.replayLabel2.attributedText = reply2_text;
        
        
        NSMutableAttributedString *reply3_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"共%d条回复 >",comment.replies_count]];
        reply3_text.yy_font = [UIFont systemFontOfSize:14];
        __weak typeof(self) weakSelf = self;
        [reply3_text yy_setTextHighlightRange:NSMakeRange(0, reply3_text.length) color:[UIColor colorWithRGB:0x496EA2] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSLog(@"+++++++++++reply3");
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(clickMoreReplyBtnAction:)]) {
                [weakSelf.delegate clickMoreReplyBtnAction:comment.comment_id];
            }
        }];
        self.replayLabel3.attributedText = reply3_text;
        
    }else if (comment.replies_count == 2){
        Comment *reply1 = comment.latest_replies[0];
        NSMutableAttributedString *reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply1.user_name,reply1.content]];
        reply1_text.yy_font = [UIFont systemFontOfSize:14];
        [reply1_text yy_setColor:[UIColor colorWithRGB:0x666666] range:NSMakeRange(reply1.user_name.length, reply1.content.length + 1)];
        [reply1_text yy_setTextHighlightRange:NSMakeRange(0, reply1.user_name.length) color:[UIColor colorWithRGB:0x496EA2] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSLog(@"+++++++++++reply1_username");
        }];
        self.replayLabel1.attributedText = reply1_text;
        
        
        Comment *reply2 = comment.latest_replies[1];
        NSMutableAttributedString *reply2_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply2.user_name,reply2.content]];
        reply2_text.yy_font = [UIFont systemFontOfSize:14];
        [reply2_text yy_setColor:[UIColor colorWithRGB:0x666666] range:NSMakeRange(reply2.user_name.length, reply2.content.length + 1)];
        [reply2_text yy_setTextHighlightRange:NSMakeRange(0, reply2.user_name.length) color:[UIColor colorWithRGB:0x496EA2] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSLog(@"+++++++++++reply2_username");
        }];
        self.replayLabel2.attributedText = reply2_text;
        
    }else if (comment.replies_count == 1){
        Comment *reply1 = comment.latest_replies[0];
        NSMutableAttributedString *reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply1.user_name,reply1.content]];
        reply1_text.yy_font = [UIFont systemFontOfSize:14];
        [reply1_text yy_setColor:[UIColor colorWithRGB:0x666666] range:NSMakeRange(reply1.user_name.length, reply1.content.length + 1)];
        [reply1_text yy_setTextHighlightRange:NSMakeRange(0, reply1.user_name.length) color:[UIColor colorWithRGB:0x496EA2] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSLog(@"+++++++++++reply1_username");
        }];
        self.replayLabel1.attributedText = reply1_text;
        
    }else{
        
    }
    self.timeLabel.text = comment.create_time;

}

+ (BOOL)requiresConstraintBasedLayout{
    return YES;
}

- (void)updateConstraints{
    [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(10);
        make.left.equalTo(self.nameLabel.mas_left);
        make.right.equalTo(self.contentView.mas_right).with.offset(-10);
    }];

    [self.contentImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLabel.mas_bottom).with.offset(10);
        make.left.equalTo(self.nameLabel.mas_left);
        self.contentImgSizeConstraint = make.size.mas_equalTo(CGSizeMake(self.comment.image_width, self.comment.image_height));
    }];

    [self.replyBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.comment.image_height > 0) {
            make.top.equalTo(self.contentImgView.mas_bottom).with.offset(10);
        }else{
            make.top.equalTo(self.contentLabel.mas_bottom).with.offset(10);
        }
        make.left.equalTo(self.nameLabel.mas_left);
        make.right.equalTo(self.nameLabel.mas_right);
        self.replyBgViewHeightConstraint = make.height.mas_equalTo(self.comment.reply_bgview_height);
    }];

    if (self.comment.replies_count > 2) {
        [self.replayLabel1 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.replyBgView.mas_top).with.offset(5);
            make.left.equalTo(self.replyBgView.mas_left).with.offset(5);
            make.right.equalTo(self.replyBgView.mas_right).with.offset(-5);
        }];

        [self.replayLabel2 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.replayLabel1.mas_bottom).with.offset(5);
            make.left.equalTo(self.replayLabel1.mas_left);
            make.right.equalTo(self.replayLabel1.mas_right);
        }];

        [self.replayLabel3 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.replayLabel2.mas_bottom).with.offset(5);
            make.left.equalTo(self.replayLabel2.mas_left);
            make.right.equalTo(self.replayLabel2.mas_right);
        }];


    }else if (self.comment.replies_count == 2){
        [self.replayLabel1 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.replyBgView.mas_top).with.offset(5);
            make.left.equalTo(self.replyBgView.mas_left).with.offset(5);
            make.right.equalTo(self.replyBgView.mas_right).with.offset(-5);
        }];

        [self.replayLabel2 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.replayLabel1.mas_bottom).with.offset(5);
            make.left.equalTo(self.replayLabel1.mas_left);
            make.right.equalTo(self.replayLabel1.mas_right);
        }];

    }else if (self.comment.replies_count == 1){
        [self.replayLabel1 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.replyBgView.mas_top).with.offset(5);
            make.left.equalTo(self.replyBgView.mas_left).with.offset(5);
            make.right.equalTo(self.replyBgView.mas_right).with.offset(-5);
        }];
    }else{

    }
    CGFloat content_width = kAppScreenWidth - 10*2 - 40 - 10;
    CGFloat timeLabelHeight = [self.comment.create_time heightForFont:[UIFont systemFontOfSize:11] width:content_width];

    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_bottom).with.offset(-(0.5+10+timeLabelHeight));
        make.left.equalTo(self.nameLabel.mas_left);
        make.right.equalTo(self.nameLabel.mas_right);
    }];

    [self.thinLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_bottom).with.offset(-0.5);
        make.left.equalTo(self.nameLabel.mas_left);
        make.right.equalTo(self.contentView.mas_right);
        make.height.mas_equalTo(0.5);
    }];

    [super updateConstraints];
}

- (void)layoutSubviews{
    if (self.comment.replies_count > 2) {
        self.replayLabel1.hidden = NO;
        self.replayLabel2.hidden = NO;
        self.replayLabel3.hidden = NO;

    }else if (self.comment.replies_count == 2){
        self.replayLabel1.hidden = NO;
        self.replayLabel2.hidden = NO;
        self.replayLabel3.hidden = YES;

    }else if (self.comment.replies_count == 1){
        self.replayLabel1.hidden = NO;
        self.replayLabel2.hidden = YES;
        self.replayLabel3.hidden = YES;
    }else{
        self.replayLabel1.hidden = YES;
        self.replayLabel2.hidden = YES;
        self.replayLabel3.hidden = YES;
    }

    [super layoutSubviews];
}

- (void)prepareForReuse{
    [super prepareForReuse];
    //如果出现复用错误，那一定是约束加的不对
    
//    [self.replyBgViewHeightConstraint uninstall];
    //关键，解决错乱问题
//    self.comment = nil;
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
