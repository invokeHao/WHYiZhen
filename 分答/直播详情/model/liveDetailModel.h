//
//  liveDetailModel.h
//  Yizhenapp
//
//  Created by augbase on 16/9/1.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface liveDetailModel : NSObject

@property (strong,nonatomic) NSString * doctorAvatar;//医生头像
@property (assign,nonatomic) NSInteger doctorId; //医生的id
@property (strong,nonatomic) NSString * doctorIntro;//医生的简介
@property (strong,nonatomic) NSString * doctorIntroLink;//医生简介的link
@property (strong,nonatomic) NSString * doctorName;//医生的名字
@property (assign,nonatomic) BOOL hasClosed;//直播是否已结束
@property (assign,nonatomic) BOOL hasAttend;//是否入场
@property (assign,nonatomic) NSInteger IDS;//该场直播的id
@property (strong,nonatomic) NSString * intro;//直播的简介
@property (strong,nonatomic) NSString * startTime;//开始时间
@property (strong,nonatomic) NSString * startShowTime;//显示时间
@property (strong,nonatomic) NSString * tag;//第几期
@property (strong,nonatomic) NSString * title;//标题
@property (assign,nonatomic) NSInteger attends;//入场人数
@property (assign,nonatomic) NSInteger price;//直播价格

@property (assign,nonatomic) BOOL canAsk;//能提问
@property (assign,nonatomic) NSInteger totalQ;//总问题
@property (assign,nonatomic) NSInteger askedQ;//回答过的问题
@property (assign,nonatomic) NSInteger perQ; //每人的问题

-(instancetype)initWithDictionary:(NSDictionary *)dic;

- (NSString *)create_time:(NSString*)timeStr;


@end
