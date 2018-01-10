//
//  accomplishRegistViewController.h
//  Yizhenapp
//
//  Created by augbase on 16/7/4.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewLabelTextFieldView.h"

@interface accomplishRegistViewController : UIViewController

@property (nonatomic,strong) ImageViewLabelTextFieldView *phoneCodeText;//手机号码框
@property (nonatomic,strong) ImageViewLabelTextFieldView *testCodeText;//验证码框
@property (nonatomic,strong) ImageViewLabelTextFieldView *passWordText;//密码框

@end
