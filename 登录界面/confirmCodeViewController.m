//
//  confirmCodeViewController.m
//  Yizhenapp
//
//  Created by augbase on 16/7/1.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "confirmCodeViewController.h"
#import "accomplishRegistViewController.h"

@interface confirmCodeViewController ()

{
    UIButton*getCodeBtn;//获取验证码按钮
    UIButton*codeImageBtn;//图片验证码
    NSString*seedID;//获取图片验证码的时候获取一次seedID，每次都刷新以保证是最新的
    BOOL isSuccess;
    NSString*randomStr;
}
@end

@implementation confirmCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

-(void)createUI
{
    int spaceRoom = 0;
    
    _phoneView = [[ImageViewLabelTextFieldView alloc]initWithFrame:CGRectMake(40, 94-spaceRoom, ViewWidth-90, 50)];
    _idCode = [[ImageViewLabelTextFieldView alloc]initWithFrame:CGRectMake(40, 149-spaceRoom, ViewWidth-90, 50)];
    _phoneView.contentTextField.placeholder=@"手机号码";
    _phoneView.contentTextField.keyboardType=UIKeyboardTypeNumberPad;
    _idCode.contentTextField.placeholder=@"输入图中数字";
    _idCode.contentTextField.keyboardType=UIKeyboardTypeNumberPad;
    
    [self.view addSubview:_phoneView];
    [self.view addSubview:_idCode];
    //按钮
    getCodeBtn = [[UIButton alloc]init];
    [getCodeBtn setTitle:NSLocalizedString(@"获取验证码", @"") forState:UIControlStateNormal];
    [getCodeBtn setBackgroundColor:themeColor];
    [getCodeBtn viewWithRadis:10.0];
    [getCodeBtn addTarget:self action:@selector(gotoFinishRegist) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:getCodeBtn];
    
    [getCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@50);
        make.top.equalTo(_idCode.mas_bottom).with.offset(50);
        make.right.equalTo(@-50);
        make.left.equalTo(@50);
    }];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title=@"注册";
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.tintColor = themeColor;
    randomStr=SuiJiShu;
    
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0,2, 120, 30)];
    loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    loginButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [loginButton setTitle:NSLocalizedString(@"已有帐号登录", @"") forState:UIControlStateNormal];
    [loginButton setTitleColor:themeColor forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginView) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:loginButton]];
    
    codeImageBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [codeImageBtn setFrame:CGRectMake(0, 0, 80, 30)];
    [codeImageBtn addTarget:self action:@selector(changeConfirmNumber) forControlEvents:UIControlEventTouchUpInside];
    //异步获取图形验证码
    seedID=SuiJiShu;
    NSString *strURL = [NSString stringWithFormat:@"%@/v3/common/captcha?seed=%@",Baseurl,seedID];
    YiZhenLog(@"url==%@",strURL);
    NSURLRequest *re=[NSURLRequest requestWithURL:[NSURL URLWithString:strURL]];
    NSOperationQueue *op=[[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:re queue:op completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        dispatch_async(dispatch_get_main_queue(),^{
            UIImage *img=[UIImage imageWithData:data];
            [codeImageBtn setBackgroundImage:img forState:UIControlStateNormal];
        });
    }];
    [codeImageBtn viewWithRadis:10.0];
    _idCode.contentTextField.rightViewMode = UITextFieldViewModeAlways;
    _idCode.contentTextField.rightView = codeImageBtn;

}

-(void)loginView
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)gotoFinishRegist
{
    //1.判断手机正则
    if ([self isValidateMobile:_phoneView.contentTextField.text]) {
       //2.然后判断验证码是否正确
        [self isValidateImageCode];
    }
    else
    {
        [[SetupView ShareInstance]showAlertViewNoButtonMessage:@"手机号格式不正确" Title:@"提示" viewController:self];
    }
}

-(void)changeConfirmNumber{
    seedID=SuiJiShu;
    NSString *strURL = [NSString stringWithFormat:@"%@/v3/common/captcha?seed=%@",Baseurl,seedID];
    NSURLRequest *re=[NSURLRequest requestWithURL:[NSURL URLWithString:strURL]];
    NSOperationQueue *op=[[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:re queue:op completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        dispatch_async(dispatch_get_main_queue(),^{
            UIImage *img=[UIImage imageWithData:data];
            [codeImageBtn setBackgroundImage:img forState:UIControlStateNormal];
        });
    }];
}
#pragma 取消输入操作
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark- 手机正则
/*手机号码验证 MODIFIED BY HELENSONG*/
-(BOOL) isValidateMobile:(NSString *)mobile
{
    //手机号以13,15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(17[0-9])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    //    NSLog(@"phoneTest is %@",phoneTest);
    return [phoneTest evaluateWithObject:mobile];
}

-(void) isValidateImageCode
{
    NSString*url=[NSString stringWithFormat:@"%@/v3/common/validate",Baseurl];
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_phoneView.contentTextField.text,seedID,_idCode.contentTextField.text,randomStr,nil] forKeys:[NSArray arrayWithObjects:@"phone",@"seed",@"captcha",@"random",nil]];
    [[HttpManager ShareInstance] AFNetPOSTNobodySupport:url Parameters:dic SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        YiZhenLog(@"res==%d",res);
        if (res==0) {
            YiZhenLog(@"success");
            isSuccess=YES;
            //将电话号码存入本地
            [[NSUserDefaults standardUserDefaults] setObject:_phoneView.contentTextField.text forKey:phoneNO];
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            accomplishRegistViewController *accomplishVC = [story instantiateViewControllerWithIdentifier:@"accomplishVC"];
            [self.navigationController pushViewController:accomplishVC animated:YES];
        }
        else if(res==801)
        {
            randomStr=SuiJiShu;
            [self changeConfirmNumber];
            [[SetupView ShareInstance] showAlertViewNoButtonMessage:@"验证码输入错误" Title:@"提示" viewController:self];
        }
        else if (res==802)
        {
            randomStr=SuiJiShu;
            [self changeConfirmNumber];
            [[SetupView ShareInstance] showAlertViewNoButtonMessage:@"短信验证码发送失败" Title:@"提示" viewController:self];
        }
        
        else if (res==804)
        {
            randomStr=SuiJiShu;
            [self changeConfirmNumber];
            [[SetupView ShareInstance] showAlertViewNoButtonMessage:@"手机号格式不正确" Title:@"提示" viewController:self];
        }
        else if (res==805)
        {
            randomStr=SuiJiShu;
            [self changeConfirmNumber];
            [[SetupView ShareInstance] showAlertViewNoButtonMessage:@"该手机号已被注册" Title:@"提示" viewController:self];
        }
        
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
        randomStr=SuiJiShu;
    }];
}
@end
