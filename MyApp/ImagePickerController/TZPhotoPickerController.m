//
//  TZPhotoPickerController.m
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "TZPhotoPickerController.h"
#import "TZAssetCell.h"
#import "TZAssetModel.h"
#import "TZImageManager.h"
#import "CBTitleView.h"
#import "CBBarButton.h"
#import "AlbumCell.h"

@interface TZPhotoPickerController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UICollectionView *collectionView;
@property (nonatomic, strong)NSMutableArray<TZAssetModel *> *photoArr;
@property (nonatomic, strong)NSMutableArray *selectedPhotoArr;
@property (nonatomic, strong)UIButton *bottomConfirmBtn;
@property (nonatomic, strong)UITableView *albumTableView;
@property (nonatomic, strong)UIView *containerView;
@property (nonatomic, strong)NSMutableArray<TZAlbumModel *> *albumArr;
@property (nonatomic, strong)UIControl *maskView;
@property (nonatomic, strong)TitleViewButton *titleBtn;
@property (nonatomic, assign)CGFloat containerViewHeight;
@end

@implementation TZPhotoPickerController


- (NSMutableArray *)selectedPhotoArr {
    if (_selectedPhotoArr == nil) _selectedPhotoArr = [NSMutableArray array];
    return _selectedPhotoArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self configMaskView];
    
    __weak typeof(self) weakSelf = self;
    [[TZImageManager manager] getAssetsFromFetchResult:self.model.result allowPickingVideo:YES completion:^(NSArray<TZAssetModel *> *models) {
        weakSelf.photoArr = [NSMutableArray arrayWithArray:models];
        [weakSelf configCollectionView];
        [weakSelf configBottomConfirmBtn];
    }];
    
    [[TZImageManager manager] getAllAlbums:YES completion:^(NSArray<TZAlbumModel *> *models) {
        weakSelf.albumArr = [NSMutableArray arrayWithArray:models];
        [weakSelf configAlbumTableView];
    }];
    
    
}

- (void)configMaskView{
    self.maskView = [UIControl new];
    self.maskView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    self.maskView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.maskView];
    [self.maskView addTarget:self action:@selector(onClickMaskView) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configLeftBarButtonItem{
    CBBarButtonConfiguration *config = [[CBBarButtonConfiguration alloc]init];
    config.type = CBBarButtonTypeImage;
    config.normalImageName = @"picker_cancel";
    CBBarButton *leftBarButton = [[CBBarButton alloc]initWithConfiguration:config];
    [leftBarButton addTarget:self action:@selector(onLeftBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBarButton];
}

- (void)configTitleView{
    self.titleBtn = [TitleViewButton buttonWithType:UIButtonTypeCustom];
    [self.titleBtn setImage:[UIImage imageNamed:@"picker_arrow"] forState:UIControlStateNormal];
    [self.titleBtn setTitle:@"相机胶卷" forState:UIControlStateNormal];
    [self.titleBtn setTitleColor:kAppThemeColor forState:UIControlStateNormal];
    self.titleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleBtn.bounds = CGRectMake(0, 0, 70, 44);
    self.titleBtn.selected = NO;
    [self.titleBtn addTarget:self action:@selector(onTitleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = self.titleBtn;
}

- (void)configRightBarButtonItem{
    
}

- (void)onLeftBarButtonClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)configCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemWH = (self.view.width - (kItemsAtEachLine-1)*kItemMargin)/kItemsAtEachLine;
    layout.itemSize = CGSizeMake(itemWH, itemWH);
    layout.minimumInteritemSpacing = kItemMargin;
    layout.minimumLineSpacing = kItemMargin;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight-kAppStatusBarAndNavigationBarHeight-kBottomConfirmBtnHeight) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:self.collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:@"TZAssetCell" bundle:nil] forCellWithReuseIdentifier:@"TZAssetCell"];
}

- (void)configAlbumTableView{
    CGFloat height = kAlbumTableViewMarginTopBottom*2 + kAlbumTableViewRowHeight*self.albumArr.count;
    self.containerViewHeight = height > kContainerViewMaxHeight ? kContainerViewMaxHeight : height;
    
    self.containerView = [UIView new];
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.frame = CGRectMake(0, -self.containerViewHeight, kAppScreenWidth, self.containerViewHeight);
    [self.view addSubview:self.containerView];
    
    CGFloat albumTableViewHeight = self.containerViewHeight - 2*kAlbumTableViewMarginTopBottom;
    self.albumTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kAlbumTableViewMarginTopBottom, kAppScreenWidth, albumTableViewHeight) style:UITableViewStylePlain];
    self.albumTableView.delegate = self;
    self.albumTableView.dataSource = self;
    self.albumTableView.rowHeight = kAlbumTableViewRowHeight;
    self.albumTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.containerView addSubview:self.albumTableView];
}



- (void)configBottomConfirmBtn {
    self.bottomConfirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.bottomConfirmBtn.frame = CGRectMake(0, kAppScreenHeight - kBottomConfirmBtnHeight - kAppStatusBarAndNavigationBarHeight, kAppScreenWidth, kBottomConfirmBtnHeight);
    self.bottomConfirmBtn.backgroundColor = [UIColor whiteColor];
    self.bottomConfirmBtn.titleLabel.font = [UIFont systemFontOfSize:kBottomConfirmBtnTitleFontSize];
    [self.bottomConfirmBtn addTarget:self action:@selector(onConfirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomConfirmBtn setTitle:@"确定(0/9)" forState:UIControlStateNormal];
    [self.bottomConfirmBtn setTitleColor:kAppThemeColor forState:UIControlStateNormal];
    [self.bottomConfirmBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    self.bottomConfirmBtn.enabled = NO;
    [self.view addSubview:self.bottomConfirmBtn];
}

- (void)onConfirmBtnClick {
    NSMutableArray *photos = @[].mutableCopy;
    NSMutableArray *assets = @[].mutableCopy;
    NSMutableArray *infoArr = @[].mutableCopy;
    __weak typeof (self) weakSelf = self;
    for (NSInteger i = 0; i < _selectedPhotoArr.count; i++) {
        TZAssetModel *model = _selectedPhotoArr[i];
        [[TZImageManager manager] getPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info) {
            if (photo) [photos addObject:photo];
            if (info) [infoArr addObject:info];
            if (photos.count < weakSelf.selectedPhotoArr.count) return;
            
        }];
    }
}

- (void)onTitleBtnClick:(TitleViewButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self.view insertSubview:self.maskView belowSubview:self.containerView];
    }
    [UIView animateWithDuration:0.35 animations:^{
        if (btn.selected) {
            CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
            btn.imageView.transform = transform;
            CGRect frame = self.containerView.frame;
            frame.origin.y += self.containerViewHeight;
            self.containerView.frame = frame;
            self.maskView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.2];
        }else{
            btn.imageView.transform = CGAffineTransformIdentity;
            CGRect frame = self.containerView.frame;
            frame.origin.y -= self.containerViewHeight;
            self.containerView.frame = frame;
            self.maskView.backgroundColor = [UIColor clearColor];
        }
    } completion:^(BOOL finished) {
        if (!btn.selected) {
            [self.view insertSubview:self.maskView belowSubview:self.collectionView];
        }
    }];
}

- (void)onClickMaskView{
    [self onTitleBtnClick:self.titleBtn];
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photoArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TZAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TZAssetCell" forIndexPath:indexPath];
    TZAssetModel *model = _photoArr[indexPath.row];
    cell.model = model;
    typeof(cell) weakCell = cell;
    cell.didSelectPhotoBlock = ^(BOOL isSelected) {
        // 1. 取消选择
        if (isSelected) {
            weakCell.selectPhotoButton.selected = NO;
            model.isSelected = NO;
            [self.selectedPhotoArr removeObject:model];
            [self refreshBottomConfirmBtn];
        } else {
            // 2. 选择照片,检查是否超过了最大个数的限制
            
            if (self.selectedPhotoArr.count < 9) {
                weakCell.selectPhotoButton.selected = YES;
                model.isSelected = YES;
                [self.selectedPhotoArr addObject:model];
                [self refreshBottomConfirmBtn];
            } else {
//                [NSString stringWithFormat:@"最多选择%zd张照片",9];
            }
        }
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TZAssetModel *model = _photoArr[indexPath.row];
   
}


#pragma mark - UITableViewDelegate,UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.albumArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CellIdentifier";
    AlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"AlbumCell" owner:self options:nil] lastObject];
    }
    cell.model = self.albumArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}




- (void)refreshBottomConfirmBtn {

}


- (void)getSelectedPhotoBytes {
    [[TZImageManager manager] getPhotosBytesWithArray:_selectedPhotoArr completion:^(NSString *totalBytes) {
        
    }];
}

@end


@implementation TitleViewButton

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(0, 0, contentRect.size.width-7.0, contentRect.size.height);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    return CGRectMake(contentRect.size.width - 7.0, contentRect.size.height/2 - 7.0/2, 7.0, 7.0);
}

@end


