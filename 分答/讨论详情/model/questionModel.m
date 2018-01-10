//
//  questionModel.m
//  Yizhenapp
//
//  Created by 王浩 on 16/11/10.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "questionModel.h"

@implementation questionModel

//"liveTotal":50,
//"liveAsked":39,
//"myTotal":3,
//"myAsked":3,
//"canHelp":false

-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        self.liveTotal=[dic[@"liveTotal"] integerValue];
        self.liveAsked=[dic[@"liveAsked"] integerValue];
        self.myTotal=[dic[@"myTotal"] integerValue];
        self.myAsked=[dic[@"myAsked"] integerValue];
        self.canHelp=[dic[@"canHelp"] boolValue];
    }
    return self;
}

@end
