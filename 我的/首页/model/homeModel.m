//
//  homeModel.m
//  Yizhenapp
//
//  Created by augbase on 16/5/4.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "homeModel.h"

@implementation homeModel
-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        self.collectAmount=[dic[@"collectAmount"] integerValue];
        self.friendAmount=[dic[@"friendAmount"]integerValue];
        self.isUnread=[dic[@"isUnread"] boolValue];
        self.messageAvatar=dic[@"messageAvatar"];
        self.nickname=dic[@"nickname"];
        self.score=[dic[@"score"] integerValue];
        self.topicAmount=[dic[@"topicAmount"] integerValue];
        self.replyAmount=[dic[@"replyAmount"] integerValue];
        self.avatar=[dic[@"avatar"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.couponAmount=[dic[@"couponAmount"] integerValue];
        self.liveAmount=[dic[@"liveAmount"] integerValue];
    }
    return self;
}
@end
