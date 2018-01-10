//
//  liveDetailViewController.h
//  Yizhenapp
//
//  Created by augbase on 16/9/1.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "liveDetailModel.h"

@interface liveDetailViewController : UIViewController

@property (assign,nonatomic)NSInteger IDS;//直播的id
@property (assign,nonatomic)BOOL hadJoin;//已经加入直播
@property (strong,nonatomic)liveDetailModel * liveModel;

@end
