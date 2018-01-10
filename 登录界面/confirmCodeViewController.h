//
//  confirmCodeViewController.h
//  Yizhenapp
//
//  Created by augbase on 16/7/1.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewLabelTextFieldView.h"

@interface confirmCodeViewController : UIViewController

@property (nonatomic,strong) ImageViewLabelTextFieldView *phoneView;//手机号框
@property (nonatomic,strong) ImageViewLabelTextFieldView *idCode;//验证码框

@end
