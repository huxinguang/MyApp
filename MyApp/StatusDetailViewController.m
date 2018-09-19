//
//  StatusDetailViewController.m
//  MyApp
//
//  Created by huxinguang on 2018/9/3.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "StatusDetailViewController.h"
#import "YYCategories.h"
#import "CommentCell.h"
#import "ReplyDetailViewController.h"

@interface StatusDetailViewController ()<UITableViewDelegate,UITableViewDataSource,CommentCellDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UITableView *commentTableView;

@end

@implementation StatusDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CBTitleView *titleView = (CBTitleView *)self.navigationItem.titleView;
    [titleView setTitleString:@"帖子详情"];
    self.dataArray = @[];
    [self buildSubviews];
    [self loadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)buildSubviews{
    self.commentTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kAppStatusBarAndNavigationBarHeight, kAppScreenWidth, kAppScreenHeight - kAppStatusBarAndNavigationBarHeight) style:UITableViewStylePlain];
    self.commentTableView.delegate = self;
    self.commentTableView.dataSource = self;
    self.commentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.commentTableView];
    
    self.indicatorView  = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.center = self.view.center;
    [self.view addSubview:self.indicatorView];
    [self.view bringSubviewToFront:self.indicatorView];
    
}

- (void)loadData{
    __weak typeof(self) weakSelf = self;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 20;
    NSDictionary *dic = @{@"page":@1,@"page_size":@20,@"status_id":[NSNumber numberWithInteger:self.sts.status_id],@"user_id":@1};
    NSURLSessionDataTask *task = [manager GET:@"http://2c66eff1.ngrok.io/status/getStatusComments" parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = (NSDictionary *)responseObject;
            if ([[response objectForKey:@"code"] intValue] == 0) {
                [Status mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
                    return @{@"status_id":@"id",
                             @"user_name":@"name"
                             };
                }];
                [Status mj_setupObjectClassInArray:^NSDictionary *{
                    return @{@"medias":[Media class],@"comment_medias":[Media class], @"replies":[Status class]};
                }];
                [Media mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
                    return @{@"media_id":@"id"};
                }];
                //当前在主线程，将高度保存在model中，这个过程涉及复杂计算，应该放在子线程
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    weakSelf.dataArray = [Status mj_objectArrayWithKeyValuesArray:response[@"data"]];
                    NSLog(@"%@",weakSelf.dataArray);
                    [self calculateCellHeight];
                    //数据处理完毕回到主线程刷新UI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.commentTableView reloadData];
                    });
                });
                
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
    
    [self.indicatorView setAnimatingWithStateOfTask:task];
    
}

- (void)calculateCellHeight{
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Status *status = (Status *)obj;
        
        //评论文本高度计算
        CGFloat content_max_width = kAppScreenWidth - 2*kCommentCellPaddingLeftRight - kCommentAvatarViewSize.width - kCommentNameMarginLeft;
        CGFloat commentTextHeight = status.content.length > 0 ? [status.content heightForFont:[UIFont systemFontOfSize:kCommentTextFont] width:content_max_width] : 0;
        
        //评论图片容器高度计算
        CGFloat commentImageContainerHeight = 0;
        switch (status.medias.count) {
            case 0:
            {
                commentImageContainerHeight = 0;
            }
                break;
            default:
            {
                int lineCount = (int)((status.medias.count - 1)/3) + 1;
                commentImageContainerHeight = lineCount*kCommentPicHW + (lineCount-1)*kStatusCellPaddingPic;
            }
                break;
        }
        
        //回复背景高度计算
        CGFloat reply_bgview_height = 0;
        CGFloat reply_label_max_width = content_max_width - 2*kReplyBackgroundPadding;
        if (status.replies_count > 2) {
            Status *reply1 = status.replies[0];

            NSMutableAttributedString *reply1_text = nil;
            if (reply1.medias.count > 0) {
                reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：[图片]%@",reply1.user_name,reply1.content]];
            }else{
                reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply1.user_name,reply1.content]];
            }

            Status *reply2 = status.replies[1];
            NSMutableAttributedString *reply2_text = nil;
            if (reply2.medias.count > 0) {
                reply2_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：[图片]%@",reply2.user_name,reply2.content]];
            }else{
                reply2_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply2.user_name,reply2.content]];
            }

            NSMutableAttributedString *reply3_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"查看%d条评论",status.replies_count]];
            
            reply_bgview_height = kReplyBackgroundPadding
            + [self heightForYYLabelDisplayedString:reply1_text maxWidth:reply_label_max_width]
            + kReplyLabelDistance
            + [self heightForYYLabelDisplayedString:reply2_text maxWidth:reply_label_max_width]
            + kReplyLabelDistance
            + [self heightForYYLabelDisplayedString:reply3_text maxWidth:reply_label_max_width]
            + kReplyBackgroundPadding;
            
        }else if (status.replies_count == 2){
            Status *reply1 = status.replies[0];
            NSMutableAttributedString *reply1_text = nil;
            if (reply1.medias.count > 0) {
                reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：[图片]%@",reply1.user_name,reply1.content]];
            }else{
                reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply1.user_name,reply1.content]];
            }
            
            Status *reply2 = status.replies[1];
            NSMutableAttributedString *reply2_text = nil;
            if (reply2.medias.count > 0) {
                reply2_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：[图片]%@",reply2.user_name,reply2.content]];
            }else{
                reply2_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply2.user_name,reply2.content]];
            }
            
            reply_bgview_height = kReplyBackgroundPadding
            + [self heightForYYLabelDisplayedString:reply1_text maxWidth:reply_label_max_width]
            + kReplyLabelDistance
            + [self heightForYYLabelDisplayedString:reply2_text maxWidth:reply_label_max_width]
            + kReplyBackgroundPadding;
            
        }else if (status.replies_count == 1){
            Status *reply1 = status.replies[0];
            NSMutableAttributedString *reply1_text = nil;
            if (reply1.medias.count > 0) {
                reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：[图片]%@",reply1.user_name,reply1.content]];
            }else{
                reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply1.user_name,reply1.content]];
            }
            
            reply_bgview_height = kReplyBackgroundPadding
            + [self heightForYYLabelDisplayedString:reply1_text maxWidth:reply_label_max_width]
            + kReplyBackgroundPadding;
        
        }else{
            reply_bgview_height = 0;
        }

        status.commentTextHeight = commentTextHeight;
        status.commentImageContainerHeight = commentImageContainerHeight;
        status.commentBgHeight = reply_bgview_height;
        status.height = kCommentAvatarViewMarginTop
        + kCommentAvatarViewSize.height
        + (status.content.length > 0 ? kCommentTextMarginTop : 0)
        + commentTextHeight
        + (status.medias.count > 0 ? kCommentImageMarginTop : 0)
        + commentImageContainerHeight
        + (status.replies_count > 0 ? kReplyBackgroundMarginTop : 0)
        + reply_bgview_height
        + kCommentCellPaddingBottom;
    }];
}

- (CGFloat)heightForYYLabelDisplayedString:(NSMutableAttributedString *)attributedString maxWidth:(CGFloat)width{
    attributedString.yy_font = [UIFont systemFontOfSize:kReplyLabelFont];
    CGSize labelSize = CGSizeMake(width, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:labelSize text:attributedString];
    CGFloat labelHeight = layout.textBoundingSize.height;
    return labelHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"CellIdentifier";
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[CommentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.delegate = self;
    
    Status *status = self.dataArray[indexPath.row];
    [cell fillCellData:status];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Status *status = self.dataArray[indexPath.row];
    return status.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



- (void)reply:(UIButton *)btn{
    
    
}


- (void)praise:(UIButton *)btn{
    
    
}

#pragma mark - CommentCellDelegate

-(void)clickMoreReplyBtnAction:(int)comment_id{
    ReplyDetailViewController *vc = [[ReplyDetailViewController alloc]init];
    vc.comment_id = comment_id;
    [self.navigationController pushViewController:vc animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
