//
//  findPasswordViewController.m
//  Yizhenapp
//
//  Created by augbase on 16/7/5.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "findPasswordViewController.h"
#import "modifePasswordViewController.h"

@interface findPasswordViewController ()

{
    UIButton*confimBtn;//确定按钮
    UIButton*getCodeBtn;//重新获取验证码按钮
    NSInteger countTime;//倒计时计数
    NSTimer *delayTimer;//计数器
    NSString*randomStr;
}
@end

@implementation findPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
}

-(void)creatUI
{
    CGFloat spaceRoom=0;
    _phoneNumberView = [[ImageViewLabelTextFieldView alloc]initWithFrame:CGRectMake(40, 94-spaceRoom, ViewWidth-90, 50)];
    _phoneNumberView.contentTextField.placeholder = NSLocalizedString(@"手机号码", @"");
    _phoneNumberView.contentTextField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneCodeView=[[ImageViewLabelTextFieldView alloc]initWithFrame:CGRectMake(40, 149-spaceRoom, ViewWidth-90, 50)];
    _phoneCodeView.contentTextField.placeholder=@"手机验证码";
    _phoneCodeView.contentTextField.keyboardType=UIKeyboardTypeNumberPad;

    [self.view addSubview:_phoneCodeView];
    [self.view addSubview:_phoneNumberView];
    
    getCodeBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 85, 25)];
    [getCodeBtn setTitleColor:themeColor forState:UIControlStateNormal];
    [getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    getCodeBtn.titleLabel.font=[UIFont systemFontOfSize:16.0];
    [getCodeBtn addTarget:self action:@selector(getPhoneCodeAgain) forControlEvents:UIControlEventTouchUpInside];
    getCodeBtn.layer.cornerRadius=10;
    getCodeBtn.layer.masksToBounds=YES;
    
    _phoneCodeView.contentTextField.rightView=getCodeBtn;
    _phoneCodeView.contentTextField.rightViewMode=UITextFieldViewModeAlways;
    confimBtn = [[UIButton alloc]init];
    confimBtn.backgroundColor = themeColor;
    [confimBtn setTitle:NSLocalizedString(@"确定", @"") forState:UIControlStateNormal];
    [confimBtn viewWithRadis:10.0];
    [confimBtn addTarget:self action:@selector(gotoModifyPassword) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confimBtn];
    
    [confimBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@50);
        make.top.equalTo(_phoneCodeView.mas_bottom).with.offset(50);
        make.right.equalTo(@-50);
        make.left.equalTo(@50);
    }];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.title = NSLocalizedString(@"忘记密码", @"");
    randomStr=SuiJiShu;
    //去登陆界面
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0,2, 120, 30)];
    loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    loginButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [loginButton setTitle:NSLocalizedString(@"已有账号登陆", @"") forState:UIControlStateNormal];
    [loginButton setTitleColor:themeColor forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginView) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:loginButton]];
    
}


-(void)loginView
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark-重新获取手机验证码
-(void)getPhoneCodeAgain
{
    if (countTime!=0) {
        return;
    }
    [self getMessageCode];
}

-(void)countNumber
{
    countTime--;
    [getCodeBtn setTitle:[NSString stringWithFormat:@"%d",(int)countTime] forState:UIControlStateNormal];
    [getCodeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    getCodeBtn.userInteractionEnabled=NO;
    [getCodeBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [getCodeBtn setTitleColor:grayLabelColor forState:UIControlStateNormal];
    if (countTime == 0) {
        [delayTimer invalidate];
        delayTimer = nil;
        getCodeBtn.userInteractionEnabled = YES;
        [getCodeBtn setTitleColor:themeColor forState:UIControlStateNormal];
        [getCodeBtn setTitle:@"重获验证码" forState:UIControlStateNormal];
    }
    
}
-(void)gotoModifyPassword
{
    //在这里做判断
    if ([self isValidateMobile:_phoneNumberView.contentTextField.text]) {
        [self comfimThePhoneCode];
    }
    else
    {
        [[SetupView ShareInstance]showAlertViewNoButtonMessage:@"手机号格式不正确" Title:@"提示" viewController:self];
    }
}


/*手机号码验证 MODIFIED BY HELENSONG*/
-(BOOL) isValidateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(17[0-9])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    //    NSLog(@"phoneTest is %@",phoneTest);
    return [phoneTest evaluateWithObject:mobile];
}

-(void) getMessageCode
{
    if ([self isValidateMobile:_phoneNumberView.contentTextField.text]) {
        //发送验证码
        [[SetupView ShareInstance]showTextHUD:self Title:@"验证码已发送"];
        NSString*url=[NSString stringWithFormat:@"%@/v3/common/forgetValidate",Baseurl];
        NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_phoneNumberView.contentTextField.text,randomStr,nil] forKeys:[NSArray arrayWithObjects:@"phone",@"random",nil]];
        [[HttpManager ShareInstance] AFNetPOSTNobodySupport:url Parameters:dic SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            int res=[[source objectForKey:@"res"] intValue];
            YiZhenLog(@"res==%d",res);
            if (res==0) {
                YiZhenLog(@"success");
                //进入倒计时
                countTime=countAgainNumber;
                getCodeBtn.userInteractionEnabled=NO;
                [delayTimer invalidate];
                delayTimer=nil;
                delayTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countNumber) userInfo:nil repeats:YES];
            }
            else if (res==808)
            {
                randomStr=SuiJiShu;
                [[SetupView ShareInstance] showAlertViewNoButtonMessage:@"用户不存在" Title:@"提示" viewController:self];
            }
            else if(res==803)
            {
                randomStr=SuiJiShu;
                [[SetupView ShareInstance] showAlertViewNoButtonMessage:@"短信验证码输入错误" Title:@"提示" viewController:self];
            }
            else if (res==802)
            {
                randomStr=SuiJiShu;
                [[SetupView ShareInstance] showAlertViewNoButtonMessage:@"短信验证码发送失败" Title:@"提示" viewController:self];
            }
            
            else if (res==804)
            {
                randomStr=SuiJiShu;
                [[SetupView ShareInstance] showAlertViewNoButtonMessage:@"手机号格式不正确" Title:@"提示" viewController:self];
            }
            else if (res==805)
            {
                randomStr=SuiJiShu;
                [[SetupView ShareInstance] showAlertViewNoButtonMessage:@"该手机号已被注册" Title:@"提示" viewController:self];
            }
            else if (res==103)
            {
                [[SetupView ShareInstance] showAlertViewNoButtonMessage:@"您的操作太过频繁" Title:@"提示" viewController:self];
            }
            
        } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            YiZhenLog(@"%@",error);
        }];
    }
    else{
        [[SetupView ShareInstance]showAlertViewNoButtonMessage:@"手机号格式不正确" Title:@"提示" viewController:self];
    }
}

-(void)comfimThePhoneCode
{
    NSString*url=[NSString stringWithFormat:@"%@v3/common/forget",Baseurl];
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_phoneNumberView.contentTextField.text,_phoneCodeView.contentTextField.text,randomStr,nil] forKeys:[NSArray arrayWithObjects:@"phone",@"code",@"random",nil]];
    [[HttpManager ShareInstance] AFNetPOSTNobodySupport:url Parameters:dic SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        YiZhenLog(@"res==%d",res);
        if (res==0) {
            YiZhenLog(@"success");
            NSString*resetKey=[source objectForKey:@"data"];
            modifePasswordViewController*modifepassVC=[[modifePasswordViewController alloc]init];
            modifepassVC.resetKey=resetKey;
            [self.navigationController pushViewController:modifepassVC animated:YES];
        }
        else if(res==803)
        {
            randomStr=SuiJiShu;
            [[SetupView ShareInstance] showAlertViewNoButtonMessage:@"请重新获取验证码后输入" Title:@"验证码输入错误" viewController:self];
        }
        else if (res==802)
        {
            randomStr=SuiJiShu;
            [[SetupView ShareInstance] showAlertViewNoButtonMessage:@"短信验证码发送失败" Title:@"提示" viewController:self];
        }
        
        else if (res==804)
        {
            randomStr=SuiJiShu;
            [[SetupView ShareInstance] showAlertViewNoButtonMessage:@"手机号格式不正确" Title:@"提示" viewController:self];
        }
        else if (res==805)
        {
            randomStr=SuiJiShu;
            [[SetupView ShareInstance] showAlertViewNoButtonMessage:@"该手机号已被注册" Title:@"提示" viewController:self];
        }
        else if (res==808)
        {
            randomStr=SuiJiShu;
            [[SetupView ShareInstance] showAlertViewNoButtonMessage:@"用户不存在" Title:@"提示" viewController:self];
        }

        
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
}



#pragma 取消输入操作
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


@end
