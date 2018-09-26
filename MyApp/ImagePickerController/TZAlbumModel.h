//
//  TZAlbumModel.h
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PHFetchResult;
@interface TZAlbumModel : NSObject
@property (nonatomic, strong) NSString *name;        //相册名称
@property (nonatomic, assign) NSInteger count;       //相册照片数量
@property (nonatomic, strong) id result;             //PHFetchResult<PHAsset> 或 ALAssetsGroup<ALAsset>
@end
