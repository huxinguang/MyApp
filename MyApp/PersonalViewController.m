//
//  PersonalViewController.m
//  MyApp
//
//  Created by huxinguang on 2018/9/10.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "PersonalViewController.h"
#import "MyCell.h"

@interface PersonalViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UITableView *myTableView;
@property (nonatomic, strong)NSArray *cellTitles;
@property (nonatomic, strong)NSArray *cellIcons;

@end

@implementation PersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    CBTitleView *titleView = (CBTitleView *)self.navigationItem.titleView;
    [titleView setTitleString:@"我的"];
    self.cellIcons = @[@"mine_status",@"mine_comment",@"mine_history",@"mine_praise",@"mine_collect",@"mine_share"];
    self.cellTitles = @[@"我的帖子",@"我评论的",@"浏览历史",@"我赞过的",@"我收藏的",@"推荐给好友"];
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight-kAppTabbarHeight ) style:UITableViewStylePlain];
//    self.myTableView.backgroundColor = [UIColor redColor];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.rowHeight = 50;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.myTableView];
    self.myTableView.tableHeaderView = [self buildTableHeaderView];
    
}

- (void)configLeftBarButtonItem{
    
}

//- (UIStatusBarStyle)preferredStatusBarStyle{
//    return UIStatusBarStyleLightContent;
//}

- (UIView *)buildTableHeaderView{
    UIView *tbHeaderView = [UIView new];
    tbHeaderView.backgroundColor = [UIColor colorWithRGB:0xEFF0F7];
    tbHeaderView.bounds = CGRectMake(0, 0, kAppScreenWidth, kAppScreenWidth * 0.6);

    return tbHeaderView;
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.cellTitles.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CellIdentifier";
    MyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.iconView.image = [UIImage imageNamed:self.cellIcons[indexPath.row]];
    cell.titleLabel.text = self.cellTitles[indexPath.row];
    cell.countLabel.text = @"10";
    return cell;
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
