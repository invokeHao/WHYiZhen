//
//  shareObject.h
//  Yizhenapp
//
//  Created by 王浩 on 16/11/3.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark-分享的用的数据模型

@interface shareObject : NSObject

@property (strong,nonatomic)NSString *shareTitle;

@property (strong,nonatomic)NSString *shareContent;

@property (strong,nonatomic)NSString *shareUrl;

-(instancetype)initWithDictionary:(NSDictionary*)dic;

@end
