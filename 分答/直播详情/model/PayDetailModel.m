//
//  PayDetailModel.m
//  Yizhenapp
//
//  Created by 王浩 on 16/11/10.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "PayDetailModel.h"

@implementation PayDetailModel

-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        self.liveId=[dic[@"liveId"] integerValue];
        self.liveName=dic[@"liveName"];
        self.liveStartTime=dic[@"liveStartTime"];
        self.liveAttends=[dic[@"liveAttends"] integerValue];
        self.liveIntro=dic[@"liveIntro"];
        self.goodPrice=[dic[@"goodPrice"] integerValue];
        self.realPrice=[dic[@"realPrice"]integerValue];
        self.couponId=[dic[@"couponId"] integerValue];
        self.couponName=dic[@"couponName"];
    }
    return self;
}

- (NSString *)create_time:(NSString*)timeStr
{
    // 日期格式化类
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    // 设置日期格式(y:年,M:月,d:日,H:时,m:分,s:秒)
    fmt.dateFormat = @"MM月dd日 HH:mm";
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    // 帖子的创建时间
    NSDate *create = [NSDate dateWithTimeIntervalSince1970:[timeStr longLongValue] /1000];
    return [fmt stringFromDate:create];
}

@end
