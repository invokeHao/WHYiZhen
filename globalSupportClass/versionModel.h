//
//  versionModel.h
//  Yizhenapp
//
//  Created by augbase on 16/7/11.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface versionModel : NSObject

@property (strong,nonatomic)NSString*appUrl; //app下载地址

@property (strong,nonatomic)NSString * version;//当前版本号

@property (assign,nonatomic)BOOL forceUpdate;//是否强制更新

@property (strong,nonatomic)NSString *releaseNote;//更新日志

-(instancetype)initWithdictionary:(NSDictionary*)dic;
@end
