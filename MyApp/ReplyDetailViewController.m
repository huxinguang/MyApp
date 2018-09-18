//
//  CommentViewController.m
//  MyApp
//
//  Created by huxinguang on 2018/9/3.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "ReplyDetailViewController.h"
#import "YYCategories.h"
#import "Comment.h"
#import "CommentCell.h"
#import "ReplyCell.h"

@interface ReplyDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UITableView *replyTableView;
@property (nonatomic, strong) Comment *comment_detail;

@end

@implementation ReplyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CBTitleView *titleView = (CBTitleView *)self.navigationItem.titleView;
    [titleView setTitleString:@"评论详情"];
    self.dataArray = @[];
    [self buildSubviews];
    [self loadData];
    
    
}

- (void)buildSubviews{
    self.replyTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kAppStatusBarAndNavigationBarHeight, kAppScreenWidth, kAppScreenHeight - kAppStatusBarAndNavigationBarHeight) style:UITableViewStylePlain];
    self.replyTableView.delegate = self;
    self.replyTableView.dataSource = self;
    self.replyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.replyTableView];
    
    
    self.indicatorView  = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.center = self.view.center;
    [self.view addSubview:self.indicatorView];
    [self.view bringSubviewToFront:self.indicatorView];
    
}

- (void)loadData{
    __weak typeof(self) weakSelf = self;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 20;
    NSDictionary *dic = @{@"page":@1,@"page_size":@20,@"comment_id":[NSNumber numberWithInteger:self.comment_id],@"user_id":@1};
    NSURLSessionDataTask *task = [manager GET:@"http://127.0.0.1:8080/news/getCommentDetailAndReplies" parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
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
                    NSDictionary *dic = response[@"data"];
                    self.comment_detail = [Comment mj_objectWithKeyValues:dic[@"detail"]];
                    self.dataArray = [Comment mj_objectArrayWithKeyValuesArray:dic[@"replies"]];
                    
                    [self calculateCellHeight];
                    //数据处理完毕回到主线程刷新UI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.replyTableView reloadData];
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
        CGFloat content_width = kAppScreenWidth - 15 - 32 - 10 - 20;
        CGFloat nameLabelHeight = [comment.user_name heightForFont:[UIFont systemFontOfSize:13] width:content_width];
        CGFloat timeLabelHeight = [comment.create_time heightForFont:[UIFont systemFontOfSize:11] width:content_width];
        CGFloat content_height = 0;
        CGFloat image_height = 0;
        CGFloat image_width = 0;
        if (comment.content) {
            NSString *str = nil;
            if (comment.reply_user_name) {
                str = [NSString stringWithFormat:@"回复@%@：%@",comment.reply_user_name,comment.content];
            }else{
                str = comment.content;
            }
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:str];
            content_height = [self heightForYYLabelDisplayedString:attributedString maxWidth:content_width];
        }
        if (comment.img_url) {
            if (comment.img_width >= comment.img_height) {
                image_width = content_width*0.618;
            }else{
                image_width = content_width*0.5;
            }
            image_height = image_width*comment.img_height/comment.img_width;
        }
        
        comment.content_height = content_height;
        comment.image_width = image_width;
        comment.image_height = image_height;
        comment.height = 10 + nameLabelHeight + 5 + timeLabelHeight + 8 + content_height + (content_height > 0 ? 8 : 0) + image_height + (image_height > 0 ? 10 : 0) + 0.5;
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
    ReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ReplyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Comment *comment = self.dataArray[indexPath.row];
    [cell fillCellData:comment];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];


    //    cell.praiseBtn.tag = indexPath.row;
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
