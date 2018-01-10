//
//  answerModel.h
//  Yizhenapp
//
//  Created by augbase on 16/8/31.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface answerModel : NSObject

@property (strong,nonatomic) NSString * doctorAvatar;//医生头像
@property (assign,nonatomic) NSInteger doctorId; //医生的id
@property (strong,nonatomic) NSString * doctorIntro;//医生的简介
@property (strong,nonatomic) NSString * doctorIntroLink;//医生简介的link
@property (strong,nonatomic) NSString * doctorName;//医生的名字
@property (assign,nonatomic) BOOL hasClosed;//直播是否已结束
@property (assign,nonatomic) BOOL hasAttend;//是否入场
@property (assign,nonatomic) NSInteger IDS;//该场直播的id
@property (strong,nonatomic) NSString * intro;//直播的简介
@property (strong,nonatomic) NSString * startTime;
@property (strong,nonatomic) NSString * startShowTime;//开始时间
@property (strong,nonatomic) NSString * tag;//第几期
@property (strong,nonatomic) NSString * title;//标题
@property (assign,nonatomic) NSInteger attends;//入场人数

//cell的高度
@property (assign,nonatomic) CGFloat cellHeight;

-(instancetype)initWithDictionary:(NSDictionary*)dic;

-(BOOL)liveIsOpen;

@end
