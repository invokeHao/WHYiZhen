//
//  homeModel.h
//  Yizhenapp
//
//  Created by augbase on 16/5/4.
//  Copyright © 2016年 wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface homeModel : NSObject

@property (assign,nonatomic)NSInteger collectAmount;
@property (assign,nonatomic)NSInteger friendAmount;
@property (assign,nonatomic)BOOL isUnread;
@property (strong,nonatomic)NSString *messageAvatar;
@property (strong,nonatomic)NSString *nickname;
@property (assign,nonatomic)NSInteger score;
@property (strong,nonatomic)NSString *avatar;
@property (assign,nonatomic)NSInteger topicAmount;
@property (assign,nonatomic)NSInteger replyAmount;//收到的回复数
@property (assign,nonatomic)NSInteger couponAmount;//优惠券数
@property (assign,nonatomic)NSInteger liveAmount;//参与的直播数

-(instancetype)initWithDictionary:(NSDictionary*)dic;
@end
