//
//  informationModel.h
//  Yizhenapp
//
//  Created by augbase on 16/5/9.
//  Copyright © 2016年 wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface informationModel : NSObject

@property (assign,nonatomic)NSInteger IDS;
@property (strong,nonatomic)NSString *picURL;
@property (strong,nonatomic)NSString *title;
@property (assign,nonatomic)long createTime;
@property (strong,nonatomic)NSString *moduleName;

-(instancetype)initWithDictionary:(NSDictionary*)dic;
- (NSString *)create_time;
@end
