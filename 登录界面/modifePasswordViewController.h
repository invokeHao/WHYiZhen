//
//  modifePasswordViewController.h
//  Yizhenapp
//
//  Created by augbase on 16/7/4.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewLabelTextFieldView.h"


@interface modifePasswordViewController : UIViewController

@property (nonatomic,strong) ImageViewLabelTextFieldView *registViewOne;


@property (nonatomic,strong) UIButton *finishButton;

@property (nonatomic,strong) NSString *resetKey;//重置密码的key

@end
