//
//  AssetModel.m
//  MyApp
//
//  Created by huxinguang on 2018/9/26.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import "AssetModel.h"

@implementation AssetModel

+ (instancetype)modelWithAsset:(PHAsset *)asset{
    AssetModel *model = [[AssetModel alloc] init];
    model.asset = asset;
    model.picked = NO;
    model.number = 0;
    return model;
}


@end


