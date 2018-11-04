//
//  BaseStatusController.m
//  MyApp
//
//  Created by huxinguang on 2018/10/29.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "BaseStatusController.h"
#import "AssetPickerController.h"
#import "AssetPickerManager.h"
#import "AssetModel.h"
#import "MediaBrowseView.h"

@interface BaseStatusController ()<UITextViewDelegate,UIAlertViewDelegate,AssetPickerControllerDelegate>

@end

@implementation BaseStatusController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configKeyboard];
}

- (void)configKeyboard{
    @weakify(self)
    NSOperationQueue * mainQueue = [NSOperationQueue mainQueue];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                      object:nil
                                                       queue:mainQueue
                                                  usingBlock:^(NSNotification *noti)
     {
         @strongify(self)
         if (!self) return;
         CGRect rect = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
         double duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
         if (self->_inputToolbar) {
             [self refreshKeyboardStatusWithRect:rect duration:duration hide:NO];
         }
     }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification
                                                      object:nil
                                                       queue:mainQueue
                                                  usingBlock:^(NSNotification *noti)
     {
         @strongify(self);
         if (!self) return;
         double duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
         if (self->_inputToolbar) {
             [self refreshKeyboardStatusWithRect:CGRectZero duration:duration hide:YES];
         }
     }];
    
}

- (void)refreshKeyboardStatusWithRect:(CGRect)rect duration:(double)duration hide:(BOOL)hide{
    if (self == self.currentVC) {
        self.currentKeyboardHeight = rect.size.height;
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
        
        @weakify(self)
        [_inputToolbar mas_makeConstraints:^(MASConstraintMaker *make) {
            @strongify(self)
            if (!self) return;
            make.bottom.equalTo(self.view.mas_bottom).with.offset(-kAppTabbarSafeBottomMargin);
            make.left.and.right.equalTo(self.view);
            make.height.mas_equalTo(self->_inputToolbar.inputToolBarHeight);//不使用self.inputToolbar避免死循环
        }];
        [_inputToolbar.imgEntryBtn addTarget:self action:@selector(onImgEntryBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _inputToolbar;
}

- (UIControl *)maskView{
    if (_maskView == nil) {
        _maskView = [WindowMaskView new];
        _maskView.backgroundColor = [UIColor clearColor];
        [_maskView addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:_maskView];
        [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(window);
        }];
    }
    return _maskView;
}

-(void)onImgEntryBtnClick{
    [self hideKeyboard];
    @weakify(self)
    [[AssetPickerManager manager] handleAuthorizationWithCompletion:^(AuthorizationStatus aStatus) {
        @strongify(self)
        if (!self) return;
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (aStatus == AuthorizationStatusAuthorized) {
                [self showAssetPickerController];
            }else{
                [self showAlert];
            }
        });
    }];
}

- (void)showAssetPickerController{
    AssetPickerOptions *options = [[AssetPickerOptions alloc]init];
    options.maxAssetsCount = 9;
    options.videoPickable = YES;
    options.pickedAssetModels = [_inputToolbar.assets mutableCopy];
    AssetPickerController *photoPickerVc = [[AssetPickerController alloc] initWithOptions:options delegate:self];
    CBNavigationController *nav = [[CBNavigationController alloc]initWithRootViewController:photoPickerVc];
    [nav setNavigationBarWithType:CBNavigationBarTypeWhiteOpaque];
    [nav setStatusBarWithStyle:UIStatusBarStyleDefault];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)showAlert{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"未开启相册权限，是否去设置中开启？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
    [alert show];
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
        _inputToolbar.inputToolBarHeight = (textViewHeight + kTextViewMaginTopBottom*2) > kInputBarMaxlHeight ? kInputBarMaxlHeight : (textViewHeight + kTextViewMaginTopBottom*2);
        [_inputToolbar setNeedsUpdateConstraints];
        _maskView.marginBottom = self.currentKeyboardHeight + _inputToolbar.inputToolBarHeight;
        [_maskView setNeedsUpdateConstraints];
    }
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

#pragma mark - AssetPickerControllerDelegate

-(void)assetPickerController:(AssetPickerController *)picker didFinishPickingAssets:(NSArray<AssetModel *> *)assets{
    if (_inputToolbar) {
        if (_inputToolbar.assetsContainer.assets.count > 0) {
            if (assets.count == 0) {
                _inputToolbar.inputToolBarHeight -= kAssetsContainerHeight;
                _inputToolbar.containerHeight = 0;
                [_inputToolbar setNeedsUpdateConstraints];
            }
        }else{
            if (assets.count > 0) {
                _inputToolbar.inputToolBarHeight += kAssetsContainerHeight;
                _inputToolbar.containerHeight = kAssetsContainerHeight;
                [_inputToolbar setNeedsUpdateConstraints];
            }
        }
        _inputToolbar.assets = assets;
        _inputToolbar.assetsContainer.assets = assets;
        
    }
    
}

-(void)assetPickerControllerDidCancel:(AssetPickerController *)picker{
    NSLog(@"点击了取消");
}

#pragma mark - CellDelegate

- (void)didClickImageAtIndex:(NSInteger)index inCell:(id)cell isInSubPicContainer:(BOOL)isInSubPicContainer{
    NSMutableArray *items = @[].mutableCopy;
    NSArray<Media *> *medias = nil;
    if (isInSubPicContainer) {
        StatusCell *sc = (StatusCell *)cell;
        medias = sc.commentPicsContainer.pics;
    }else{
        BaseCell *bc = (BaseCell *)cell;
        medias = bc.picsContainer.pics;
    }
    UIView *fromView = nil;
    for (int i=0; i<medias.count; i++) {
        YYControl *imageView = nil;
        if (isInSubPicContainer) {
            StatusCell *sc = (StatusCell *)cell;
            imageView = sc.commentPicsContainer.picViews[i];
        }else{
            BaseCell *bc = (BaseCell *)cell;
            imageView = bc.picsContainer.picViews[i];
        }
        Media *m = medias[i];
        MediaItem *item = [MediaItem new];
        item.thumbView = imageView;
        item.largeMediaURL = [NSURL URLWithString:m.media_url];
        item.largeMediaSize = CGSizeMake(m.media_width, m.media_height);
        item.mediaType = (m.media_type == 1 ? MediaItemTypeImage: MediaItemTypeVideo);
        [items addObject:item];
        if (i == index) {
            fromView = imageView;
        }
    }
    MediaBrowseView *v = [[MediaBrowseView alloc] initWithItems:items];
    [v presentFromImageView:fromView toContainer:[UIApplication sharedApplication].keyWindow animated:YES completion:nil];
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
    @weakify(self)
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.bottom.equalTo(self.superview.mas_bottom).with.offset(-self.marginBottom);
    }];
    [super updateConstraints];
}


@end
