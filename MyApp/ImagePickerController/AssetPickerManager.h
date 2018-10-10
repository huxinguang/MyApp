//
//  AssetPickerManager.h
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSUInteger,AuthorizationStatus) {
    AuthorizationStatusNotDetermined = 0,
    AuthorizationStatusRestricted,
    AuthorizationStatusDenied,
    AuthorizationStatusAuthorized
};

@class AlbumModel,AssetModel;
@interface AssetPickerManager : NSObject

+ (instancetype)manager;


- (void)handleAuthorizationWithCompletion:(void (^)(AuthorizationStatus aStatus))completion;

/// Return YES if Authorized 返回YES如果得到了授权
- (BOOL)authorizationStatusAuthorized;

/// Get Album 获得相册/相册数组
- (void)getAllAlbums:(BOOL)allowPickingVideo completion:(void (^)(NSArray<AlbumModel *> *models))completion;

/// Get Asset 获得Asset数组
- (void)getAssetsFromFetchResult:(id)result allowPickingVideo:(BOOL)allowPickingVideo completion:(void (^)(NSArray<AssetModel *> *models))completion;

/// Get photo 获得照片
- (void)getPostImageWithAlbumModel:(AlbumModel *)model completion:(void (^)(UIImage *postImage))completion;
- (void)getPhotoWithAsset:(id)asset completion:(void (^)(UIImage *photo,NSDictionary *info))completion;
- (void)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info))completion;

/// Get video 获得视频
- (void)getVideoWithAsset:(id)asset completion:(void (^)(AVPlayerItem * playerItem, NSDictionary * info))completion;

/// Get photo bytes 获得一组照片的大小
- (void)getPhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *totalBytes))completion;

@end

