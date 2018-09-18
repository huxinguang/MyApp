//
//  HomeViewController.m
//  MyApp
//
//  Created by huxinguang on 2018/9/10.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "HomeViewController.h"
#import "FSScrollContentView.h"
#import "ChildViewController.h"
#import "StatusViewController.h"

@interface HomeViewController ()<FSPageContentViewDelegate,FSSegmentTitleViewDelegate>
@property (nonatomic, strong) FSPageContentView *pageContentView;
@property (nonatomic, strong) FSSegmentTitleView *segmentTitleView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    NSMutableArray *childVCs = [[NSMutableArray alloc]init];    
    for (NSString *title in @[@"推荐",@"关注",@"视频",@"图文"]) {
        StatusViewController *vc = [[StatusViewController alloc]init];
        vc.title = title;
        [childVCs addObject:vc];
    }
    self.pageContentView = [[FSPageContentView alloc]initWithFrame:CGRectMake(0, kAppStatusBarAndNavigationBarHeight, kAppScreenWidth, kAppScreenHeight - kAppStatusBarAndNavigationBarHeight - kAppTabbarHeight) childVCs:childVCs parentVC:self delegate:self];
    self.pageContentView.contentViewCurrentIndex = 0;
    //    self.pageContentView.contentViewCanScroll = NO;//设置滑动属性
    [self.view addSubview:_pageContentView];
    
}

//重写父类方法
-(void)configTitleView{
    self.segmentTitleView = [[FSSegmentTitleView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth - 50, 50) titles:@[@"推荐",@"关注",@"视频",@"图文"] delegate:self indicatorType:FSIndicatorTypeEqualTitle];
    self.segmentTitleView.titleSelectFont = [UIFont boldSystemFontOfSize:kAppNavigationTitleViewTitleFontSize];
    self.segmentTitleView.selectIndex = 0;
    self.navigationItem.titleView = self.segmentTitleView;
}

- (void)configLeftBarButtonItem{
    CBBarButtonConfiguration *config = [[CBBarButtonConfiguration alloc]init];
    config.type = CBBarButtonTypeBack;
    config.normalImageName = @"navi_search";
    self.leftBarButton = [[CBBarButton alloc]initWithConfiguration:config];
    [self.leftBarButton addTarget:self action:@selector(onSearchClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.leftBarButton];
}

- (void)onSearchClick{
    NSLog(@"点击搜索");
}


#pragma mark --
- (void)FSSegmentTitleView:(FSSegmentTitleView *)titleView startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex
{
    self.pageContentView.contentViewCurrentIndex = endIndex;
}

- (void)FSContenViewDidEndDecelerating:(FSPageContentView *)contentView startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex
{
    self.segmentTitleView.selectIndex = endIndex;
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
