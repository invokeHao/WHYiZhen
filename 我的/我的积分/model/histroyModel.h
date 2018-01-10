//
//  histroyModel.h
//  Yizhenapp
//
//  Created by augbase on 16/5/9.
//  Copyright © 2016年 wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface histroyModel : NSObject

@property (assign,nonatomic)long createTime;
@property (strong,nonatomic)NSString *desc;
@property (assign,nonatomic)int score;


-(instancetype)initWithDictionary:(NSDictionary*)dic;
-(NSString*)create_time;
@end
