//
//  modifePasswordViewController.m
//  Yizhenapp
//
//  Created by augbase on 16/7/4.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "modifePasswordViewController.h"

@interface modifePasswordViewController ()

{
    UIButton*sectureButton;//控制密码的明暗文
    BOOL showPasswordOrNot;
    NSString *randomStr;
}
@end

@implementation modifePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _registViewOne = [[ImageViewLabelTextFieldView alloc]initWithFrame:CGRectMake(40, 74, ViewWidth-90, 50)];
    
    _registViewOne.contentTextField.placeholder = NSLocalizedString(@"新密码", @"");
    _registViewOne.contentTextField.secureTextEntry = YES;
    _registViewOne.contentTextField.keyboardType = UIKeyboardTypeASCIICapable;
    sectureButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [sectureButton addTarget:self action:@selector(changeSecture) forControlEvents:UIControlEventTouchUpInside];
    [sectureButton setBackgroundImage:[UIImage imageNamed:@"not_visible"] forState:UIControlStateNormal];
    _registViewOne.contentTextField.rightView=sectureButton;
    _registViewOne.contentTextField.rightViewMode=UITextFieldViewModeAlways;
    
    
    _finishButton = [[UIButton alloc]init];
    [_finishButton addTarget:self action:@selector(finishEdit) forControlEvents:UIControlEventTouchUpInside];
    _finishButton.backgroundColor = themeColor;
    [_finishButton setTitle:NSLocalizedString(@"重置", @"") forState:UIControlStateNormal];
    [_finishButton.layer setMasksToBounds:YES];
    [_finishButton.layer setCornerRadius:10.0];
    
    [self.view addSubview:_registViewOne];
    [self.view addSubview:_finishButton];
    
    //autolayout
    [_finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@50);
        make.top.equalTo(_registViewOne.mas_bottom).with.offset(50);
        make.right.equalTo(@-60);
        make.left.equalTo(@60);
    }];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    randomStr=SuiJiShu;
    showPasswordOrNot=YES;
    self.navigationItem.title=@"重置密码";
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0,2, 120, 30)];
    [loginButton setImage:[UIImage imageNamed:@"back_w"] forState:UIControlStateNormal];
    [loginButton setImageEdgeInsets:UIEdgeInsetsMake(0, -18, 0, 0)];
    loginButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [loginButton addTarget:self action:@selector(backToLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:loginButton]];
}

-(void)backToLogin
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma 完成修改密码
-(void)finishEdit{
    
    if ([self ensurePassword]) {
        NSString *url = [NSString stringWithFormat:@"%@v3/common/resetPassword",Baseurl];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:_resetKey forKey:@"resetKey"];
        [dic setObject:_registViewOne.contentTextField.text forKey:@"newPassword"];
        [dic setObject:randomStr forKey:@"random"];
        [[HttpManager ShareInstance]AFNetPOSTNobodySupport:url Parameters:dic SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            int res=[[source objectForKey:@"res"] intValue];
            NSLog(@"res===%d",res);
            if (res == 0) {
                //请求完成
//                [[SetupView ShareInstance]showTextHUD:self Title:@"重置密码成功，请重新登录"];
                NSNotificationCenter*center=[NSNotificationCenter defaultCenter];
                [center postNotificationName:@"modifeKey" object:@YES];
                
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            }else{
                [[SetupView ShareInstance]hideHUD];
                [[SetupView ShareInstance]showAlertViewOneButton:NSLocalizedString(@"请重新操作", @"") Title:NSLocalizedString(@"修改失败", @"") ViewController:self];
                
            }
        } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

-(void)changeSecture{
    if (showPasswordOrNot) {
        _registViewOne.contentTextField.secureTextEntry = NO;
        showPasswordOrNot = NO;
        [sectureButton setBackgroundImage:[UIImage imageNamed:@"visible"] forState:UIControlStateNormal];
    }else{
        _registViewOne.contentTextField.secureTextEntry = YES;
        showPasswordOrNot = YES;
        [sectureButton setBackgroundImage:[UIImage imageNamed:@"not_visible"] forState:UIControlStateNormal];
    }
}

-(BOOL)ensurePassword
{
    //判断密码格式是否正确
    if (_registViewOne.contentTextField.text.length>5) {
        return YES;
    }
    else
    {
        [[SetupView ShareInstance] showAlertViewNoButtonMessage:@"密码至少六位数" Title:@"提示" viewController:self];
        return NO;
        
    }
}

#pragma 取消输入操作
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


@end
