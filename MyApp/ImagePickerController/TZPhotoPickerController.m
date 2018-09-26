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

@interface TZPhotoPickerController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UICollectionView *collectionView;
@property (nonatomic, strong)NSMutableArray *photoArr;
@property (nonatomic, strong)NSMutableArray *selectedPhotoArr;
@property (nonatomic, strong)UIButton *bottomConfirmBtn;
@property (nonatomic, strong)UITableView *albumTableView;
@property (nonatomic, strong)NSMutableArray *albumArr;
@end

@implementation TZPhotoPickerController


- (NSMutableArray *)selectedPhotoArr {
    if (_selectedPhotoArr == nil) _selectedPhotoArr = [NSMutableArray array];
    return _selectedPhotoArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
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

- (void)configLeftBarButtonItem{
    CBBarButtonConfiguration *config = [[CBBarButtonConfiguration alloc]init];
    config.type = CBBarButtonTypeImage;
    config.normalImageName = @"picker_cancel";
    CBBarButton *leftBarButton = [[CBBarButton alloc]initWithConfiguration:config];
    [leftBarButton addTarget:self action:@selector(onLeftBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBarButton];
}

- (void)configTitleView{
    TitleViewButton *titleBtn = [TitleViewButton buttonWithType:UIButtonTypeCustom];
    [titleBtn setImage:[UIImage imageNamed:@"picker_arrow"] forState:UIControlStateNormal];
    [titleBtn setTitle:@"相机胶卷" forState:UIControlStateNormal];
    [titleBtn setTitleColor:kAppThemeColor forState:UIControlStateNormal];
    titleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    titleBtn.bounds = CGRectMake(0, 0, 70, 44);
    titleBtn.selected = NO;
    [titleBtn addTarget:self action:@selector(onTitleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleBtn;
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
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - kBottomConfirmBtnHeight) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:self.collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:@"TZAssetCell" bundle:nil] forCellWithReuseIdentifier:@"TZAssetCell"];
}

- (void)configAlbumTableView{
    self.albumTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, -kAlbumTableViewHeight, kAppScreenWidth, kAlbumTableViewHeight) style:UITableViewStylePlain];
    self.albumTableView.backgroundColor = [UIColor redColor];
    self.albumTableView.delegate = self;
    self.albumTableView.dataSource = self;
    self.albumTableView.rowHeight = 60;
    [self.view addSubview:self.albumTableView];
    
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

- (void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    [UIView animateWithDuration:0.35 animations:^{
        if (btn.selected) {
            CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
            btn.imageView.transform = transform;
            CGRect frame = self.albumTableView.frame;
            frame.origin.y += kAlbumTableViewHeight;
            self.albumTableView.frame = frame;
        }else{
            btn.imageView.transform = CGAffineTransformIdentity;
            CGRect frame = self.albumTableView.frame;
            frame.origin.y -= kAlbumTableViewHeight;
            self.albumTableView.frame = frame;
        }
    } completion:^(BOOL finished) {
    }];
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
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return cell;
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


