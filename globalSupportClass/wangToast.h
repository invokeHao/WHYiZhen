//
//  wangToast.h
//  Yizhenapp
//
//  Created by 王浩 on 16/11/22.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface wangToast : UIView
{
    UILabel * showLabel;
}
@property (strong,nonatomic) NSString * titleStr;//显示的提示
-(instancetype)initWithFrame:(CGRect)frame;
-(void)show;
@end
