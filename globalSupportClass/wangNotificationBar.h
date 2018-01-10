//
//  wangNotificationBar.h
//  Yizhenapp
//
//  Created by 王浩 on 16/11/9.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <UIKit/UIKit.h>

//自定义通知栏，类似安卓
@interface wangNotificationBar : UIView

@property (strong,nonatomic)UIImageView * IconView;

@property (strong,nonatomic)UILabel * contentLabel;

@property (strong,nonatomic)NSString * content;//推送内容

@property (strong,nonatomic)NSString * imageUrl;


-(instancetype)initWithFrame:(CGRect)frame;

-(void)show;
@end
