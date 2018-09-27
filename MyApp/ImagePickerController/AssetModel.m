//
//  AssetModel.m
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "AssetModel.h"

@implementation AssetModel

+ (instancetype)modelWithAsset:(id)asset type:(AssetModelMediaType)type{
    AssetModel *model = [[AssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(id)asset type:(AssetModelMediaType)type timeLength:(NSString *)timeLength {
    AssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}

@end


