//
//  wangNotificationBar.m
//  Yizhenapp
//
//  Created by 王浩 on 16/11/9.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "wangNotificationBar.h"

@implementation wangNotificationBar

-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

-(void)createUI
{
    self.backgroundColor=themeColor;
    self.layer.cornerRadius=10;
    self.layer.masksToBounds=YES;
    _IconView=[[UIImageView alloc]init];
    [_IconView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_IconView];
    
    _contentLabel=[[UILabel alloc]init];
    _contentLabel.font=YiZhenFont;
    _contentLabel.textColor=[UIColor whiteColor];
    _contentLabel.numberOfLines=0;
    [self addSubview:_contentLabel];
    
    [_IconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_IconView.mas_right).with.offset(6);
        make.centerY.mas_equalTo(self);
        make.height.equalTo(@22);
    }];
}

-(void)show
{
    _contentLabel.text=_content;
    [_IconView setImage:[UIImage imageNamed:_imageUrl]];

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    [window bringSubviewToFront:self];
    
    CGRect beginiRect= self.frame;
    beginiRect.origin.y=20;
    [UIView animateWithDuration:0.5 animations:^{
        self.frame=beginiRect;
    } completion:^(BOOL finished) {
        
    }];
    [self performSelector:@selector(hiden) withObject:nil afterDelay:2.7];
}

-(void)hiden
{
    CGRect beginiRect= self.frame;
    beginiRect.origin.y=-64;
    [UIView animateWithDuration:0.5 animations:^{
        self.frame=beginiRect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end
