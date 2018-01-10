//
//  RootGuideViewController.m
//  Yizhenapp
//
//  Created by 李胜书 on 15/9/30.
//  Copyright © 2015年 李胜书. All rights reserved.
//

#import "RootGuideViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface RootGuideViewController ()

{
    UIPageControl *myPageControl;
    CGFloat imageY;
    CGFloat themeLabelY;//都是比例
    CGFloat pageCY;
    CGFloat loginY;
    CGFloat imageH;
    UIButton*skipButton;
}

@end

@implementation RootGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

-(void)skipGuide:(UIButton *)sender{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [story instantiateViewControllerWithIdentifier:@"loginview"];
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = [[ControlAllNavigationViewController alloc] initWithRootViewController:loginViewController];
}

-(void)setupView{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    _guideScroller = [[UIScrollView alloc]init];
    _guideScroller.delegate = self;
    _guideScroller.contentSize = CGSizeMake(ViewWidth*4, 5);
    _guideScroller.pagingEnabled = YES;
    _guideScroller.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_guideScroller];
    
    
    UIButton*igronBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [igronBtn setBackgroundColor:lightGrayBackColor];
    [igronBtn setTitle:@"跳过" forState:UIControlStateNormal];
    [igronBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [igronBtn.titleLabel setFont:YiZhenFont12];
    igronBtn.layer.cornerRadius=13;
    igronBtn.layer.masksToBounds=YES;
    [igronBtn setFrame:CGRectMake(ViewWidth-10-50, 30, 50, 26)];
    [igronBtn addTarget:self action:@selector(skipGuide:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:igronBtn];
    
    if (ViewHeight>480) {
        imageY=0.285;
        themeLabelY=0.7;
        pageCY=0.82;
        loginY=0.9;
        imageH=0.299;
        UIImageView*backImageV=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, ViewHeight)];
        [backImageV setImage:[UIImage imageNamed:@"guide_background"]];
        [self.view addSubview:backImageV];
        [self.view sendSubviewToBack:backImageV];
        [self setupDetailView];
    }
    else{
        imageY=0.2;
        themeLabelY=0.67;
        pageCY=0.82;
        loginY=0.875;
        imageH=0.354;
        UIImageView*backImageV=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, ViewHeight)];
        [backImageV setImage:[UIImage imageNamed:@"guide_background2"]];
        [self.view addSubview:backImageV];
        [self.view sendSubviewToBack:backImageV];
        [self setupDetailView];
    }
}

-(void)setupDetailView{
    NSMutableArray *imageArray = [@[NSLocalizedString(@"guide_pages_first", @""),NSLocalizedString(@"guide_pages_second", @""),NSLocalizedString(@"guide_pages_third", @""),NSLocalizedString(@"guide_pages_fourth", @"")] mutableCopy];
    
    NSMutableArray *titleArray = [@[NSLocalizedString(@"直播",@""),NSLocalizedString(@"智能", @""),NSLocalizedString(@"自在", @""),NSLocalizedString(@"贴心", @"")]mutableCopy];
    
    NSMutableArray *remindArray = [@[NSLocalizedString(@"权威专家为您答疑解惑",@""),NSLocalizedString(@"拍化验单识别成电子病历", @""),NSLocalizedString(@"和战友们聊天 做真实的自己", @""),NSLocalizedString(@"服药提醒专治忘吃药", @"")]mutableCopy];
    for (int i = 0; i< 4; i++) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        // 1.设置frame
        imageView.frame = CGRectMake(i * ViewWidth,0 ,ViewWidth , ViewHeight*imageH);
        // 2.设置图片
        NSString *imgName = imageArray[i];
        imageView.image = [UIImage imageNamed:imgName];
        [_guideScroller addSubview:imageView];
        
        UILabel*themeLabel=[[UILabel alloc]initWithFrame:CGRectMake(i*ViewWidth, ViewHeight*(themeLabelY-imageY), ViewWidth, 20)];
        themeLabel.text=titleArray[i];
        themeLabel.textColor=themeColor;
        themeLabel.font = [UIFont boldSystemFontOfSize:17.0];
        themeLabel.textAlignment = NSTextAlignmentCenter;
        [_guideScroller addSubview:themeLabel];
        
        UILabel *remindLabel = [[UILabel alloc]initWithFrame:CGRectMake(i*ViewWidth, themeLabel.y+themeLabel.height+5, ViewWidth, 20)];
        remindLabel.text = remindArray[i];
        remindLabel.font = YiZhenFont14;
        remindLabel.textColor=grayLabelColor;
        remindLabel.textAlignment = NSTextAlignmentCenter;
        [_guideScroller addSubview:remindLabel];
        
    }
    
    [_guideScroller setFrame:CGRectMake(0, ViewHeight*imageY, ViewWidth, ViewHeight*pageCY)];
    myPageControl = [[UIPageControl alloc]init];
    myPageControl.center=CGPointMake(ViewWidth/2,ViewHeight*pageCY);
    myPageControl.bounds=CGRectMake(0, 0, 40, 7);
    myPageControl.numberOfPages = 4;
    myPageControl.currentPage = 0;
    myPageControl.enabled = NO;
    myPageControl.pageIndicatorTintColor = lightGrayBackColor;
    myPageControl.currentPageIndicatorTintColor = grayLabelColor;
    [self.view addSubview:myPageControl];
    skipButton = [[UIButton alloc]init];
    [skipButton setCenter:CGPointMake(ViewWidth/2, ViewHeight*loginY)];
    [skipButton setBounds:CGRectMake(0, 0, 160, 40)];
    [skipButton setTitle:NSLocalizedString(@"注册/登录",@"") forState:UIControlStateNormal];
    [skipButton setTitleColor:themeColor forState:UIControlStateNormal];
    [skipButton viewWithRadis:20.0];
    [skipButton addTarget:self action:@selector(skipGuide:) forControlEvents:UIControlEventTouchUpInside];
    skipButton.layer.borderColor = themeColor.CGColor;
    skipButton.layer.borderWidth =1 ;
    skipButton.hidden=YES;
    [self.view addSubview:skipButton];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int PageNumber = (int)scrollView.contentOffset.x/ViewWidth;
    myPageControl.currentPage = PageNumber;
    
    if (scrollView.contentOffset.x>ViewWidth*3-30) {
        skipButton.hidden=NO;
    }
    if (scrollView.contentOffset.x<2*ViewWidth+10)
    {
        skipButton.hidden=YES;
    }
    if (scrollView.contentOffset.x>ViewWidth*3+20) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginViewController = [story instantiateViewControllerWithIdentifier:@"loginview"];
        [self.navigationController pushViewController:loginViewController animated:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

@end
