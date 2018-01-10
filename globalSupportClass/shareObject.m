//
//  shareObject.m
//  Yizhenapp
//
//  Created by 王浩 on 16/11/3.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "shareObject.h"


@implementation shareObject

-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        self.shareTitle=dic[@"title"];
        self.shareContent=dic[@"content"];
        self.shareUrl=dic[@"url"];
    }
    return self;
}


@end
