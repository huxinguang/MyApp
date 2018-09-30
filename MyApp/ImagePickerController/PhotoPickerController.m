//
//  PhotoPickerController.m
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "PhotoPickerController.h"
#import "AssetCell.h"
#import "AssetModel.h"
#import "PickerImageManager.h"
#import "CBTitleView.h"
#import "CBBarButton.h"
#import "AlbumCell.h"

@interface PhotoPickerController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong)UICollectionView *collectionView;
@property (nonatomic, strong)NSMutableArray<AssetModel *> *photoArr;
@property (nonatomic, strong)NSMutableArray<AssetModel *> *selectedPhotoArr;
@property (nonatomic, strong)UIButton *bottomConfirmBtn;
@property (nonatomic, strong)UITableView *albumTableView;
@property (nonatomic, strong)UIView *containerView;
@property (nonatomic, strong)NSMutableArray<AlbumModel *> *albumArr;
@property (nonatomic, strong)UIControl *maskView;
@property (nonatomic, strong)NavTitleView *ntView;
@property (nonatomic, assign)CGFloat containerViewHeight;
@property (nonatomic, strong)NSIndexPath *currentAlbumIndexpath;
@property (nonatomic, strong)AssetModel *placeholderModel;//相机占位model
@property (nonatomic, strong)NSMutableArray<NSIndexPath *> *albumSelectedIndexpaths;

@end

@implementation PhotoPickerController
@synthesize photoArr = _photoArr;//同时重写setter/getter方法需要这样

-(AssetModel *)placeholderModel{
    if (_placeholderModel == nil) {
        _placeholderModel = [[AssetModel alloc]init];
        _placeholderModel.type = AssetModelMediaTypeCamera;
    }
    return _placeholderModel;
}

-(NSMutableArray<AlbumModel *> *)albumArr{
    if (_albumArr == nil) {
        _albumArr = [NSMutableArray array];
    }
    return _albumArr;
}

-(NSMutableArray<AssetModel *> *)photoArr{
    if (_photoArr == nil) {
        _photoArr = [NSMutableArray array];
    }
    return _photoArr;
}

- (NSMutableArray<NSIndexPath *> *)albumSelectedIndexpaths{
    if (_albumSelectedIndexpaths == nil) {
        _albumSelectedIndexpaths = [NSMutableArray array];
    }
    return _albumSelectedIndexpaths;
}

-(void)setPhotoArr:(NSMutableArray<AssetModel *> *)photoArr{
    _photoArr = photoArr;
    //插入相机占位
    if (![_photoArr containsObject:self.placeholderModel]) {
        [_photoArr insertObject:self.placeholderModel atIndex:0];
    }
}

- (NSMutableArray<AssetModel *> *)selectedPhotoArr{
    if (_selectedPhotoArr == nil) _selectedPhotoArr = [NSMutableArray array];
    return _selectedPhotoArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self configMaskView];
    
    __weak typeof(self) weakSelf = self;
    [[PickerImageManager manager] getAllAlbums:YES completion:^(NSArray<AlbumModel *> *models) {
        weakSelf.albumArr = [NSMutableArray arrayWithArray:models];
        weakSelf.albumArr[0].isSelected = YES;//默认第一个选中
        [weakSelf.ntView.titleBtn setTitle:weakSelf.albumArr[0].name forState:UIControlStateNormal];
        weakSelf.ntView.titleBtnWidth = [weakSelf.albumArr[0].name widthForFont:kTitleViewTitleFont] + kTitleViewTextImageDistance + kTitleViewArrowSize.width;
        weakSelf.currentAlbumIndexpath = [NSIndexPath indexPathForRow:0 inSection:0];
        weakSelf.photoArr = weakSelf.albumArr[0].assetArray;
        [weakSelf configCollectionView];
        [weakSelf.collectionView reloadData];
        [weakSelf configAlbumTableView];
        [weakSelf.albumTableView reloadData];
        [weakSelf configBottomConfirmBtn];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRightBarButtonClick{
    [self.selectedPhotoArr removeAllObjects];
    NSArray *indexPaths = [self.albumSelectedIndexpaths copy];
    [self.albumSelectedIndexpaths removeAllObjects];
    for (AlbumModel *album in self.albumArr) {
        album.selectedCount = 0;
        for (AssetModel *asset in album.assetArray) {
            asset.isSelected = NO;
            asset.number = 0;
        }
    }
    [self.albumTableView reloadData];
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    [self refreshNavRightBtn];
    [self refreshBottomConfirmBtn];
}

- (void)configCollectionView {
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
    self.bottomConfirmBtn.frame = CGRectMake(0, kAppScreenHeight - kBottomConfirmBtnHeight - kAppStatusBarAndNavigationBarHeight - kAppTabbarSafeBottomMargin, kAppScreenWidth, kBottomConfirmBtnHeight);
    self.bottomConfirmBtn.backgroundColor = [UIColor whiteColor];
    self.bottomConfirmBtn.titleLabel.font = [UIFont boldSystemFontOfSize:kBottomConfirmBtnTitleFontSize];
    [self.bottomConfirmBtn addTarget:self action:@selector(onConfirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomConfirmBtn setTitle:@"确定(0/9)" forState:UIControlStateNormal];
    [self.bottomConfirmBtn setTitleColor:kAppThemeColor forState:UIControlStateNormal];
    [self.bottomConfirmBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    self.bottomConfirmBtn.enabled = NO;
    [self.view addSubview:self.bottomConfirmBtn];
}

- (void)onConfirmBtnClick {

}

- (void)onTitleBtnClick:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self.view insertSubview:self.maskView belowSubview:self.containerView];
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
            self.maskView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.2];
        }else{
            self.ntView.arrowView.transform = CGAffineTransformIdentity;
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
    [self onTitleBtnClick:self.ntView.titleBtn];
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetCell" forIndexPath:indexPath];
    AssetModel *model = self.photoArr[indexPath.row];
    cell.model = model;
    __weak typeof(cell) weakCell = cell;
    cell.didSelectPhotoBlock = ^(BOOL isSelected) {
        if (isSelected) {
            // 1. 取消选择
            weakCell.selectPhotoButton.selected = NO;
            model.isSelected = NO;
            [self.selectedPhotoArr removeObject:model];
            weakCell.numberLabel.text = @"";
            self.albumArr[self.currentAlbumIndexpath.row].selectedCount --;
        } else {
            // 2. 选择照片,检查是否超过了最大个数的限制
            if (self.selectedPhotoArr.count < 9) {
                weakCell.selectPhotoButton.selected = YES;
                model.isSelected = YES;
                [self.selectedPhotoArr addObject:model];
                self.albumArr[self.currentAlbumIndexpath.row].selectedCount ++;
                weakCell.numberLabel.text = [NSString stringWithFormat:@"%ld",self.selectedPhotoArr.count];
            } else {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"最多选择9张照片";
                [hud hideAnimated:YES afterDelay:1.5f];
            }
        }
        for (int i=0; i<self.selectedPhotoArr.count; i++) {
            AssetModel *selectedModel = self.selectedPhotoArr[i];
            selectedModel.number = i+1;
        }
       
        [self.albumSelectedIndexpaths removeAllObjects];
        for (AssetModel *am in self.selectedPhotoArr) {
            if ([self.albumArr[self.currentAlbumIndexpath.row].assetArray containsObject:am]) {
                NSUInteger indexAtCurrentAlbum = [self.albumArr[self.currentAlbumIndexpath.row].assetArray indexOfObject:am];
                [self.albumSelectedIndexpaths addObject:[NSIndexPath indexPathForItem:indexAtCurrentAlbum inSection:0]];
            }
        }
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
        [self openCamera];
    }else{
        AssetModel *model = self.photoArr[indexPath.row];
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
    self.photoArr = self.albumArr[indexPath.row].assetArray;
    if (indexPath != self.currentAlbumIndexpath) {
        [self.collectionView reloadData];
        [self onTitleBtnClick:self.ntView.titleBtn];
    }else{
        [self onTitleBtnClick:self.ntView.titleBtn];
    }
    self.currentAlbumIndexpath = indexPath;
    
}

- (void)refreshNavRightBtn{
    CBBarButton *btn = (CBBarButton *)self.navigationItem.rightBarButtonItem.customView;
    if (self.selectedPhotoArr.count > 0) {
        btn.enabled = YES;
    }else{
        btn.enabled = NO;
    }
}

- (void)refreshBottomConfirmBtn {
    if (self.selectedPhotoArr.count > 0) {
        self.bottomConfirmBtn.enabled = YES;
    }else{
        self.bottomConfirmBtn.enabled = NO;
    }
    [self.bottomConfirmBtn setTitle:[NSString stringWithFormat:@"确定(%ld/9)",self.selectedPhotoArr.count] forState:UIControlStateNormal];
}

- (void)openCamera{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    if (iOS7Later) {
        picker.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
    }
    // 设置导航默认标题的颜色及字体大小
    picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                 NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    [self presentViewController:picker animated:YES completion:nil];
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
//    UIImage *image = info[UIImagePickerControllerOriginalImage];
//    NSData *data = UIImagePNGRepresentation(image);
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end


@implementation NavTitleView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.titleBtn = [[UIButton alloc]init];
        self.titleBtn.titleLabel.font = kTitleViewTitleFont;
        [self.titleBtn setTitleColor:kAppThemeColor forState:UIControlStateNormal];
        [self addSubview:self.titleBtn];
        
        self.arrowView = [UIImageView new];
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"picker_arrow.png"];
        self.arrowView.image = [UIImage imageWithContentsOfFile:path];
        [self addSubview:self.arrowView];
        
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout{
    return YES;
}

-(void)updateConstraints{
    @weakify(self);
    [self.titleBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
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


