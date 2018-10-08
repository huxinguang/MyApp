//
//  StatusDetailViewController.m
//  MyApp
//
//  Created by huxinguang on 2018/9/3.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "StatusDetailViewController.h"
#import "CommentCell.h"
#import "ReplyDetailViewController.h"
#import "StatusCell.h"
#import "YYPhotoGroupView.h"

#import "MyApp-Swift.h"//OC 引用Swift类需要导入 "工程名-Swift.h"

@interface StatusDetailViewController ()<UITableViewDelegate,UITableViewDataSource,CommentCellDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UITableView *commentTableView;


@end

@implementation StatusDetailViewController

-(void)dealloc{
    NSLog(@"=========");
}

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
    
    self.commentTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.commentTableView.delegate = self;
    self.commentTableView.dataSource = self;
    self.commentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.commentTableView];
    @weakify(self)
    [self.commentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.top.equalTo(self.view.mas_top).with.offset(kAppStatusBarAndNavigationBarHeight);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.inputToolbar.mas_top);
    }];
    
    [self.view bringSubviewToFront:self.inputToolbar];
    
    self.indicatorView  = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.center = self.view.center;
    [self.view addSubview:self.indicatorView];
    [self.view bringSubviewToFront:self.indicatorView];
    
}

- (UIView *)tableHeaderView{
    //选择在这里copy而不是直接用copy修饰Controller的sts属性，是为了神评数据更新时，同步数据到上级页面
    Status *sts = [self.sts copy];
    StatusCell *cell = [[StatusCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.frame = CGRectMake(0, 0, kAppScreenWidth, self.sts.height - self.sts.commentBgHeight);
    /*由于strong修饰的Status类型的sts属性和上级页面里传过来的model之间的关系是两个指针指向同一个对象，
     这里改了sts，也会改变上级页面model,解决办法是让Status遵循NSCopying协议，使其具备拷贝功能*/
    sts.comment_content = @"";
    sts.comment_medias = @[];
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
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 20;
    NSDictionary *dic = @{@"page":@1,@"page_size":@20,@"status_id":[NSNumber numberWithInteger:self.sts.status_id],@"user_id":@1};
    @weakify(self)
    NSURLSessionDataTask *task = [manager GET:[NetworkUtil getStatusCommentsUrl] parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self)
        if (!self) return;
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
                    self.dataArray = [Status mj_objectArrayWithKeyValuesArray:response[@"data"]];
                    NSLog(@"%@",self.dataArray);
                    [self calculateCellHeight];
                    //数据处理完毕回到主线程刷新UI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.commentTableView.tableHeaderView = [self tableHeaderView];
                        [self.commentTableView reloadData];
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
            + [self heightForYYLabelDisplayedString:reply1_text font:[UIFont systemFontOfSize:kReplyLabelFont] maxWidth:reply_label_max_width]
            + kReplyLabelDistance
            + [self heightForYYLabelDisplayedString:reply2_text font:[UIFont systemFontOfSize:kReplyLabelFont] maxWidth:reply_label_max_width]
            + kReplyLabelDistance
            + [self heightForYYLabelDisplayedString:reply3_text font:[UIFont systemFontOfSize:kReplyLabelFont] maxWidth:reply_label_max_width]
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
            + [self heightForYYLabelDisplayedString:reply1_text font:[UIFont systemFontOfSize:kReplyLabelFont] maxWidth:reply_label_max_width]
            + kReplyLabelDistance
            + [self heightForYYLabelDisplayedString:reply2_text font:[UIFont systemFontOfSize:kReplyLabelFont] maxWidth:reply_label_max_width]
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
            + [self heightForYYLabelDisplayedString:reply1_text font:[UIFont systemFontOfSize:kReplyLabelFont] maxWidth:reply_label_max_width]
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
    
    for (int i=0; i<cell.picsContainer.picViews.count; i++) {
        UIButton *btn = cell.picsContainer.picViews[i];
        btn.paramDic = @{@"cell":cell,@"pic_index":[NSNumber numberWithInt:i]};
        [btn addTarget:self action:@selector(clickImage:) forControlEvents:UIControlEventTouchUpInside];
    }

    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Status *status = self.dataArray[indexPath.row];
    return status.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ReplyDetailViewController *vc = [[ReplyDetailViewController alloc]init];
    vc.sts = self.dataArray[indexPath.row];;
    [self.navigationController pushViewController:vc animated:YES];
}



- (void)reply:(UIButton *)btn{
    
    
}


- (void)praise:(UIButton *)btn{
    
    
}

- (void)clickImage:(UIButton *)btn{
    CommentCell *cell = btn.paramDic[@"cell"];
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

//- (void)onImgEntryBtnClick{
//    [super onImgEntryBtnClick];
//    
//    if ([[AssetPickerManager manager] authorizationStatusNotDetermined] || [[AssetPickerManager manager] authorizationStatusAuthorized]) {
//        AssetPickerController *photoPickerVc = [[AssetPickerController alloc] init];
//        CBNavigationController *nav = [[CBNavigationController alloc]initWithRootViewController:photoPickerVc];
//        [nav setNavigationBarWithType:CBNavigationBarTypeWhiteOpaque];
//        [nav setStatusBarWithStyle:UIStatusBarStyleDefault];
//        [self presentViewController:nav animated:YES completion:nil];
//        
//    } else {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"未开启相册权限，是否去设置中开启？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
//        [alert show];
//    }
//    
//}

#pragma mark - CommentCellDelegate

- (void)clickMoreReplyBtnAction:(Status *)status{
    ReplyDetailViewController *vc = [[ReplyDetailViewController alloc]init];
    vc.sts = status;
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        //取消
    }else{
        //去设置
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
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
