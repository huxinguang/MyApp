//
//  CommentViewController.m
//  MyApp
//
//  Created by huxinguang on 2018/9/3.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "ReplyDetailViewController.h"
#import "CommentCell.h"
#import "ReplyCell.h"
#import "YYPhotoGroupView.h"

@interface ReplyDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UITableView *replyTableView;

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
    
    self.inputToolbar.inputView.delegate = self;
    
    self.indicatorView  = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.center = self.view.center;
    [self.view addSubview:self.indicatorView];
    [self.view bringSubviewToFront:self.indicatorView];
    
}

- (UIView *)tableHeaderView{
    //选择在这里copy而不是直接用copy修饰Controller的sts属性，是为了评论详情数据更新时，同步数据到上级页面
    Status *sts = [self.sts copy];
    CommentCell *cell = [[CommentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.frame = CGRectMake(0, 0, kAppScreenWidth, self.sts.height - self.sts.commentBgHeight);
    /*由于strong修饰的Status类型的sts属性和上级页面里传过来的model之间的关系是两个指针指向同一个对象，
     这里改了sts，也会改变上级页面model,解决办法是让Status遵循NSCopying协议，使其具备拷贝功能*/
    sts.replies_count = 0;
    sts.replies = @[];
    [cell fillCellData:sts];
    [cell setNeedsUpdateConstraints];
    
    for (int i=0; i<cell.picsContainer.picViews.count; i++) {
        UIButton *btn = cell.picsContainer.picViews[i];
        btn.paramDic = @{@"cell":cell,@"pic_index":[NSNumber numberWithInt:i]};
        [btn addTarget:self action:@selector(clickImage:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (void)loadData{
    __weak typeof(self) weakSelf = self;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 20;
    NSDictionary *dic = @{@"page":@1,@"page_size":@20,@"comment_id":[NSNumber numberWithInteger:self.sts.status_id],@"user_id":@1};
    NSURLSessionDataTask *task = [manager GET:[NetworkUtil getCommentRepliesUrl] parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
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
                    return @{@"medias":[Media class], @"replies":[Status class]};
                }];
                [Media mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
                    return @{@"media_id":@"id"};
                }];
                //当前在主线程，将高度保存在model中，这个过程涉及复杂计算，应该放在子线程
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSDictionary *dic = response[@"data"];
                    self.dataArray = [Status mj_objectArrayWithKeyValuesArray:dic[@"replies"]];
                    [self calculateCellHeight];
                    //数据处理完毕回到主线程刷新UI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.replyTableView.tableHeaderView = [weakSelf tableHeaderView];
                        [weakSelf.replyTableView reloadData];
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
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:status.content];
        CGFloat commentTextHeight = status.content.length > 0 ? [self heightForYYLabelDisplayedString:str font:[UIFont systemFontOfSize:kCommentTextFont] maxWidth:content_max_width] : 0;
        
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
        
        status.commentTextHeight = commentTextHeight;
        status.commentImageContainerHeight = commentImageContainerHeight;
        status.height = kCommentAvatarViewMarginTop
        + kCommentAvatarViewSize.height
        + (status.content.length > 0 ? kCommentTextMarginTop : 0)
        + commentTextHeight
        + (status.medias.count > 0 ? kCommentImageMarginTop : 0)
        + commentImageContainerHeight
        + kCommentCellPaddingBottom;
    }];
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
    
    Status *sts = self.dataArray[indexPath.row];
    [cell fillCellData:sts];
    [cell setNeedsUpdateConstraints];
    
    for (int i=0; i<cell.picsContainer.picViews.count; i++) {
        UIButton *btn = cell.picsContainer.picViews[i];
        btn.paramDic = @{@"cell":cell,@"pic_index":[NSNumber numberWithInt:i]};
        [btn addTarget:self action:@selector(clickImage:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Status *comment = self.dataArray[indexPath.row];
    return comment.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (void)clickImage:(UIButton *)btn{
    ReplyCell *cell = btn.paramDic[@"cell"];
    int index = [btn.paramDic[@"pic_index"] intValue];
    NSMutableArray *items = [NSMutableArray new];
    NSArray<Media *> *medias = cell.picsContainer.pics;
    UIView *fromView = nil;
    for (int i=0; i<medias.count; i++) {
        UIButton *btnItem = cell.picsContainer.picViews[i];
        Media *m = medias[i];
        YYPhotoGroupItem *item = [YYPhotoGroupItem new];
        item.thumbView = btnItem.imageView;
        item.largeImageURL = [NSURL URLWithString:m.media_url];
        item.largeImageSize = CGSizeMake(m.media_width, m.media_height);
        [items addObject:item];
        if (i == index) {
            fromView = btnItem.imageView;
        }
    }
    YYPhotoGroupView *v = [[YYPhotoGroupView alloc] initWithGroupItems:items];
    [v presentFromImageView:fromView toContainer:self.navigationController.view animated:YES completion:nil];
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
