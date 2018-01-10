//
//  PayDetailModel.h
//  Yizhenapp
//
//  Created by 王浩 on 16/11/10.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayDetailModel : NSObject

@property (assign,nonatomic)NSInteger liveId;
@property (strong,nonatomic)NSString * liveName;
@property (strong,nonatomic)NSString * liveStartTime;//
@property (assign,nonatomic)NSInteger liveAttends;
@property (strong,nonatomic)NSString * liveIntro;
@property (assign,nonatomic)NSInteger goodPrice;
@property (assign,nonatomic)NSInteger realPrice;
@property (assign,nonatomic)NSInteger couponId;
@property (strong,nonatomic)NSString * couponName;

-(instancetype)initWithDictionary:(NSDictionary*)dic;

- (NSString *)create_time:(NSString*)timeStr;

@end
