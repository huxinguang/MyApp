//
//  AssetPickerController.m
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "AssetPickerController.h"
#import "AssetCell.h"
#import "AssetModel.h"
#import "AssetPickerManager.h"
#import "CBTitleView.h"
#import "CBBarButton.h"
#import "AlbumCell.h"

@interface AssetPickerController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate,PHPhotoLibraryChangeObserver>
@property (nonatomic, strong)UICollectionView *collectionView;
@property (nonatomic, strong)NSMutableArray<AssetModel *> *assetArr;
@property (nonatomic, strong)UIButton *bottomConfirmBtn;
@property (nonatomic, strong)UITableView *albumTableView;
@property (nonatomic, strong)UIView *containerView;
@property (nonatomic, strong)NSMutableArray<AlbumModel *> *albumArr;
@property (nonatomic, strong)UIControl *mask;
@property (nonatomic, strong)NavTitleView *ntView;
@property (nonatomic, assign)CGFloat containerViewHeight;
@property (nonatomic, strong)NSIndexPath *currentAlbumIndexpath;
@property (nonatomic, strong)AssetModel *placeholderModel; //相机占位model
@property (nonatomic, strong)NSMutableArray<NSIndexPath *> *albumSelectedIndexpaths;

@end

@implementation AssetPickerController
@synthesize assetArr = _assetArr;//同时重写setter/getter方法需要这样

-(AssetModel *)placeholderModel{
    if (_placeholderModel == nil) {
        _placeholderModel = [[AssetModel alloc]init];
        _placeholderModel.isPlaceholder = YES;
    }
    return _placeholderModel;
}

-(NSMutableArray<AlbumModel *> *)albumArr{
    if (_albumArr == nil) _albumArr = [NSMutableArray array];
    return _albumArr;
}

-(NSMutableArray<AssetModel *> *)assetArr{
    if (_assetArr == nil) _assetArr = [NSMutableArray array];
    return _assetArr;
}

- (NSMutableArray<NSIndexPath *> *)albumSelectedIndexpaths{
    if (_albumSelectedIndexpaths == nil) _albumSelectedIndexpaths = [NSMutableArray array];
    return _albumSelectedIndexpaths;
}

-(void)setAssetArr:(NSMutableArray<AssetModel *> *)assetArr{
    _assetArr = assetArr;
    //插入相机占位
    if (![_assetArr containsObject:self.placeholderModel]) {
        [_assetArr insertObject:self.placeholderModel atIndex:0];
    }
}

- (AssetModel *)getAssetModelAtCurrentAlbumWithIdentifier:(NSString *)identifier{
    AssetModel *model = nil;
    for (AssetModel *am in self.albumArr[self.currentAlbumIndexpath.row].assetArray) {
        if ([am.asset.localIdentifier isEqualToString:identifier]) {
            model = am;
        }
    }
    return model;
}

- (AssetModel *)getAssetModelAtAllAlbumsWithIdentifier:(NSString *)identifier{
    AssetModel *model = nil;
    for (AlbumModel *albumItem in self.albumArr) {
        for (AssetModel *assetItem in albumItem.assetArray) {
            if ([assetItem.asset.localIdentifier isEqualToString:identifier]) {
                model = assetItem;
            }
        }
    }
    return model;
}

-(void)dealloc{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

-(instancetype)initWithOptions:(AssetPickerOptions *)options delegate:(id<AssetPickerControllerDelegate>)delegate{
    if (self = [super init]) {
        self.pickerOptions = options;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    [self configMask];
    [self getAlbums];
    
}

- (void)getAlbums{
    @weakify(self)
    [[AssetPickerManager manager] getAllAlbums:self.pickerOptions.videoPickable completion:^(NSArray<AlbumModel *> *models) {
        @strongify(self)
        if (!self) return;
        self.albumArr = [NSMutableArray arrayWithArray:models];
        self.albumArr[0].isSelected = YES;//默认第一个选中
        [self.ntView.titleBtn setTitle:self.albumArr[0].name forState:UIControlStateNormal];
        self.ntView.titleBtnWidth = [self.albumArr[0].name widthForFont:kTitleViewTitleFont] + kTitleViewTextImageDistance + kTitleViewArrowSize.width;
        self.currentAlbumIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
        self.assetArr = self.albumArr[0].assetArray;
        [self refreshAlbumAssetsStatus];
        [self configCollectionView];
        [self configBottomConfirmBtn];
        [self.collectionView reloadData];
        [self refreshNavRightBtn];
        [self configAlbumTableView];
        [self.albumTableView reloadData];
    }];
}

- (void)resetAlbums{
    @weakify(self)
    [[AssetPickerManager manager] getAllAlbums:self.pickerOptions.videoPickable completion:^(NSArray<AlbumModel *> *models) {
        @strongify(self)
        if (!self) return;
        self.albumArr = [NSMutableArray arrayWithArray:models];
        self.albumArr[self.currentAlbumIndexpath.row].isSelected = YES;
        [self.ntView.titleBtn setTitle:self.albumArr[self.currentAlbumIndexpath.row].name forState:UIControlStateNormal];
        self.ntView.titleBtnWidth = [self.albumArr[self.currentAlbumIndexpath.row].name widthForFont:kTitleViewTitleFont] + kTitleViewTextImageDistance + kTitleViewArrowSize.width;
        self.assetArr = self.albumArr[self.currentAlbumIndexpath.row].assetArray;
        [self refreshAlbumAssetsStatus];
        [self refreshNavRightBtn];
        [self refreshBottomConfirmBtn];
        [self.albumTableView reloadData];
    }];
}

- (void)configMask{
    self.mask = [UIControl new];
    self.mask.frame = self.view.bounds;
    self.mask.backgroundColor = [UIColor clearColor];
    self.mask.userInteractionEnabled = NO;
    [self.view addSubview:self.mask];
    [self.mask addTarget:self action:@selector(onClickMask) forControlEvents:UIControlEventTouchUpInside];
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
    self.ntView = [[NavTitleView alloc]init];
    self.ntView.intrinsicContentSize = CGSizeMake(kAppScreenWidth - 2*50, kAppNavigationBarHeight);
    self.ntView.titleBtn.selected = NO;
    [self.ntView.titleBtn addTarget:self action:@selector(onTitleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = self.ntView;
}

- (void)configRightBarButtonItem{
    CBBarButtonConfiguration *config = [[CBBarButtonConfiguration alloc]init];
    config.type = CBBarButtonTypeText;
    config.titleString = @"重选";
    config.normalColor = kAppThemeColor;
    config.disabledColor = [UIColor lightGrayColor];
    config.titleFont = [UIFont boldSystemFontOfSize:15];
    CBBarButton *rightBarButton = [[CBBarButton alloc]initWithConfiguration:config];
    [rightBarButton addTarget:self action:@selector(onRightBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBarButton];
    [self refreshNavRightBtn];
}

- (void)onLeftBarButtonClick{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(assetPickerControllerDidCancel:)]) {
            [self.delegate assetPickerControllerDidCancel:self];
        }
    }];
}

- (void)onRightBarButtonClick{
    [self.pickerOptions.pickedAssetModels removeAllObjects];
    NSArray *indexPaths = [self.albumSelectedIndexpaths copy];
    [self.albumSelectedIndexpaths removeAllObjects];
    [self.pickerOptions.pickedAssetModels removeAllObjects];
    for (AlbumModel *album in self.albumArr) {
        for (AssetModel *asset in album.assetArray) {
            asset.picked = NO;
            asset.number = 0;
        }
    }
    [self.albumTableView reloadData];
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    [self refreshNavRightBtn];
    [self refreshBottomConfirmBtn];
}

- (void)configCollectionView {
    if (!self.collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemWH = (self.view.width - (kItemsAtEachLine-1)*kItemMargin)/kItemsAtEachLine;
        layout.itemSize = CGSizeMake(itemWH, itemWH);
        layout.minimumInteritemSpacing = kItemMargin;
        layout.minimumLineSpacing = kItemMargin;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight-kAppStatusBarAndNavigationBarHeight-kBottomConfirmBtnHeight-kAppTabbarSafeBottomMargin) collectionViewLayout:layout];
        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.alwaysBounceVertical = YES;
        [self.view addSubview:self.collectionView];
        [self.collectionView registerNib:[UINib nibWithNibName:@"AssetCell" bundle:nil] forCellWithReuseIdentifier:@"AssetCell"];
    }
}

- (void)configAlbumTableView{
    if (!self.albumTableView) {
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
}

- (void)configBottomConfirmBtn {
    if (!self.bottomConfirmBtn) {
        self.bottomConfirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.bottomConfirmBtn.frame = CGRectMake(0, kAppScreenHeight - kBottomConfirmBtnHeight - kAppStatusBarAndNavigationBarHeight - kAppTabbarSafeBottomMargin, kAppScreenWidth, kBottomConfirmBtnHeight);
        self.bottomConfirmBtn.backgroundColor = [UIColor whiteColor];
        self.bottomConfirmBtn.titleLabel.font = [UIFont boldSystemFontOfSize:kBottomConfirmBtnTitleFontSize];
        [self.bottomConfirmBtn addTarget:self action:@selector(onConfirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomConfirmBtn setTitle:[NSString stringWithFormat:@"确定(%ld/%ld)",self.pickerOptions.pickedAssetModels.count,self.pickerOptions.maxAssetsCount] forState:UIControlStateNormal];
        [self.bottomConfirmBtn setTitleColor:kAppThemeColor forState:UIControlStateNormal];
        [self.bottomConfirmBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        if (self.pickerOptions.pickedAssetModels.count > 0) {
            self.bottomConfirmBtn.enabled = YES;
        }else{
            self.bottomConfirmBtn.enabled = NO;
        }
        [self.view addSubview:self.bottomConfirmBtn];
    }
    
}

- (void)onConfirmBtnClick {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(assetPickerController:didFinishPickingAssets:)]) {
            [self.delegate assetPickerController:self didFinishPickingAssets:[self.pickerOptions.pickedAssetModels copy]];
        }
    }];
}

- (void)onTitleBtnClick:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self.view insertSubview:self.mask belowSubview:self.containerView];
        self.mask.userInteractionEnabled = YES;
    }else{
        self.mask.userInteractionEnabled = NO;
    }
    [self.albumTableView reloadData];
    [self.albumTableView scrollToRowAtIndexPath:self.currentAlbumIndexpath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [UIView animateWithDuration:0.35 animations:^{
        if (btn.selected) {
            CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
            self.ntView.arrowView.transform = transform;
            CGRect frame = self.containerView.frame;
            frame.origin.y += self.containerViewHeight;
            self.containerView.frame = frame;
            self.mask.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.2];
        }else{
            self.ntView.arrowView.transform = CGAffineTransformIdentity;
            CGRect frame = self.containerView.frame;
            frame.origin.y -= self.containerViewHeight;
            self.containerView.frame = frame;
            self.mask.backgroundColor = [UIColor clearColor];
        }
    } completion:^(BOOL finished) {
        if (!btn.selected) {
            [self.view insertSubview:self.mask belowSubview:self.collectionView];
        }
    }];
}

- (void)onClickMask{
    [self onTitleBtnClick:self.ntView.titleBtn];
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetCell" forIndexPath:indexPath];
    AssetModel *model = self.assetArr[indexPath.row];
    cell.model = model;
    __weak typeof(cell) weakCell = cell;
    @weakify(self)
    cell.didSelectPhotoBlock = ^(BOOL isSelected) {
        @strongify(self)
        if (!self) return;
        if (isSelected) {
            // 1. 取消选择
            weakCell.selectPhotoButton.selected = NO;
            model.picked = NO;
            model.number = 0;
            for (AssetModel *am in [self.pickerOptions.pickedAssetModels copy]) {
                if ([am.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
                    am.number = 0;
                    am.picked = NO;
                    [self.pickerOptions.pickedAssetModels removeObject:am];
                }
            }
            weakCell.numberLabel.text = @"";
        } else {
            // 2. 选择照片,检查是否超过了最大个数的限制
            if (self.pickerOptions.pickedAssetModels.count < self.pickerOptions.maxAssetsCount) {
                weakCell.selectPhotoButton.selected = YES;
                model.picked = YES;
                [self.pickerOptions.pickedAssetModels addObject:model];
                weakCell.numberLabel.text = [NSString stringWithFormat:@"%ld",self.pickerOptions.pickedAssetModels.count];
            } else {
                [self showHudWithString:[NSString stringWithFormat:@"最多选择%ld张照片",self.pickerOptions.maxAssetsCount]];
            }
        }
        [self refreshAlbumAssetsStatus];
        //取消选择的时候才刷新所有选中的item
        if (self.albumSelectedIndexpaths.count > 0 && isSelected) {
            [collectionView reloadItemsAtIndexPaths:self.albumSelectedIndexpaths];
        }
        [self refreshNavRightBtn];
        [self refreshBottomConfirmBtn];
        
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        //打开相机
        if (self.pickerOptions.pickedAssetModels.count < self.pickerOptions.maxAssetsCount) {
#if TARGET_IPHONE_SIMULATOR
            [self showHudWithString:@"模拟器不支持相机"];
#elif TARGET_OS_IPHONE
            [self openCamera];
#endif
        }else{
            [self showHudWithString:[NSString stringWithFormat:@"最多选择%ld张照片",self.pickerOptions.maxAssetsCount]];
        }
    }else{
        AssetModel *model = self.assetArr[indexPath.row];
    }
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
    for (AlbumModel *album in self.albumArr) {
        album.isSelected = NO;
    }
    self.albumArr[indexPath.row].isSelected = YES;
    [self.ntView.titleBtn setTitle:self.albumArr[indexPath.row].name forState:UIControlStateNormal];
    self.ntView.titleBtnWidth = [self.albumArr[indexPath.row].name widthForFont:kTitleViewTitleFont] + kTitleViewTextImageDistance + kTitleViewArrowSize.width;
    self.assetArr = self.albumArr[indexPath.row].assetArray;
    if (indexPath != self.currentAlbumIndexpath) {
        [self refreshAlbumAssetsStatus];
        [self.collectionView reloadData];
        [self onTitleBtnClick:self.ntView.titleBtn];
    }else{
        [self onTitleBtnClick:self.ntView.titleBtn];
    }
    self.currentAlbumIndexpath = indexPath;
}

- (void)refreshAlbumAssetsStatus{
    [self.albumSelectedIndexpaths removeAllObjects];
    for (int i=1; i<self.assetArr.count; i++) {//第1个为相机占位
        AssetModel *am = self.assetArr[i];
        am.picked = NO;
        am.number = 0;
        for (int j=0; j<self.pickerOptions.pickedAssetModels.count; j++) {
            AssetModel *pam = self.pickerOptions.pickedAssetModels[j];
            if ([am.asset.localIdentifier isEqualToString:pam.asset.localIdentifier]) {
                am.picked = YES;
                am.number = j+1;
                [self.albumSelectedIndexpaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
            }
        }
    }
}

- (void)refreshNavRightBtn{
    CBBarButton *btn = (CBBarButton *)self.navigationItem.rightBarButtonItem.customView;
    if (self.pickerOptions.pickedAssetModels.count > 0) {
        btn.enabled = YES;
    }else{
        btn.enabled = NO;
    }
}

- (void)refreshBottomConfirmBtn {
    if (self.pickerOptions.pickedAssetModels.count > 0) {
        self.bottomConfirmBtn.enabled = YES;
    }else{
        self.bottomConfirmBtn.enabled = NO;
    }
    [self.bottomConfirmBtn setTitle:[NSString stringWithFormat:@"确定(%ld/%ld)",self.pickerOptions.pickedAssetModels.count,self.pickerOptions.maxAssetsCount] forState:UIControlStateNormal];
}

- (void)showHudWithString:(NSString *)string{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = string;
    [hud hideAnimated:YES afterDelay:1.5f];
}

- (void)openCamera{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    if (self.pickerOptions.videoPickable) {
        NSString *mediaTypeImage = (NSString *)kUTTypeImage;
        NSString *mediaTypeMovie = (NSString *)kUTTypeMovie;
        picker.mediaTypes = @[mediaTypeImage,mediaTypeMovie];
    }
    picker.delegate = self;
    picker.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
    picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                 NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (void)switchToCameraRoll{
    for (AlbumModel *album in self.albumArr) {
        album.isSelected = NO;
    }
    self.albumArr[0].isSelected = YES;
    [self.ntView.titleBtn setTitle:self.albumArr[0].name forState:UIControlStateNormal];
    self.ntView.titleBtnWidth = [self.albumArr[0].name widthForFont:kTitleViewTitleFont] + kTitleViewTextImageDistance + kTitleViewArrowSize.width;
    self.assetArr = self.albumArr[0].assetArray;
    [self refreshAlbumAssetsStatus];
    [self.collectionView reloadData];
    [self.albumTableView reloadData];
    self.currentAlbumIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    @weakify(self)
    dispatch_sync(dispatch_get_main_queue(), ^{
        @strongify(self)
        if (!self) return;
        //相册添加照片所产生的change(这里只对app内调用相机拍照后点击“use photo（使用照片）”按钮后所产生的change)
        AlbumModel *currentAlbum = self.albumArr[0];
        PHFetchResultChangeDetails *changes = [changeInstance changeDetailsForFetchResult:currentAlbum.result];
        if (changes) {
            currentAlbum.result = [changes fetchResultAfterChanges];
            if (changes.hasIncrementalChanges) {
                if (self.collectionView) {
                    NSArray<PHAsset *> *insertItems = changes.insertedObjects;
                    NSMutableArray *indexPaths = @[].mutableCopy;
                    if (insertItems && insertItems.count > 0) {
                        for (int i=0; i<insertItems.count; i++) {
                            AssetModel *model = [[AssetModel alloc] init];
                            model.asset = insertItems[i];
                            if (self.pickerOptions.pickedAssetModels.count < self.pickerOptions.maxAssetsCount) {
                                model.picked = YES;
                                model.number = (int)self.pickerOptions.pickedAssetModels.count + 1;
                                [self.pickerOptions.pickedAssetModels addObject:model];
                            }else{
                                model.picked = NO;
                                model.number = 0;
                            }
                            [currentAlbum.assetArray insertObject:model atIndex:1];
                            [indexPaths addObject:[NSIndexPath indexPathForItem:i+1 inSection:0]];
                        }
                    }

                    [self.collectionView performBatchUpdates:^{
                        NSArray<PHAsset *> *insertItems = changes.insertedObjects;
                        if (insertItems && insertItems.count > 0) {
                            [self.collectionView insertItemsAtIndexPaths:indexPaths];
                            [changes enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex) {
                                [self.collectionView moveItemAtIndexPath:[NSIndexPath indexPathForItem:fromIndex inSection:0] toIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0]];
                            }];
                            [self.collectionView reloadItemsAtIndexPaths:indexPaths];
                        }
                    } completion:^(BOOL finished) {
                        [self resetAlbums];
                    }];

                }

            }
        }
        
    });
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image: didFinishSavingWithError: contextInfo:), nil);
    }else{
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *urlStr = [url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
            UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    }
    if (self.currentAlbumIndexpath.row != 0) {
        [self switchToCameraRoll];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{

}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
}

@end


@implementation NavTitleView

- (instancetype)init{
    self = [super init];
    if (self) {
        self.titleBtn = [[UIButton alloc]init];
        self.titleBtn.titleLabel.font = kTitleViewTitleFont;
        [self.titleBtn setTitleColor:kAppThemeColor forState:UIControlStateNormal];
        [self addSubview:self.titleBtn];
        
        self.arrowView = [UIImageView new];
        self.arrowView.image = [UIImage imageNamed:@"picker_arrow"];
        
        /*
         存放在Images.xcassets/Assets.xcassets中的图片只能通过[UIImage imageNamed:@"xxx"]的方式来创建
         只有存放在普通文件夹里的图片才能使用 [UIImage imageWithContentsOfFile:path]来创建
         */
//        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"picker_arrow"];
//        self.arrowView.image = [UIImage imageWithContentsOfFile:path];
        [self addSubview:self.arrowView];
        
    }
    return self;
}



+ (BOOL)requiresConstraintBasedLayout{
    return YES;
}

- (void)updateConstraints{
    @weakify(self)
    [self.titleBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        if (!self) return;
        make.centerY.equalTo(self.mas_centerY);
        make.centerX.equalTo(self.mas_centerX).with.offset(-(kTitleViewTextImageDistance + kTitleViewArrowSize.width)/2);
        make.size.mas_equalTo(CGSizeMake(self.titleBtnWidth, kAppNavigationBarHeight));
    }];

    [self.arrowView mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.titleBtn.mas_right).with.offset(kTitleViewTextImageDistance);
        make.size.mas_equalTo(kTitleViewArrowSize);
    }];

    [super updateConstraints];
}

- (void)setTitleBtnWidth:(CGFloat)titleBtnWidth{
    _titleBtnWidth = titleBtnWidth;
    [self setNeedsUpdateConstraints];
}


@end

@implementation AssetPickerOptions

-(NSMutableArray<AssetModel *> *)pickedAssetModels{
    if(_pickedAssetModels == nil)  _pickedAssetModels = [NSMutableArray array];
    return _pickedAssetModels;
}

@end


