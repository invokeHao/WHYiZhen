//
//  pointsModel.h
//  Yizhenapp
//
//  Created by augbase on 16/5/8.
//  Copyright © 2016年 wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface pointsModel : NSObject

@property (strong,nonatomic)NSString *currentLevel;
@property (strong,nonatomic)NSString *nextLevel;
@property (assign,nonatomic)NSInteger ranking;
@property (assign,nonatomic)NSInteger totalScore;
@property (assign,nonatomic)NSInteger minScore;
@property (assign,nonatomic)NSInteger maxScore;


@end
