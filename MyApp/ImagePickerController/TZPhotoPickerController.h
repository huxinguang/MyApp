//
//  TZPhotoPickerController.h
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

#define kItemMargin 4                                                                                                 //item间距
#define kItemsAtEachLine 3                                                                                            //每行显示多少个
#define kBottomConfirmBtnHeight 49                                                                                    //底部确定按钮的高度
#define kBottomConfirmBtnTitleFontSize 16                                                                             //确定按钮字体大小
#define kAlbumTableViewMarginTopBottom 10                                                                             //相册列表上下边距
#define kAlbumTableViewRowHeight 60                                                                                   //相册列表cell高度
#define kContainerViewMaxHeight (kAppScreenHeight-kAppStatusBarAndNavigationBarHeight-kBottomConfirmBtnHeight)/2      //相册列表最大高度

@class TZAlbumModel;
@interface TZPhotoPickerController : RootViewController

@property (nonatomic, strong) TZAlbumModel *model;

@end

@interface TitleViewButton : UIButton

@end

