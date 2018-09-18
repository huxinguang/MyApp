//
//  StatusDetailViewController.m
//  MyApp
//
//  Created by huxinguang on 2018/9/3.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "StatusDetailViewController.h"
#import "YYCategories.h"
#import "Comment.h"
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
    NSDictionary *dic = @{@"page":@1,@"page_size":@20,@"status_id":[NSNumber numberWithInteger:self.status_id],@"user_id":@1};
    NSURLSessionDataTask *task = [manager GET:@"http://127.0.0.1:8080/news/getNewsDetail" parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = (NSDictionary *)responseObject;
            if ([[response objectForKey:@"code"] intValue] == 0) {
                [Comment mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
                    return @{@"comment_id":@"id"};
                }];
                [Comment mj_setupObjectClassInArray:^NSDictionary *{
                    return @{@"latest_replies":[Comment class]};
                }];
                //当前在主线程，将高度保存在model中，这个过程涉及复杂计算，应该放在子线程
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    weakSelf.dataArray = [Comment mj_objectArrayWithKeyValuesArray:response[@"data"]];
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
    
//    [self.indicatorView setAnimatingWithStateOfTask:task];
    
}

- (void)calculateCellHeight{
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Comment *comment = (Comment *)obj;
        CGFloat content_width = kAppScreenWidth - 10*2 - 40 - 10;
        CGFloat nameLabelHeight = [comment.user_name heightForFont:[UIFont systemFontOfSize:15] width:content_width];
        CGFloat content_height = 0;
        CGFloat image_height = 0;
        CGFloat image_width = 0;
        CGFloat reply_bgview_height = 0;
        CGFloat timeLabelHeight = [comment.create_time heightForFont:[UIFont systemFontOfSize:11] width:content_width];
        if (comment.content) {
            content_height = [comment.content heightForFont:[UIFont systemFontOfSize:15] width:content_width];
        }
        if (comment.img_url) {
            if (comment.img_width >= comment.img_height) {
                image_width = content_width*0.618;
            }else{
                image_width = content_width*0.5;
            }
            image_height = image_width*comment.img_height/comment.img_width;
        }
        if (comment.replies_count > 2) {
            Comment *reply1 = comment.latest_replies[0];
            
            NSMutableAttributedString *reply1_text = nil;
            if (reply1.img_url) {
                reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@ 查看图片",reply1.user_name,reply1.content]];
            }else{
                reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply1.user_name,reply1.content]];
            }
            
            Comment *reply2 = comment.latest_replies[1];
            NSMutableAttributedString *reply2_text = nil;
            if (reply2.img_url) {
                reply2_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@ 查看图片",reply2.user_name,reply2.content]];
            }else{
                reply2_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply2.user_name,reply2.content]];
            }
            
            NSMutableAttributedString *reply3_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"共%ld条回复 >",comment.replies_count]];
            
            reply_bgview_height = 5 +
            [self heightForYYLabelDisplayedString:reply1_text maxWidth:content_width - 2*5]
            + 5
            + [self heightForYYLabelDisplayedString:reply2_text maxWidth:content_width - 2*5]
            + 5
            + [self heightForYYLabelDisplayedString:reply3_text maxWidth:content_width - 2*5]
            + 5;
            
        }else if (comment.replies_count == 2){

            Comment *reply1 = comment.latest_replies[0];
            NSMutableAttributedString *reply1_text = nil;
            if (reply1.img_url) {
                reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@ 查看图片",reply1.user_name,reply1.content]];
            }else{
                reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply1.user_name,reply1.content]];
            }
            
            Comment *reply2 = comment.latest_replies[1];
            NSMutableAttributedString *reply2_text = nil;
            if (reply2.img_url) {
                reply2_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@ 查看图片",reply2.user_name,reply2.content]];
            }else{
                reply2_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply2.user_name,reply2.content]];
            }
            
            reply_bgview_height = 5 +
            [self heightForYYLabelDisplayedString:reply1_text maxWidth:content_width - 2*5]
            + 5
            + [self heightForYYLabelDisplayedString:reply2_text maxWidth:content_width - 2*5]
            + 5;
            
        }else if (comment.replies_count == 1){
            
            Comment *reply1 = comment.latest_replies[0];
            NSMutableAttributedString *reply1_text = nil;
            if (reply1.img_url) {
                reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@ 查看图片",reply1.user_name,reply1.content]];
            }else{
                reply1_text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@：%@",reply1.user_name,reply1.content]];
            }
            reply_bgview_height = 5 +
            [self heightForYYLabelDisplayedString:reply1_text maxWidth:content_width - 2*5]
            + 5;
        }else{
            reply_bgview_height = 0;
        }
        
        comment.content_height = content_height;
        comment.image_width = image_width;
        comment.image_height = image_height;
        comment.reply_bgview_height = reply_bgview_height;
        comment.height = 10 + nameLabelHeight + 10 + content_height + (content_height > 0 ? 10 : 0) + image_height + (image_height > 0 ? 10 : 0) + reply_bgview_height + (reply_bgview_height > 0 ? 10 : 0) + timeLabelHeight + 10 + 0.5;
    }];
}

- (CGFloat)heightForYYLabelDisplayedString:(NSMutableAttributedString *)attributedString maxWidth:(CGFloat)width{
    attributedString.yy_font = [UIFont systemFontOfSize:14];
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
    
    Comment *comment = self.dataArray[indexPath.row];
    [cell fillCellData:comment];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    //    [cell addConstraintForSubViews:comment];
    
    //    cell.replyBtn.tag = indexPath.row;
    //    cell.praiseBtn.tag = indexPath.row;
    //
    //    [cell.replyBtn addTarget:self action:@selector(reply:) forControlEvents:UIControlEventTouchUpInside];
    //    [cell.praiseBtn addTarget:self action:@selector(praise:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Comment *comment = self.dataArray[indexPath.row];
    return comment.height;
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
