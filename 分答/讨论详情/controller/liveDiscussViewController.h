//
//  liveDiscussViewController.h
//  Yizhenapp
//
//  Created by augbase on 16/9/5.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BackBlock) (BOOL isBack);
@interface liveDiscussViewController : UIViewController

@property (assign,nonatomic)NSInteger liveId;//直播id

@property (strong,nonatomic)BackBlock backB;//返回的block,主要用于控制心跳

@property (assign,nonatomic)BOOL hasClosed;//直播已关闭

-(void)setBackB:(BackBlock)backB;
@end
