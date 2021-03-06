//
//  informationModel.m
//  Yizhenapp
//
//  Created by augbase on 16/5/9.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "informationModel.h"

@implementation informationModel

-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        self.IDS=[dic[@"id"] integerValue];
        self.picURL=[dic[@"picURL"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.title=dic[@"title"];
        self.createTime=[dic[@"createTime"] longLongValue];
        self.moduleName=dic[@"moduleName"];
    }
    return self;
}
- (NSString *)create_time
{
    // 日期格式化类
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    // 设置日期格式(y:年,M:月,d:日,H:时,m:分,s:秒)
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    // 帖子的创建时间
    NSDate *create = [NSDate dateWithTimeIntervalSince1970:self.createTime /1000];
    
    
    if (create.isThisYear) { // 今年
        if (create.isToday) { // 今天
            NSDateComponents *cmps = [[NSDate date] deltaFrom:create];
            
            if (cmps.hour >= 1) { // 时间差距 >= 1小时
                return [NSString stringWithFormat:@"%zd小时前", cmps.hour];
            } else if (cmps.minute >= 1) { // 1小时 > 时间差距 >= 1分钟
                return [NSString stringWithFormat:@"%zd分钟前", cmps.minute];
            } else { // 1分钟 > 时间差距
                return @"刚刚";
            }
        } else if (create.isYesterday) { // 昨天
            fmt.dateFormat = @"昨天 HH:mm:ss";
            return [fmt stringFromDate:create];
        } else { // 其他
            fmt.dateFormat = @"MM-dd HH:mm:ss";
            return [fmt stringFromDate:create];
        }
    } else { // 非今年
        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
        return [fmt stringFromDate:create];
    }
}


@end
