//
//  questionModel.h
//  Yizhenapp
//
//  Created by 王浩 on 16/11/10.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <Foundation/Foundation.h>

//问题model

@interface questionModel : NSObject

@property (assign,nonatomic)NSInteger liveTotal;
@property (assign,nonatomic)NSInteger liveAsked;
@property (assign,nonatomic)NSInteger myTotal;
@property (assign,nonatomic)NSInteger myAsked;
@property (assign,nonatomic)BOOL canHelp;

-(instancetype)initWithDictionary:(NSDictionary*)dic;


@end
