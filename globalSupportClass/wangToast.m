//
//  wangToast.m
//  Yizhenapp
//
//  Created by 王浩 on 16/11/22.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "wangToast.h"

@implementation wangToast


-(instancetype)init
{
    self=[super init];
    if (self) {
        [self createUI];
    }
    return self;
}

-(void)createUI
{
    self.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    self.layer.cornerRadius=10;
    self.layer.masksToBounds=YES;
    showLabel=[[UILabel alloc]init];
    showLabel.font=[UIFont systemFontOfSize:16.0];
    showLabel.numberOfLines=0;
    showLabel.textAlignment=NSTextAlignmentCenter;
    showLabel.textColor=[UIColor whiteColor];
    showLabel.text=_titleStr;
    [self addSubview:showLabel];
    
    [showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.top.equalTo(@10);
        make.right.equalTo(@-20);
    }];
}

-(void)show{
    showLabel.text=_titleStr;
    CGSize maxSize = CGSizeMake(ViewWidth-100-40, MAXFLOAT);
    // 计算文字的高度
    CGFloat titleH = [_titleStr boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0] } context:nil].size.height;
    [self setFrame:CGRectMake(50, ViewHeight/2-64, ViewWidth-100, titleH+20)];

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    [window bringSubviewToFront:self];
    [self performSelector:@selector(hide) withObject:nil afterDelay:3.5];
    
}

-(void)hide
{
    [self removeFromSuperview];
}

@end
