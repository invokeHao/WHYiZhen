//
//  versionModel.m
//  Yizhenapp
//
//  Created by augbase on 16/7/11.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "versionModel.h"

@implementation versionModel

-(instancetype)initWithdictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        self.appUrl=dic[@"URL"];
        self.forceUpdate=[dic[@"forceUpdate"] boolValue];
        self.version=dic[@"version"];
        self.releaseNote=dic[@"releaseNote"];
    }
    return self;
}

@end
