//
//  WXpayModel.m
//  Yizhenapp
//
//  Created by 王浩 on 16/11/10.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "WXpayModel.h"

@implementation WXpayModel

//"wx_appid":"qwer123qwe",
//"wx_partnerid":"qwer13qwe",
//"wx_prepayid":"qwerq34",
//"wx_noncestr":"qwerqwer",
//"wx_timestamp":"142434332",
//"wx_package":"Sign=WXPay",
//"wx_sign":"23atwergerewtqe134"

-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        self.wx_appid=dic[@"wx_appid"];
        self.wx_partnerid=dic[@"wx_partnerid"];
        self.wx_prepayid=dic[@"wx_prepayid"];
        self.wx_noncestr=dic[@"wx_noncestr"];
        self.wx_timestamp=dic[@"wx_timestamp"];
        self.wx_package=dic[@"wx_package"];
        self.wx_sign=dic[@"wx_sign"];
        self.skipPayment=[dic[@"skipPayment"] boolValue];
    }
    return self;
}

@end
