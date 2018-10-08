//
//  AssetPickerManager.m
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "AssetPickerManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "AssetModel.h"
#import "AlbumModel.h"

@interface AssetPickerManager ()
@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;
@end

@implementation AssetPickerManager

+ (instancetype)manager {
    static AssetPickerManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (ALAssetsLibrary *)assetLibrary {
    if (_assetLibrary == nil) _assetLibrary = [[ALAssetsLibrary alloc] init];
    return _assetLibrary;
}

- (BOOL)authorizationStatusNotDetermined{
    if (iOS8Later) {
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) return YES;
    } else {
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) return YES;
    }
    return NO;
}

// 如果得到了授权返回YES
- (BOOL)authorizationStatusAuthorized {
    if (iOS8Later) {
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) return YES;
    } else {
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) return YES;
    }
    return NO;
}

#pragma mark - Get Album

- (void)getAllAlbums:(BOOL)allowPickingVideo completion:(void (^)(NSArray<AlbumModel *> *))completion{
    NSMutableArray *albumArr = [NSMutableArray array];
    if (iOS8Later) {
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        if (!allowPickingVideo) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        
        PHAssetCollectionSubtype smartAlbumSubtype = PHAssetCollectionSubtypeSmartAlbumUserLibrary | PHAssetCollectionSubtypeSmartAlbumRecentlyAdded | PHAssetCollectionSubtypeSmartAlbumVideos;
        // For iOS 9, We need to show ScreenShots Album（屏幕快照） && SelfPortraits Album
        if (iOS9Later) {
            smartAlbumSubtype = PHAssetCollectionSubtypeSmartAlbumUserLibrary | PHAssetCollectionSubtypeSmartAlbumRecentlyAdded | PHAssetCollectionSubtypeSmartAlbumScreenshots | PHAssetCollectionSubtypeSmartAlbumSelfPortraits | PHAssetCollectionSubtypeSmartAlbumVideos;
        }
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:smartAlbumSubtype options:nil];
        for (PHAssetCollection *collection in smartAlbums) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (fetchResult.count < 1) continue;
            if ([collection.localizedTitle containsString:@"Deleted"]) continue;
            if ([collection.localizedTitle isEqualToString:@"Camera Roll"]) {
                [albumArr insertObject:[self modelWithResult:fetchResult name:collection.localizedTitle allowPickingVideo:allowPickingVideo] atIndex:0];
            } else {
                [albumArr addObject:[self modelWithResult:fetchResult name:collection.localizedTitle allowPickingVideo:allowPickingVideo]];
            }
        }
        
        PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular | PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
        for (PHAssetCollection *collection in albums) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (fetchResult.count < 1) continue;
            if ([collection.localizedTitle isEqualToString:@"My Photo Stream"]) {
                [albumArr insertObject:[self modelWithResult:fetchResult name:collection.localizedTitle allowPickingVideo:allowPickingVideo] atIndex:1];
            } else {
                [albumArr addObject:[self modelWithResult:fetchResult name:collection.localizedTitle allowPickingVideo:allowPickingVideo]];
            }
        }
        if (completion) completion(albumArr);
    } else {
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group == nil) {
                if (completion) completion(albumArr);
            }
            if ([group numberOfAssets] < 1) return;
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
            if ([name isEqualToString:@"Camera Roll"] || [name isEqualToString:@"相机胶卷"]) {
                [albumArr insertObject:[self modelWithResult:group name:name allowPickingVideo:allowPickingVideo] atIndex:0];
            } else if ([name isEqualToString:@"My Photo Stream"] || [name isEqualToString:@"我的照片流"]) {
                [albumArr insertObject:[self modelWithResult:group name:name allowPickingVideo:allowPickingVideo] atIndex:1];
            } else {
                [albumArr addObject:[self modelWithResult:group name:name allowPickingVideo:allowPickingVideo]];
            }
        } failureBlock:nil];
    }
}

#pragma mark - Get Asset

// 获得照片数组
- (void)getAssetsFromFetchResult:(id)result allowPickingVideo:(BOOL)allowPickingVideo completion:(void (^)(NSArray<AssetModel *> *))completion {
    NSMutableArray *assetArr = [NSMutableArray array];
    if ([result isKindOfClass:[PHFetchResult class]]) {
        for (PHAsset *asset in result) {
            AssetModelMediaType type = AssetModelMediaTypePhoto;
            if (asset.mediaType == PHAssetMediaTypeVideo)      type = AssetModelMediaTypeVideo;
            else if (asset.mediaType == PHAssetMediaTypeAudio) type = AssetModelMediaTypeAudio;
            else if (asset.mediaType == PHAssetMediaTypeImage) {
                if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) type = AssetModelMediaTypeLivePhoto;
            }
            NSString *timeLength = type == AssetModelMediaTypeVideo ? [NSString stringWithFormat:@"%0.0f",asset.duration] : @"";
            timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
            [assetArr addObject:[AssetModel modelWithAsset:asset type:type timeLength:timeLength]];
        }
        if (completion) completion(assetArr);
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *gruop = (ALAssetsGroup *)result;
        if (!allowPickingVideo) [gruop setAssetsFilter:[ALAssetsFilter allPhotos]];
        [gruop enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result == nil) {
                if (completion) completion(assetArr);
            }
            AssetModelMediaType type = AssetModelMediaTypePhoto;
            if (!allowPickingVideo){
                [assetArr addObject:[AssetModel modelWithAsset:result type:type]];
                return;
            }
            /// Allow picking video
            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                type = AssetModelMediaTypeVideo;
                NSTimeInterval duration = [[result valueForProperty:ALAssetPropertyDuration] integerValue];
                NSString *timeLength = [NSString stringWithFormat:@"%0.0f",duration];
                timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
                [assetArr addObject:[AssetModel modelWithAsset:result type:type timeLength:timeLength]];
            } else {
                [assetArr addObject:[AssetModel modelWithAsset:result type:type]];
            }
        }];
    }
}

- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}

/// Get photo bytes 获得一组照片的大小
- (void)getPhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *totalBytes))completion {
    __block NSInteger dataLength = 0;
    for (NSInteger i = 0; i < photos.count; i++) {
        AssetModel *model = photos[i];
        if ([model.asset isKindOfClass:[PHAsset class]]) {
            [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                if (model.type != AssetModelMediaTypeVideo) dataLength += imageData.length;
                if (i >= photos.count - 1) {
                    NSString *bytes = [self getBytesFromDataLength:dataLength];
                    if (completion) completion(bytes);
                }
            }];
        } else if ([model.asset isKindOfClass:[ALAsset class]]) {
            ALAssetRepresentation *representation = [model.asset defaultRepresentation];
            if (model.type != AssetModelMediaTypeVideo) dataLength += (NSInteger)representation.size;
            if (i >= photos.count - 1) {
                NSString *bytes = [self getBytesFromDataLength:dataLength];
                if (completion) completion(bytes);
            }
        }
    }
}

- (NSString *)getBytesFromDataLength:(NSInteger)dataLength {
    NSString *bytes;
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%0.1fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%0.0fK",dataLength/1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%zdB",dataLength];
    }
    return bytes;
}

#pragma mark - Get Photo

//获得照片本身
- (void)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *, NSDictionary *))completion {
    [self getPhotoWithAsset:asset photoWidth:[UIScreen mainScreen].bounds.size.width completion:completion];
}

- (void)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *, NSDictionary *))completion {
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)asset;
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        CGFloat multiple = [UIScreen mainScreen].scale;
        CGFloat pixelWidth = photoWidth * multiple;
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(pixelWidth, pixelHeight) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            if (downloadFinined) {
                if (completion) completion(result,info);
            }
        }];
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = (ALAsset *)asset;
        ALAssetRepresentation *assetRep = [alAsset defaultRepresentation];
        CGImageRef imageRef;
        if (photoWidth == [UIScreen mainScreen].bounds.size.width) {
            imageRef = [assetRep fullScreenImage];
        } else {
            imageRef = alAsset.thumbnail;
        }
        UIImage *image = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:(UIImageOrientation)[assetRep orientation]];
        if (completion) completion(image,nil);
    }
}

- (void)getPostImageWithAlbumModel:(AlbumModel *)model completion:(void (^)(UIImage *))completion {
    if (iOS8Later) {
        [[AssetPickerManager manager] getPhotoWithAsset:[model.result lastObject] photoWidth:80 completion:^(UIImage *photo, NSDictionary *info) {
            if (completion) completion(photo);
        }];
    } else {
        ALAssetsGroup *gruop = model.result;
        UIImage *postImage = [UIImage imageWithCGImage:gruop.posterImage];
        if (completion) completion(postImage);
    }
}

#pragma mark - Get Video

- (void)getVideoWithAsset:(id)asset completion:(void (^)(AVPlayerItem * _Nullable, NSDictionary * _Nullable))completion {
    if ([asset isKindOfClass:[PHAsset class]]) {
        [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            if (completion) completion(playerItem,info);
        }];
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        ALAsset *alAsset = (ALAsset *)asset;
        ALAssetRepresentation *defaultRepresentation = [alAsset defaultRepresentation];
        NSString *uti = [defaultRepresentation UTI];
        NSURL *videoURL = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:uti];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:videoURL];
        if (completion && playerItem) completion(playerItem,nil);
    }
}

#pragma mark - Private Method

- (AlbumModel *)modelWithResult:(id)result name:(NSString *)name allowPickingVideo:(BOOL)allowPickingVideo{
    AlbumModel *model = [[AlbumModel alloc] init];
    model.result = result;
    model.name = [self getNewAlbumName:name];
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        model.count = fetchResult.count;
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *gruop = (ALAssetsGroup *)result;
        model.count = [gruop numberOfAssets];
    }
    
    NSMutableArray *assetArr = [NSMutableArray array];
    if ([result isKindOfClass:[PHFetchResult class]]) {
        for (PHAsset *asset in result) {
            AssetModelMediaType type = AssetModelMediaTypePhoto;
            if (asset.mediaType == PHAssetMediaTypeVideo)      type = AssetModelMediaTypeVideo;
            else if (asset.mediaType == PHAssetMediaTypeAudio) type = AssetModelMediaTypeAudio;
            else if (asset.mediaType == PHAssetMediaTypeImage) {
                if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) type = AssetModelMediaTypeLivePhoto;
            }
            NSString *timeLength = type == AssetModelMediaTypeVideo ? [NSString stringWithFormat:@"%0.0f",asset.duration] : @"";
            timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
            [assetArr addObject:[AssetModel modelWithAsset:asset type:type timeLength:timeLength]];
        }
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *gruop = (ALAssetsGroup *)result;
        if (!allowPickingVideo) [gruop setAssetsFilter:[ALAssetsFilter allPhotos]];
        [gruop enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            AssetModelMediaType type = AssetModelMediaTypePhoto;
            if (!allowPickingVideo){
                [assetArr addObject:[AssetModel modelWithAsset:result type:type]];
                return;
            }
            /// Allow picking video
            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                type = AssetModelMediaTypeVideo;
                NSTimeInterval duration = [[result valueForProperty:ALAssetPropertyDuration] integerValue];
                NSString *timeLength = [NSString stringWithFormat:@"%0.0f",duration];
                timeLength = [self getNewTimeFromDurationSecond:timeLength.integerValue];
                [assetArr addObject:[AssetModel modelWithAsset:result type:type timeLength:timeLength]];
            } else {
                [assetArr addObject:[AssetModel modelWithAsset:result type:type]];
            }
        }];
    }
    
    model.assetArray = assetArr;
    return model;
}

- (NSString *)getNewAlbumName:(NSString *)name {
    if (iOS8Later) {
        NSString *newName;
        if ([name containsString:@"Roll"])         newName = @"相机胶卷";
        else if ([name containsString:@"Stream"])  newName = @"我的照片流";
        else if ([name containsString:@"Added"])   newName = @"最近添加";
        else if ([name containsString:@"Selfies"]) newName = @"自拍";
        else if ([name containsString:@"shots"])   newName = @"截屏";
        else if ([name containsString:@"Videos"])  newName = @"视频";
        else newName = name;
        return newName;
    } else {
        return name;
    }
}

@end

