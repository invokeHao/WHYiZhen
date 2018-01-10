//
//  findPasswordViewController.h
//  Yizhenapp
//
//  Created by augbase on 16/7/5.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewLabelTextFieldView.h"

@interface findPasswordViewController : UIViewController

//键盘输入
@property (nonatomic,strong) ImageViewLabelTextFieldView *phoneNumberView;

//手机验证码输入
@property (nonatomic,strong) ImageViewLabelTextFieldView *phoneCodeView;

@end
