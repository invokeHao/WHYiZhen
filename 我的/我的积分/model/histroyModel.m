//
//  histroyModel.m
//  Yizhenapp
//
//  Created by augbase on 16/5/9.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "histroyModel.h"

@implementation histroyModel

-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        self.createTime=[dic[@"createTime"] longLongValue];
        self.desc=dic[@"desc"];
        self.score=[dic[@"score"] intValue];
    }
    return self;
}

- (NSString *)create_time
{
    // 日期格式化类
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    // 设置日期格式(y:年,M:月,d:日,H:时,m:分,s:秒)
    fmt.dateFormat = @"MM.dd";
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    // 帖子的创建时间
    NSDate *create = [NSDate dateWithTimeIntervalSince1970:_createTime/1000];
    
    return [fmt stringFromDate:create];
}

@end
