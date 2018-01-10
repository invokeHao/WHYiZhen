//
//  SetupView.m
//  ResultContained
//
//  Created by 李胜书 on 15/8/14.
//  Copyright (c) 2015年 李胜书. All rights reserved.
//

#import "SetupView.h"
#import "sys/sysctl.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "DataTool.h"



@implementation SetupView
{
    CGFloat angel;
    BOOL isRun;
    UIImageView*imageV;
}

+(SetupView *) ShareInstance{
    static SetupView *sharedSetupViewInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedSetupViewInstance = [[self alloc] init];
    });
    return sharedSetupViewInstance;
}

-(void)setupSearchbar:(UISearchController *)searchViewController{
    searchViewController.searchBar.backgroundColor = [UIColor whiteColor];
    searchViewController.searchBar.backgroundImage = [UIImage imageNamed:@"white"];
//    searchViewController.searchBar.layer.borderWidth = 0.5;
//    searchViewController.searchBar.layer.borderColor = lightGrayBackColor.CGColor;
    [searchViewController.searchBar makeInsetShadowWithRadius:0.5 Color:lightGrayBackColor Directions:[NSArray arrayWithObjects:@"bottom", nil]];
    for (UIView *sb in [[searchViewController.searchBar subviews][0] subviews]) {
        if ([sb isKindOfClass:[UITextField class]]) {
            sb.layer.borderColor = themeColor.CGColor;
            sb.layer.borderWidth = 0.5;
            [sb viewWithRadis:10.0];
        }
    }
}

-(void)setupNavigationRightButton:(UIViewController *)viewController RightButton:(UIButton *)rightButton{
    [viewController.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:rightButton]];
}

-(void)setupNavigationLeftButton:(UIViewController *)viewController LeftButton:(UIButton *)leftButton{
    [viewController.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:leftButton]];
}

-(void)setupNavigationView:(UINavigationController *)navigation Image:(UIImage *)image{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    navigation.navigationBarHidden = NO;
#warning 去掉navigationbar下划线
    UINavigationBar *navigationBar = navigation.navigationBar;
    [navigationBar setBackgroundImage:image
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:[UIImage new]];
    
    navigation.navigationBar.barStyle = UIBaselineAdjustmentNone;
    
    [navigation.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:themeColor,NSForegroundColorAttributeName,nil]];
    navigation.navigationBar.tintColor = themeColor;
    [navigation.navigationBar setBackgroundImage:image forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
}

-(void)showAlertView:(NSString *)message Title:(NSString *)title ViewController:(UIViewController *)controller{
    __weak id weakVC=controller;
    UIAlertView *showAlert = [[UIAlertView alloc]initWithTitle:title message:message delegate:weakVC cancelButtonTitle:NSLocalizedString(@"确定", @"") otherButtonTitles:NSLocalizedString(@"取消", @""), nil];
    [showAlert show];
}

-(void)showAlertViewOneButton:(NSString *)message Title:(NSString *)title ViewController:(UIViewController *)controller{
    __weak id weakVC=controller;
    UIAlertView *showAlert = [[UIAlertView alloc]initWithTitle:title message:message delegate:weakVC cancelButtonTitle:NSLocalizedString(@"确定", @"") otherButtonTitles:nil, nil];
    [showAlert show];
}

-(void)showAlertViewNoButtonMessage:(NSString*)message Title:(NSString *)title viewController:(UIViewController *)controller
{
    __weak id weakVC=controller;
    UIAlertView *showAlert=[[UIAlertView alloc]initWithTitle:title message:message delegate:weakVC cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [showAlert show];
    [self performSelector:@selector(hideAltert:) withObject:showAlert afterDelay:1.7];
}

-(void)hideAltert:(UIAlertView*)alter
{
    [alter dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)showHUdAlertView:(NSString *)message Title:(NSString *)title ViewController:(UIViewController *)controller{
    __weak id weakVC=controller;
    UIAlertView *showAlert = [[UIAlertView alloc]initWithTitle:title message:message delegate:weakVC cancelButtonTitle:NSLocalizedString(@"确定", @"") otherButtonTitles:nil, nil];
    [showAlert show];
}

-(void)showAlertView:(NSString *)message Title:(NSString *)title Objec:(id )objec{
    UIAlertView *showAlert = [[UIAlertView alloc]initWithTitle:title message:message delegate:objec cancelButtonTitle:NSLocalizedString(@"确定", @"") otherButtonTitles:nil, nil];
    [showAlert show];
}

-(void)showAlertTitileView:(NSString*)title AtView:(UIView*)view
{
    UILabel*label=[[UILabel alloc]init];
    
    UIView*backView=[[UIView alloc]init];
    backView.center=view.center;
    backView.bounds=CGRectMake(0, 0, 200, 40);
    backView.backgroundColor=grayBackgroundDarkColor;
    [view addSubview:backView];
    
    label.center=view.center;
    label.text=title;
    label.bounds=CGRectMake(0, 0, 200, 22);
    label.font=YiZhenFont;
    label.textColor=[UIColor whiteColor];
    label.textAlignment=NSTextAlignmentCenter;
    [backView addSubview:label];
    
    [NSThread sleepForTimeInterval:2];
    backView.hidden=YES;
}

-(NSString *)getNetWorkStates{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"]valueForKeyPath:@"foregroundView"]subviews];
    NSString *state = [[NSString alloc]init];
    int netType = 0;
    //获取到网络返回码
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取到状态栏
            netType = [[child valueForKeyPath:@"dataNetworkType"]intValue];
            
            switch (netType) {
                case 0:
                    state = @"无网络";
                    //无网模式
                    break;
                case 1:
                    state = @"2G";
                    break;
                case 2:
                    state = @"3G";
                    break;
                case 3:
                    state = @"4G";
                    break;
                case 5:
                {
                    state = @"WIFI";
                }
                    break;
                default:
                    break;
            }
        }
    }
    //根据状态选择
    return state;
}


-(void)showAlertView:(int)res Hud:(MBProgressHUD *)HUD ViewController:(UIViewController *)controller{
    [_HUD hide:YES];
    if (res == 1){
        [self showHUdAlertView:NSLocalizedString(@"", @"") Title:NSLocalizedString(@"输入数据出错", @"") ViewController:controller];
        [HUD hide:YES];
    }else if (res == 6){
        [self showAlertViewNoButtonMessage:@"用户名太抢手了，换一个吧" Title:@"提示" viewController:controller];
    }else if (res == 23){
        [self showAlertViewNoButtonMessage:@"用户编号和预留手机号不匹配" Title:@"提示" viewController:controller];
    }else if (res == 24){
        [self showAlertViewNoButtonMessage:@"二维码不属于易诊？" Title:@"提示" viewController:controller];
    }else if (res == 25){
        [self showAlertViewNoButtonMessage:@"二维码已用" Title:@"提示" viewController:controller];
    }
    else if (res == 49){
        [self showAlertViewNoButtonMessage:@"用户登录过期" Title:@"提示" viewController:controller];
    }
    else if (res ==102||res==101){
        [self logout];
    }
    else if (res ==103){
        [self showAlertViewNoButtonMessage:@"操作频繁" Title:@"提示" viewController:controller];
    }
    else if (res ==104){
        [self showAlertViewNoButtonMessage:@"用户已被锁定" Title:@"提示" viewController:controller];
    }
    else if (res ==802){
        [self showAlertViewNoButtonMessage:@"短信验证码发送失败" Title:@"提示" viewController:controller];
    }
    else if (res ==803){
        [self showAlertViewNoButtonMessage:@"短信验证码不正确" Title:@"提示" viewController:controller];
    }
    else if (res ==804){
        [self showAlertViewNoButtonMessage:@"手机号格式不正确" Title:@"提示" viewController:controller];
    }
    else if (res ==805){
        [self showAlertViewNoButtonMessage:@"手机号已注册" Title:@"提示" viewController:controller];
    }
    else if (res ==80220){
        [self showAlertViewNoButtonMessage:@"短信余额不足" Title:@"提示" viewController:controller];
    }
    else if (res ==806){
        [self showAlertViewNoButtonMessage:@"登录名或密码错误" Title:@"提示" viewController:controller];
    }
    else if (res ==808){
        [self showAlertViewNoButtonMessage:@"用户不存在" Title:@"提示" viewController:controller];
    }
    else if (res == 901){
        [self showAlertViewNoButtonMessage:@"直播不存在" Title:@"提示" viewController:controller];
    }
    else if (res == 904){
        [self showAlertViewNoButtonMessage:@"您还没有进入直播" Title:@"提示" viewController:controller];
    }
    else if (res == 905){
        [self showAlertViewNoButtonMessage:@"您已被禁言" Title:@"提示" viewController:controller];
    }
    else if (res == 906){
        [self showAlertViewNoButtonMessage:@"用户已进入直播" Title:@"提示" viewController:controller];
    }
}

-(void)showHUD:(UIViewController *)viewController Title:(NSString *)title{
    _HUD = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    
    //常用的设置
    //小矩形的背景色
    _HUD.color = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6f];//背景色
    //显示的文字
    _HUD.labelText = title;
    //是否有庶罩
    _HUD.dimBackground = NO;
}

-(void)showTextHUD:(UIViewController*)viewController Title:(NSString*)title
{
    _HUD=[MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    _HUD.color=[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6f];
    _HUD.labelFont=[UIFont systemFontOfSize:16.0];
    _HUD.labelText=title;
    _HUD.mode=MBProgressHUDModeText;
    _HUD.dimBackground=NO;
    _HUD.removeFromSuperViewOnHide=YES;
    [_HUD hide:YES afterDelay:1.6];
}

-(void)showImageHUD:(UIViewController*)viewcontroller
{
    _HUD = [MBProgressHUD showHUDAddedTo:viewcontroller.view animated:NO];
    _HUD.color=[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6f];
    _HUD.mode=MBProgressHUDModeCustomView;
    imageV=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"rotation"]];
    _HUD.customView=imageV;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CABasicAnimation *rotationAnim = [CABasicAnimation animation];
        rotationAnim.keyPath = @"transform.rotation.z";
        rotationAnim.toValue = @(2 * M_PI);
        rotationAnim.repeatCount = MAXFLOAT;
        rotationAnim.duration = 2;
        rotationAnim.cumulative = NO;//无限循环
        [imageV.layer addAnimation:rotationAnim forKey:nil];
    });

    
//    CABasicAnimation* rotationAnimation;
//    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
//    rotationAnimation.duration = 1;
//    rotationAnimation.cumulative = YES;
//    rotationAnimation.repeatCount = 60;
//    [imageV.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)hideHUD{
    [_HUD hide:YES];
    isRun=NO;
}

- (NSString*) doDevicePlatform{
    size_t size=10;
//    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
//    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) {
        
        platform = @"iPhone";
        
    } else if ([platform isEqualToString:@"iPhone1,2"]) {
        
        platform = @"iPhone 3G";
        
    } else if ([platform isEqualToString:@"iPhone2,1"]) {
        
        platform = @"iPhone 3GS";
        
    } else if ([platform isEqualToString:@"iPhone3,1"]||[platform isEqualToString:@"iPhone3,2"]||[platform isEqualToString:@"iPhone3,3"]) {
        
        platform = @"iPhone 4";
        
    } else if ([platform isEqualToString:@"iPhone4,1"]) {
        
        platform = @"iPhone 4S";
        
    } else if ([platform isEqualToString:@"iPhone5,1"]||[platform isEqualToString:@"iPhone5,2"]) {
        
        platform = @"iPhone 5";
        
    }else if ([platform isEqualToString:@"iPhone5,3"]||[platform isEqualToString:@"iPhone5,4"]) {
        
        platform = @"iPhone 5C";
        
    }else if ([platform isEqualToString:@"iPhone6,2"]||[platform isEqualToString:@"iPhone6,1"]) {
        
        platform = @"iPhone 5S";
        
    }else if ([platform isEqualToString:@"iPod4,1"]) {
        
        platform = @"iPod touch 4";
        
    }else if ([platform isEqualToString:@"iPod5,1"]) {
        
        platform = @"iPod touch 5";
        
    }else if ([platform isEqualToString:@"iPod3,1"]) {
        
        platform = @"iPod touch 3";
        
    }else if ([platform isEqualToString:@"iPod2,1"]) {
        
        platform = @"iPod touch 2";
        
    }else if ([platform isEqualToString:@"iPod1,1"]) {
        
        platform = @"iPod touch";
        
    } else if ([platform isEqualToString:@"iPad3,2"]||[platform isEqualToString:@"iPad3,1"]) {
        
        platform = @"iPad 3";
        
    } else if ([platform isEqualToString:@"iPad2,2"]||[platform isEqualToString:@"iPad2,1"]||[platform isEqualToString:@"iPad2,3"]||[platform isEqualToString:@"iPad2,4"]) {
        
        platform = @"iPad 2";
        
    }else if ([platform isEqualToString:@"iPad1,1"]) {
        
        platform = @"iPad 1";
        
    }else if ([platform isEqualToString:@"iPad2,5"]||[platform isEqualToString:@"iPad2,6"]||[platform isEqualToString:@"iPad2,7"]) {
        
        platform = @"ipad mini";
        
    } else if ([platform isEqualToString:@"iPad3,3"]||[platform isEqualToString:@"iPad3,4"]||[platform isEqualToString:@"iPad3,5"]||[platform isEqualToString:@"iPad3,6"]) {
        
        platform = @"ipad 3";
        
    }
    
    return platform;
}

#pragma mark-登出app
-(void)logout
{
    UIAlertView *remindAlertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"温馨提示", @"") message:NSLocalizedString(@"登录过期，请重新登录", @"") delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    if(!_DontshowAlter)
    {
        [remindAlertView show];
    }
    _DontshowAlter=NO;
    [self performSelector:@selector(gotoLogin) withObject:nil afterDelay:1.7];
    [self hideHUD];
    
    //清理沙盒
    [self cleanSandBox];
}

-(void)cleanSandBox
{
    [GeTuiSdk resetBadge];
    [MemoSDK destroy];
    [[DataTool shareInstance] setTableStatu:DataToolTableNameStatuliveList];
    [[DataTool shareInstance] removeTable];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KmemoboxAmount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KinformationAmount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KchatAmount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KtopicAmount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KOcrFailedAmount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KOcrSuccessAmount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KliveNtfIntroAmount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KliveNtfMetionAmount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kNewCouponNtfAmount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCouponWillBadNtfAmount];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KLivePushId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLiveId];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:userAvatar];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:userNickname];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:isLoaded];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:hadMedicineAlert];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:DonotUseCoupon];

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userUID"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userPassword"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userToken"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userNickName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userAge"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userGender"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userTele"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userSystemVersion"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userNote"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userWeChat"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userPhone"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userOpenVoice"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userOpenShake"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userRemindCamera"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"medinceHis"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"noFirstToAdd"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NotFirstTime"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ShowGuide"];
}


-(void)gotoLogin
{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [story instantiateViewControllerWithIdentifier:@"loginview"];
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.window.rootViewController = [[ControlAllNavigationViewController alloc] initWithRootViewController:loginViewController];
    
}
@end
