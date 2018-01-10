//
//  TicketModel.h
//  Yizhenapp
//
//  Created by 王浩 on 16/11/9.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TicketModel : NSObject


@property (assign,nonatomic)NSInteger IDS;
@property (assign,nonatomic)BOOL hasUsed;
@property (strong,nonatomic)NSString * phone;
@property (strong,nonatomic)NSString * Nickname;//用户昵称
@property (assign,nonatomic)NSInteger userId;
@property (assign,nonatomic)NSInteger sourceId;
@property (strong,nonatomic)NSString * receiveTime;
@property (strong,nonatomic)NSString * endTime;//结束时间
@property (strong,nonatomic)NSString * name;
@property (assign,nonatomic)NSInteger price;
@property (strong,nonatomic)NSString * ruleLink;

-(instancetype)initWithDictionary:(NSDictionary*)dic;

- (NSString *)create_time:(NSString*)timeStr;

@end
