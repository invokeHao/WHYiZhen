//
//  TicketModel.m
//  Yizhenapp
//
//  Created by 王浩 on 16/11/9.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "TicketModel.h"

@implementation TicketModel

//{
//    "id":132,
//    "hasUsed":true,
//    "phone":"13800138000",
//    "userNickname":"我要我要",
//    "userId":123,
//    "sourceId":12,
//    "receiveTime":14294729472,
//    "endTime":14294729472
//}

-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        self.IDS=[dic[@"id"] integerValue];
        self.hasUsed=[dic[@"hasUsed"] boolValue];
        self.phone=dic[@"phone"];
        self.Nickname=dic[@"userNickName"];
        self.userId=[dic[@"userId"] integerValue];
        self.sourceId=[dic[@"sourceId"] integerValue];
        self.receiveTime=dic[@"receiveTime"];
        self.endTime=dic[@"endTime"];
        self.name=dic[@"name"];
        self.price=[dic[@"price"] integerValue];
        self.ruleLink=dic[@"ruleLink"];
    }
    return self;
}

- (NSString *)create_time:(NSString*)timeStr
{
    // 日期格式化类
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    // 设置日期格式(y:年,M:月,d:日,H:时,m:分,s:秒)
    fmt.dateFormat = @"yyyy.MM.dd";
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    // 帖子的创建时间
    NSDate *create = [NSDate dateWithTimeIntervalSince1970:[timeStr longLongValue] /1000];
    return [fmt stringFromDate:create];
}

@end
