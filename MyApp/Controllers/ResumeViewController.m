//
//  ResumeViewController.m
//  MyApp
//
//  Created by huxinguang on 2018/9/19.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "ResumeViewController.h"
#import <WebKit/WebKit.h>


@interface ResumeViewController ()<WKNavigationDelegate,WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation ResumeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.zhangu365.com/preview/CYDF6iPNMlQS"]]];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    //开了支持滑动返回
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.view addSubview:self.webView];
    
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
