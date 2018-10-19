//
//  MediaModel.h
//  MyApp
//
//  Created by huxinguang on 2018/9/12.
//  Copyright © 2018年 huxinguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Media : NSObject
@property (nonatomic, assign) NSInteger media_id;
@property (nonatomic, assign) int media_width;
@property (nonatomic, assign) int media_height;
@property (nonatomic,copy) NSString *media_url;
@property (nonatomic, assign) short media_type;
@end
