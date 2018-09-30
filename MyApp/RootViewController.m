//
//  RootViewController.m
//  MyApp
//
//  Created by huxinguang on 2018/9/11.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "RootViewController.h"
#import "PhotoPickerController.h"
#import "PickerImageManager.h"

@interface RootViewController ()<CBDefaultPageViewDelegate>

@end

@implementation RootViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.defaultPageView.delegate = self;
    [self configKeyboard];
    [self configWindowLevel];
    [self configTitleView];
    [self configLeftBarButtonItem];
    [self configRightBarButtonItem];
}

- (void)configKeyboard{
    @weakify(self);
    NSOperationQueue * mainQueue = [NSOperationQueue mainQueue];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                      object:nil
                                                       queue:mainQueue
                                                  usingBlock:^(NSNotification *noti)
    {
        @strongify(self);
        CGRect rect = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        double duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        //self可能为nil
        if (self && self->_inputToolbar) {
            [self refreshKeyboardStatusWithRect:rect duration:duration hide:NO];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification
                                                      object:nil
                                                       queue:mainQueue
                                                  usingBlock:^(NSNotification *noti)
    {
        @strongify(self);
        double duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        //self可能为nil
        if (self && self->_inputToolbar) {
            [self refreshKeyboardStatusWithRect:CGRectZero duration:duration hide:YES];
        }
    }];

}

- (void)configWindowLevel{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        window.windowLevel = UIWindowLevelNormal;
    });
}

- (void)configTitleView{
    self.titleView = [[CBTitleView alloc]initWithFrame:CGRectMake(0, 0, kAppNavigationTitleViewMaxWidth, kAppNavigationTitleViewHeight) style:CBTitleViewStyleNormal];
//    self.titleView.delegate = self;
    self.navigationItem.titleView = self.titleView;
}

//若不要返回按钮或者想替换成其他按钮可重写此方法
- (void)configLeftBarButtonItem{
    CBBarButtonConfiguration *config = [[CBBarButtonConfiguration alloc]init];
    config.type = CBBarButtonTypeBack;
    config.normalImageName = @"navi_back";
    self.leftBarButton = [[CBBarButton alloc]initWithConfiguration:config];
    [self.leftBarButton addTarget:self action:@selector(onLeftBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.leftBarButton];
}

- (void)configRightBarButtonItem{
    
}

- (void)onLeftBarButtonClick{
    [self.navigationController popViewControllerAnimated:YES];
}


- (CGFloat)heightForYYLabelDisplayedString:(NSMutableAttributedString *)attributedString font:(UIFont *)font maxWidth:(CGFloat)width{
    attributedString.font = font;
    CGSize labelSize = CGSizeMake(width, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:labelSize text:attributedString];
    CGFloat labelHeight = layout.textBoundingSize.height;
    return labelHeight;
}

-(InputToolBar *)inputToolbar{
    if (_inputToolbar == nil) {
        _inputToolbar = [[InputToolBar alloc]init];
        _inputToolbar.inputToolBarHeight = kInputBarOriginalHeight;
        _inputToolbar.inputView.delegate = self;
        [self.view addSubview:_inputToolbar];
        
        @weakify(self);
        [_inputToolbar mas_makeConstraints:^(MASConstraintMaker *make) {
            @strongify(self);
            make.bottom.equalTo(self.view.mas_bottom).with.offset(-kAppTabbarSafeBottomMargin);
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.height.mas_equalTo(self->_inputToolbar.inputToolBarHeight);//不使用self.inputToolbar避免死循环
        }];
        [_inputToolbar.imgEntryBtn addTarget:self action:@selector(onImgEntryBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _inputToolbar;
}

- (UIControl *)maskView{
    if (_maskView == nil) {
        _maskView = [WindowMaskView new];
        _maskView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        [_maskView addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:_maskView];
        [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(window.mas_top);
            make.left.equalTo(window.mas_left);
            make.right.equalTo(window.mas_right);
            make.bottom.equalTo(window.mas_bottom);
        }];
    }
    return _maskView;
}

-(void)onImgEntryBtnClick{
    [self hideKeyboard];
    if ([[PickerImageManager manager] authorizationStatusNotDetermined] || [[PickerImageManager manager] authorizationStatusAuthorized]) {
        PhotoPickerController *photoPickerVc = [[PhotoPickerController alloc] init];
        CBNavigationController *nav = [[CBNavigationController alloc]initWithRootViewController:photoPickerVc];
        [nav setNavigationBarWithType:CBNavigationBarTypeWhiteOpaque];
        [nav setStatusBarWithStyle:UIStatusBarStyleDefault];
        [self presentViewController:nav animated:YES completion:nil];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"未开启相册权限，是否去设置中开启？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
        [alert show];
    }
}

- (void)refreshKeyboardStatusWithRect:(CGRect)rect duration:(double)duration hide:(BOOL)hide{
    self.cuurentKeyboardHeight = rect.size.height;
    [UIView animateWithDuration:duration animations:^{
        //这里不能用self.inputToolbar,因为调用get方法会创建inputToolbar，而有些页面是没有inputToolbar的
        [self->_inputToolbar mas_updateConstraints:^(MASConstraintMaker *make) {
            if(hide){
                make.bottom.equalTo(self.view.mas_bottom).with.offset(-kAppTabbarSafeBottomMargin);
            }else{
                make.bottom.equalTo(self.view.mas_bottom).with.offset(-rect.size.height);
            }
        }];
    } completion:^(BOOL finished) {
        if (finished) {
            if (!hide) {
                self.maskView.marginBottom = self->_inputToolbar.inputToolBarHeight + rect.size.height;
                [self.maskView setNeedsUpdateConstraints];
            }
            
        }
    }];
    [self.view layoutIfNeeded];
}

- (void)hideKeyboard{
    [_maskView removeTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [_maskView removeFromSuperview];
    _maskView = nil;
    [self.view endEditing:YES];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView{
    //这里不能用self.inputToolbar,因为调用get方法会创建inputToolbar，而有些页面是没有inputToolbar的
    if (_inputToolbar) {
        CGFloat fixedWidth = textView.frame.size.width;
        CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGFloat textViewHeight = fmaxf(newSize.height, kTextViewOriginalHeight);
        _inputToolbar.inputToolBarHeight = textViewHeight + kTextViewMaginTopBottom*2;
        [_inputToolbar setNeedsUpdateConstraints];
        _maskView.marginBottom = self.cuurentKeyboardHeight + _inputToolbar.inputToolBarHeight;
        [_maskView setNeedsUpdateConstraints];
        
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


@implementation WindowMaskView

// tell UIKit that you are using AutoLayout
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

-(void)updateConstraints{
    @weakify(self);
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.bottom.equalTo(self.superview.mas_bottom).with.offset(-self.marginBottom);
    }];
    [super updateConstraints];
}


@end
