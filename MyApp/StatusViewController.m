//
//  StatusViewController.m
//  MyApp
//
//  Created by huxinguang on 2018/8/28.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "StatusViewController.h"
#import "Status.h"
#import "StatusCell.h"
#import "StatusDetailViewController.h"
#import "YYFPSLabel.h"

@interface StatusViewController ()<UITableViewDelegate,UITableViewDataSource>{
    
}
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UITableView *statusTableView;
@property (nonatomic, strong) YYFPSLabel *fpsLabel;

@end

@implementation StatusViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //在拉取详情页数据时， 如果帖子神评发生变化时，将
//    [self.statusTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = @[];
    [self buildSubviews];
    [self loadData];
}

- (void)buildSubviews{
    self.statusTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight - kAppStatusBarAndNavigationBarHeight - kAppTabbarHeight) style:UITableViewStylePlain];
    self.statusTableView.delegate = self;
    self.statusTableView.dataSource = self;
    self.statusTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.statusTableView];
    
    self.fpsLabel = [YYFPSLabel new];
    [self.fpsLabel sizeToFit];
    self.fpsLabel.bottom = self.view.height - 200;
    self.fpsLabel.left = 10;
    self.fpsLabel.alpha = 0;
    [self.view addSubview:self.fpsLabel];
    
    self.indicatorView  = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.center = self.view.center;
    
    [self.view addSubview:self.indicatorView];
    [self.view bringSubviewToFront:self.indicatorView];
    __weak typeof(self) weakSelf = self;
    self.statusTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData];
    }];
    
}

- (void)loadData{
    __weak typeof(self) weakSelf = self;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 20;
    NSURLSessionDataTask *task = [manager GET:@"http://127.0.0.1:8080/status/getStatusList?user_id=1&page=1&page_size=10" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
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
                    return @{@"medias":[Media class],@"comment_medias":[Media class]};
                }];
                [Media mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
                    return @{@"media_id":@"id"};
                }];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    weakSelf.dataArray = [Status mj_objectArrayWithKeyValuesArray:response[@"data"]];
                    [weakSelf calculateCellHeight];
                    //数据处理完毕回到主线程刷新UI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.statusTableView reloadData];
                        [weakSelf.statusTableView.mj_header endRefreshing];
                    });
                });
                
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",[error localizedDescription]);
        [weakSelf.statusTableView.mj_header endRefreshing];
    }];
    
    [self.indicatorView setAnimatingWithStateOfTask:task];
    
}

- (void)calculateCellHeight{
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Status *status = (Status *)obj;
        //帖子文本高度计算
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:status.content];
        CGFloat textHeight = status.content.length > 0 ? [self heightForYYLabelDisplayedString:str font:[UIFont systemFontOfSize:kStatusTextFont] maxWidth:kAppScreenWidth - 2*kStatusCellPaddingLeftRight] : 0;
        //帖子图片容器高度计算
        CGFloat imageContainerHeight = 0;
        switch (status.medias.count) {
            case 0:
            {
                imageContainerHeight = 0;
            }
                break;
            case 1:
            {
                CGFloat width = 0;
                if (status.medias[0].media_width > status.medias[0].media_height) {
                    width = kAppScreenWidth - 2*kStatusCellPaddingLeftRight;
                }else{
                    width = (kAppScreenWidth - 2*kStatusCellPaddingLeftRight)*0.667;
                }
                imageContainerHeight = width*status.medias[0].media_height/status.medias[0].media_width;
            }
                break;
            case 4:
            {
                imageContainerHeight = 2*kStatusPicHW + kStatusCellPaddingPic;
            }
                break;
            default:
            {
                int lineCount = (int)((status.medias.count - 1)/3) + 1;
                imageContainerHeight = lineCount*kStatusPicHW + (lineCount-1)*kStatusCellPaddingPic;
            }
                break;
        }
        //神评文本高度计算
        CGFloat commentTextHeight = status.comment_content.length > 0 ? [status.comment_content heightForFont:[UIFont systemFontOfSize:kStatusHotCommentTextFont] width:kAppScreenWidth - 2*kStatusCellPaddingLeftRight - 2*kStatusCommentBackgroundPadding] : 0;
        
        //神评图片容器高度计算
        CGFloat commentImageContainerHeight = 0;
        switch (status.comment_medias.count) {
            case 0:
            {
                commentImageContainerHeight = 0;
            }
                break;
            default:
            {
                int lineCount = (int)((status.medias.count - 1)/3) + 1;
                commentImageContainerHeight = lineCount*kStatusCommentPicHW + (lineCount-1)*kStatusCellPaddingPic;
            }
                break;
        }
        
        //神评背景总高度计算
        CGFloat commentBgHeight = 0;
        BOOL has_comment = (status.comment_content.length != 0) || (status.comment_medias.count != 0);
        if (!has_comment) {
            commentBgHeight = 0;
        }else{
            commentBgHeight = kStatusCommentBackgroundPadding
            + kStatusCommentHotIconHeight
            + (status.comment_content.length > 0 ? kStatusCommentTextPaddingTop : 0)
            + commentTextHeight
            + (status.comment_medias.count > 0 ? kStatusCommentImagePaddingTop : 0)
            + commentImageContainerHeight
            + kStatusCommentBackgroundPadding;
        }
        
        status.textHeight = textHeight;
        status.imageContainerHeight = imageContainerHeight;
        status.commentTextHeight = commentTextHeight;
        status.commentImageContainerHeight = commentImageContainerHeight;
        status.commentBgHeight = commentBgHeight;
        
        CGFloat height = kStatusAvatarViewPaddingTop
        + kStatusAvatarViewSize.height
        + (status.content ? kStatusTextPaddingTop: 0)
        + (status.content ? textHeight : 0)
        + kStatusTopicPaddingTop
        + kStatusTopicLabelHeight
        + (status.medias.count > 0 ? kStatusImagePaddingTop : 0)
        + imageContainerHeight
        + (has_comment == YES ? kStatusCommentBackgroundPaddingTop : 0)
        + commentBgHeight
        + kStatusToolbarButtonPaddingTop
        + kStatusToolbarButtonItemHeight
        + kStatusToolbarButtonPaddingBottom
        + kStatusCellBottomLineHeight;
        
        status.height = height;
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CellIdentifier";
    StatusCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[StatusCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    Status *status = self.dataArray[indexPath.row];
    [cell fillCellData:status];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    cell.shareBtn.tag = indexPath.row;
    cell.commentBtn.tag = indexPath.row;
    cell.likeBtn.tag = indexPath.row;

    [cell.shareBtn addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    [cell.commentBtn addTarget:self action:@selector(comment:) forControlEvents:UIControlEventTouchUpInside];
    [cell.likeBtn addTarget:self action:@selector(praise:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Status *status = self.dataArray[indexPath.row];
    return status.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



- (void)share:(UIButton *)btn{
    
    
}

- (void)comment:(UIButton *)btn{
    StatusDetailViewController *vc = [[StatusDetailViewController alloc]init];
    vc.sts = self.dataArray[btn.tag];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)praise:(UIButton *)btn{
    Status *status = self.dataArray[btn.tag];
    __weak typeof(self) weakSelf = self;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 20;
    NSDictionary *dic = @{@"user_id":@1,@"id":[NSNumber numberWithInteger:status.status_id],@"type":@1};
    [manager POST:@"http://127.0.0.1:8080/news/praise" parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = (NSDictionary *)responseObject;
            if ([[response objectForKey:@"code"] intValue] == 0) {
            
            }else{
                
            }
            NSLog(@"%@",response[@"message"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
    
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.fpsLabel.alpha == 0) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.fpsLabel.alpha = 1;
        } completion:NULL];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        if (self.fpsLabel.alpha != 0) {
            [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.fpsLabel.alpha = 0;
            } completion:NULL];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.fpsLabel.alpha != 0) {
        [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.fpsLabel.alpha = 0;
        } completion:NULL];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if (self.fpsLabel.alpha == 0) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.fpsLabel.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
