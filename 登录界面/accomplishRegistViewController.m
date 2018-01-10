//
//  accomplishRegistViewController.m
//  Yizhenapp
//
//  Created by augbase on 16/7/4.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "accomplishRegistViewController.h"
#import "ServiceAndPrivateWebViewController.h"
#import "wangTabBarController.h"
#import "AppDelegate.h"

@interface accomplishRegistViewController ()
{
    UIButton*finishBtn;//完成按钮
    UIButton *getCodeBtn;//重获验证码按钮
    UIButton*sectureButton;//明文暗文
    UIView *noticeView;
    BOOL showPasswordOrNot;
    float countTime;//倒计时时间
    NSTimer *delayTimer;//倒计时timer
    NSString*randomStr;//防止重复点击
}
@end

@implementation accomplishRegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    randomStr=SuiJiShu;
    [_phoneCodeText.contentTextField becomeFirstResponder];
    countTime=countAgainNumber;

    [self creatUI];
}

-(void)creatUI
{

    
    _phoneCodeText = [[ImageViewLabelTextFieldView alloc]initWithFrame:CGRectMake(40, 74, ViewWidth-90, 50)];
    _testCodeText =[[ImageViewLabelTextFieldView alloc]initWithFrame:CGRectMake(40, 74+44+7, ViewWidth-90, 50)];
    _passWordText = [[ImageViewLabelTextFieldView alloc]initWithFrame:CGRectMake(40, 74+44+44+15, ViewWidth-90, 50)];
    _phoneCodeText.contentTextField.placeholder=@"手机号码";
    _phoneCodeText.contentTextField.keyboardType=UIKeyboardTypeNumberPad;
    _testCodeText.contentTextField.placeholder=@"输入验证码";
    _testCodeText.contentTextField.keyboardType=UIKeyboardTypeNumberPad;
    _passWordText.contentTextField.placeholder=@"输入密码";
    
    [self.view addSubview:_phoneCodeText];
    [self.view addSubview:_testCodeText];
    [self.view addSubview:_passWordText];
    //明暗文按钮
    sectureButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [sectureButton addTarget:self action:@selector(changeSecture) forControlEvents:UIControlEventTouchUpInside];
    [sectureButton setBackgroundImage:[UIImage imageNamed:@"not_visible"] forState:UIControlStateNormal];
    _passWordText.contentTextField.placeholder = NSLocalizedString(@"密码", @"");
    _passWordText.contentTextField.secureTextEntry = YES;
    _passWordText.contentTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _passWordText.contentTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _passWordText.contentTextField.rightView=sectureButton;
    _passWordText.contentTextField.rightViewMode=UITextFieldViewModeAlways;
    showPasswordOrNot = YES;
    
    //重新获取手机验证码按钮
    getCodeBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 85, 25)];
    getCodeBtn.titleLabel.font=[UIFont systemFontOfSize:16.0];
    [getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCodeBtn setTitleColor:themeColor forState:UIControlStateNormal];
    [getCodeBtn addTarget:self action:@selector(getPhoneCode) forControlEvents:UIControlEventTouchUpInside];
    
    _testCodeText.contentTextField.rightViewMode=UITextFieldViewModeAlways;
    _testCodeText.contentTextField.rightView=getCodeBtn;
    //按钮
    finishBtn = [[UIButton alloc]init];
    [finishBtn setTitle:NSLocalizedString(@"注册", @"") forState:UIControlStateNormal];
    [finishBtn setBackgroundColor:themeColor];
    [finishBtn viewWithRadis:10.0];
    [finishBtn addTarget:self action:@selector(finishTheRegist) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finishBtn];
    
    [finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@50);
        make.top.equalTo(_passWordText.mas_bottom).with.offset(50);
        make.right.equalTo(@-50);
        make.left.equalTo(@50);
    }];
    
    noticeView = [[UIView alloc]init];
    UIButton *privateNoticeButton = [[UIButton alloc]init];
    [privateNoticeButton setTitle:NSLocalizedString(@"隐私条款", @"") forState:UIControlStateNormal];
    [privateNoticeButton setTitleColor:themeColor forState:UIControlStateNormal];
    [privateNoticeButton addTarget:self action:@selector(showPrivate) forControlEvents:UIControlEventTouchUpInside];
    privateNoticeButton.titleLabel.font = [UIFont systemFontOfSize:11.0];
    UILabel  *noticeLabel = [[UILabel alloc]init];
    noticeLabel.text = NSLocalizedString(@"  点击完成，表示您同意", @"");
    noticeLabel.font = [UIFont systemFontOfSize:11.0];
    noticeLabel.textColor = grayLabelColor;
    [noticeView addSubview:noticeLabel];
    [noticeView addSubview:privateNoticeButton];
    [self.view addSubview:noticeView];
    
    [noticeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@20);
        make.top.equalTo(finishBtn.mas_bottom).with.offset(15);
        make.width.equalTo(@180);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [noticeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@20);
        make.top.equalTo(noticeView.mas_top).with.offset(0);
        make.left.equalTo(noticeView.mas_left).with.offset(0);
        make.right.equalTo(privateNoticeButton.mas_left).with.offset(-3);
    }];
    [privateNoticeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@20);
        make.top.equalTo(noticeView.mas_top).with.offset(0);
        make.left.equalTo(noticeLabel.mas_right).with.offset(3);
    }];
}

-(void)viewWillAppear:(BOOL)animated
{

    randomStr=SuiJiShu;
    self.title=@"注册";
    [super viewWillAppear:animated];
}

#pragma mark-完成注册

-(void)finishTheRegist
{
    NSString*url=[NSString stringWithFormat:@"%@/v3/common/regist",Baseurl];
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_phoneCodeText.contentTextField.text,_passWordText.contentTextField.text,_testCodeText.contentTextField.text,randomStr,nil] forKeys:[NSArray arrayWithObjects:@"phone",@"password",@"code",@"random",nil]];
    [[HttpManager ShareInstance] AFNetPOSTNobodySupport:url Parameters:dic SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        YiZhenLog(@"res==%d",res);
        if (res==0) {
            YiZhenLog(@"success");
            //进行登录操作
            [[NSUserDefaults standardUserDefaults] setObject:_phoneCodeText.contentTextField.text forKey:phoneNO];
            [self gotoMainView];
        }
        else{
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:self];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
        randomStr=SuiJiShu;
    }];

}

#pragma mark-点击取消输入

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark-更改明暗文
-(void)changeSecture{
    if (showPasswordOrNot) {
        _passWordText.contentTextField.secureTextEntry = NO;
        showPasswordOrNot = NO;
        [sectureButton setBackgroundImage:[UIImage imageNamed:@"visible"] forState:UIControlStateNormal];
    }else{
        _passWordText.contentTextField.secureTextEntry = YES;
        showPasswordOrNot = YES;
        [sectureButton setBackgroundImage:[UIImage imageNamed:@"not_visible"] forState:UIControlStateNormal];
    }
}

#pragma 显示隐私条款等
-(void)showPrivate{
    YiZhenLog(@"显示隐私条款");
    ServiceAndPrivateWebViewController *spv = [[ServiceAndPrivateWebViewController alloc]init];
    spv.url = @"http://h.yizhenapp.com/?p=1129";
    spv.WebTitle = NSLocalizedString(@"隐私条款", @"");
    [self.navigationController pushViewController:spv animated:YES];
}


#pragma mark-重新获取手机验证码
-(void)getPhoneCode
{
    // 验证手机号
    [self getTheSingCode];
    
    if (delayTimer) {
        [delayTimer invalidate];
        delayTimer=nil;
    }
    [getCodeBtn setTitle:[NSString stringWithFormat:@"%d",(int)countTime] forState:UIControlStateNormal];
    [getCodeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    getCodeBtn.userInteractionEnabled=NO;
    [getCodeBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [getCodeBtn setTitleColor:grayLabelColor forState:UIControlStateNormal];
    
    delayTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countNumber) userInfo:nil repeats:YES];
}

-(void)countNumber
{
    countTime--;
    [getCodeBtn setTitle:[NSString stringWithFormat:@"%d",(int)countTime] forState:UIControlStateNormal];
    if (countTime == 0) {
        countTime=countAgainNumber;
        [delayTimer invalidate];
        randomStr=SuiJiShu;
        delayTimer = nil;
        getCodeBtn.userInteractionEnabled = YES;
        [getCodeBtn setTitleColor:themeColor forState:UIControlStateNormal];
        [getCodeBtn setTitle:@"重发" forState:UIControlStateNormal];
    }

}
#pragma mark-验证手机号获取验证啊
-(void)getTheSingCode
{
    NSString *url = [NSString stringWithFormat:@"%@v3/common/validate",Baseurl];
    NSDictionary *dicc=[NSDictionary dictionaryWithObject:_phoneCodeText.contentTextField.text forKey:@"phone"];
    
    [[HttpManager ShareInstance] AFNetPOSTNobodySupport:url Parameters:dicc SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res==0) {
            YiZhenLog(@"获取验证码成功");
        }
        else
        {
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:self];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error){
        YiZhenLog(@"%@",error);
        [[SetupView ShareInstance]showAlertView:NSLocalizedString(@"请检查您的网络", @"") Title:NSLocalizedString(@"网路出错", @"") ViewController:self];
        [[SetupView ShareInstance]hideHUD];
    }];
}


#pragma 登录的响应函数
-(void)gotoMainView{
    [self.view endEditing:YES];
    if ([self ensurePassword]) {
        [[SetupView ShareInstance]showHUD:self Title:@"登录中..."];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[defaults objectForKey:phoneNO] forKey:@"userName"];
        [defaults setObject:_passWordText.contentTextField.text forKey:@"userPassword"];
        
        NSString *url = [NSString stringWithFormat:@"%@v3/common/login",Baseurl];
        NSMutableDictionary *loginDic = [NSMutableDictionary dictionary];
        [loginDic setValue:[defaults objectForKey:@"userName"] forKey:@"loginName"];
        [loginDic setValue:[defaults objectForKey:@"userPassword"] forKey:@"password"];
        [loginDic setObject:randomStr forKey:@"random"];
        url = [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer=[AFHTTPRequestSerializer serializer];
        [manager POST:url parameters:loginDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"responseObject=%@",responseObject);
            NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary*Udic=[source objectForKey:@"data"];
            int res=[[source objectForKey:@"res"] intValue];
            YiZhenLog(@"登陆的返回res====%d",res);
            if (res==0) {
                //请求完成
                [defaults setObject:[Udic objectForKey:@"uid"] forKey:@"userUID"];
                [defaults setObject:[Udic objectForKey:@"token"] forKey:@"userToken"];
                [self openGtServer];
            }
            else{
                randomStr=SuiJiShu;
                [[SetupView ShareInstance] showAlertView:res Hud:nil ViewController:self];
            }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            YiZhenLog(@"WEB端登录失败");
            randomStr=SuiJiShu;
            [[SetupView ShareInstance]hideHUD];
            [[SetupView ShareInstance]showAlertView:NSLocalizedString(@"请检查您的网络", @"") Title:NSLocalizedString(@"网路出错", @"") ViewController:self];
        }];
    }
}

#pragma mark-后台打开个推服务
-(void)openGtServer
{
    NSString *url = [NSString stringWithFormat:@"%@v3/common/push/on",Baseurl];
    NSUserDefaults*defaults=[NSUserDefaults standardUserDefaults];
    NSString *yzuid = [defaults objectForKey:@"userUID"];
    NSString *yztoken = [defaults objectForKey:@"userToken"];
    NSString *clientId=[defaults objectForKey:@"cid"];
    NSDictionary *dicc=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:yzuid,yztoken,clientId,@"0",randomStr,nil] forKeys:[NSArray arrayWithObjects:@"uid",@"token",@"cid",@"deviceType",@"random",nil]];
    
    [[HttpManager ShareInstance] AFNetPOSTNobodySupport:url Parameters:dicc SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res==0) {
            [self loginToYizhen];
            YiZhenLog(@"打开推送success");
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error){
        YiZhenLog(@"%@",error);
        [[SetupView ShareInstance]showAlertView:NSLocalizedString(@"请检查您的网络", @"") Title:NSLocalizedString(@"网路出错", @"") ViewController:self];
        [[SetupView ShareInstance]hideHUD];
    }];
}


-(void)loginToYizhen
{
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"NotFirstTime"];
    wangTabBarController *wangTabelVC=[[wangTabBarController alloc]init];
//    wangTabelVC.selectedIndex=1;
    
    ControlAllNavigationViewController*navVC=[[ControlAllNavigationViewController alloc]initWithRootViewController:wangTabelVC];
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.window.rootViewController =navVC ;
    
}


-(BOOL)ensurePassword
{
    //判断密码格式是否正确
    if (_passWordText.contentTextField.text.length>5) {
        return YES;
    }
    else
    {
        [[SetupView ShareInstance] showAlertViewNoButtonMessage:@"密码至少六位数" Title:@"提示" viewController:self];
        return NO;

    }
}


@end
