//
//  liveDetailModel.m
//  Yizhenapp
//
//  Created by augbase on 16/9/1.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "liveDetailModel.h"


@implementation liveDetailModel

//"canAsk":false,
//"totalQ":30,
//"askedQ":0,
//"perQ":3

-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        self.doctorAvatar=[dic[@"doctorAvatar"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.doctorId=[dic[@"doctorId"] integerValue];
        self.doctorIntro=dic[@"doctorIntro"];
        self.doctorIntroLink=dic[@"doctorIntroLink"];
        self.doctorName=dic[@"doctorName"];
        self.hasAttend=[dic[@"hasAttend"] boolValue];
        self.hasClosed=[dic[@"hasClosed"] boolValue];
        self.IDS=[dic[@"id"] integerValue];
        self.intro=dic[@"intro"];
        self.startTime=dic[@"startTime"];
        self.startShowTime=dic[@"startShowTime"];
        self.tag=dic[@"tag"];
        self.title=dic[@"title"];
        self.attends=[dic[@"attends"] integerValue];
        self.price=[dic[@"price"] integerValue];
        self.canAsk=[dic[@"canAsk"] boolValue];
        self.totalQ=[dic[@"totalQ"] integerValue];
        self.askedQ=[dic[@"askedQ"] integerValue];
        self.perQ=[dic[@"perQ"] integerValue];
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
