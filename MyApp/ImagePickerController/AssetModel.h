//
//  AssetModel.h
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PHAsset;
@interface AssetModel : NSObject
@property (nonatomic, strong)PHAsset *asset;            // PHAsset
@property (nonatomic, getter=isPicked)BOOL picked;      // 选中状态 默认NO
@property (nonatomic, assign)int number;                // 数字
@property (nonatomic, assign)BOOL isPlaceholder;        // 是否为相机占位
@property (nonatomic, assign)BOOL selectable;           // 是否可以被选中

+ (instancetype)modelWithAsset:(PHAsset *)asset;


@end

