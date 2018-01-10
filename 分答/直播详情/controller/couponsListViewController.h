//
//  couponsListViewController.h
//  Yizhenapp
//
//  Created by 王浩 on 16/11/10.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <UIKit/UIKit.h>

//可以使用的优惠券列表

typedef void (^couponBlock) (NSInteger couId);

@interface couponsListViewController : UIViewController

@property (assign,nonatomic) NSInteger liveId;//直播Id

@property (assign,nonatomic)NSInteger checkId;

@property (strong,nonatomic) couponBlock couBlock;//传递couponId的block

-(void)setCouBlock:(couponBlock)couBlock;

@end
