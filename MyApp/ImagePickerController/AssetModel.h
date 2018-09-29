//
//  AssetModel.h
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    AssetModelMediaTypePhoto = 0,
    AssetModelMediaTypeLivePhoto,
    AssetModelMediaTypeVideo,
    AssetModelMediaTypeAudio,
    AssetModelMediaTypeCamera       //相机占位
} AssetModelMediaType;

@class PHAsset;
@interface AssetModel : NSObject

@property (nonatomic, strong)id asset;                  // PHAsset 或 ALAsset
@property (nonatomic, assign)BOOL isSelected;           // 选中状态 默认NO
@property (nonatomic, assign)int number;                // 数字
@property (nonatomic, assign)AssetModelMediaType type;  //
@property (nonatomic, copy)NSString *timeLength;

/// 用一个PHAsset/ALAsset实例，初始化一个照片模型
+ (instancetype)modelWithAsset:(id)asset type:(AssetModelMediaType)type;
+ (instancetype)modelWithAsset:(id)asset type:(AssetModelMediaType)type timeLength:(NSString *)timeLength;

@end

