//
//  WXpayModel.h
//  Yizhenapp
//
//  Created by 王浩 on 16/11/10.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXpayModel : NSObject

//"wx_appid":"qwer123qwe",
//"wx_partnerid":"qwer13qwe",
//"wx_prepayid":"qwerq34",
//"wx_noncestr":"qwerqwer",
//"wx_timestamp":"142434332",
//"wx_package":"Sign=WXPay",
//"wx_sign":"23atwergerewtqe134"


@property (strong,nonatomic) NSString * wx_appid;
@property (strong,nonatomic) NSString * wx_partnerid;
@property (strong,nonatomic) NSString * wx_prepayid;
@property (strong,nonatomic) NSString * wx_noncestr;
@property (strong,nonatomic) NSString * wx_timestamp;
@property (strong,nonatomic) NSString * wx_package;
@property (strong,nonatomic) NSString * wx_sign;
@property (assign,nonatomic)BOOL skipPayment;//用来判断是否跳过微信支付，直接进入直播

-(instancetype)initWithDictionary:(NSDictionary*)dic;

@end
