//
//  liveDiscussViewController.m
//  Yizhenapp
//
//  Created by augbase on 16/9/5.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "liveDiscussViewController.h"
#import "liveDiscussTableViewCell.h"
#import "liveDiscussModel.h"
#import "userListViewController.h"

#import "questionModel.h"
#import "myInfoModel.h"
#import "iconButton.h"
#import "DataTool.h"
#import "wangToast.h"

@interface liveDiscussViewController ()<UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate,UITextViewDelegate,UIActionSheetDelegate,UIPickerViewDelegate>
{
    UIView * commentView;//回复view
    UIView * shadowView;//阴影view
    UIView * bgView;//背景view
    UIView * helpView;//求助介绍view
    UIView * infoView;//用户完善信息view

    UIButton*helpbutton;//求助按钮
    UIButton*postBtn;//发送按钮
    iconButton*iconBtn;//头像
    
    UILabel * bottomLabel;//需要承载文字
    UILabel * pleaseHoldLabel;//输入框的等待文字
    
    UITextField * nameField;//昵称text
    
    BOOL isHelp;
    BOOL postSuccess;
    BOOL toHelp;
    BOOL FirstJoin;
    
    NSString * randomStr;
    NSString *pleaseLabel;
    
    myInfoModel * infoModel;
    UIImage * iconImage;
    DataTool * dataT;
}
@property (strong,nonatomic)UITableView * MainTable;
@property (strong,nonatomic)NSMutableArray * dataArray;
@property (strong, nonatomic)MJRefreshHeaderView *header;
@property (strong, nonatomic)MJRefreshFooterView *footer;
@property (assign ,nonatomic)int currentpage;
@property (strong,nonatomic)UITextView* commentTextView;//评论框
@property (strong,nonatomic)questionModel * questionM;

@end

@implementation liveDiscussViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dataT=[DataTool shareInstance];
    [dataT setTableStatu:DataToolTableNameStatuliveList];

    pleaseLabel=@"提问";
    
    if (_hasClosed) {
        pleaseLabel=@"直播已结束，继续参与讨论";
    }
    [self creatUI];
    [self regNotification];
    [self setUpData];
    [self setUpForHelp];
    FirstJoin=YES;
    _currentpage=1;
    _dataArray=[[NSMutableArray alloc]initWithCapacity:0];
    randomStr=SuiJiShu;
    
    NSUserDefaults * user=[NSUserDefaults standardUserDefaults];
    
    NSInteger amount=[[user objectForKey:KliveNtfMetionAmount] integerValue];
    [UIApplication sharedApplication].applicationIconBadgeNumber-=amount;
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:KliveNtfMetionAmount];
    //同步角标到个推服务器
    [GeTuiSdk setBadge:[UIApplication sharedApplication].applicationIconBadgeNumber];
}

-(void)creatUI
{
    self.view.backgroundColor=[UIColor whiteColor];
    [self creatTableView];
    [self createBottomView];
}
-(void)creatTableView
{
    _MainTable=[[UITableView alloc]init];
    __weak id weakSelf=self;
    _MainTable.delegate=weakSelf;
    _MainTable.dataSource=weakSelf;
    _MainTable.layer.borderColor=lightGrayBackColor.CGColor;
    _MainTable.layer.borderWidth=0.5;
    _MainTable.showsVerticalScrollIndicator=NO;
    _MainTable.separatorStyle=UITableViewCellSeparatorStyleNone;
    _MainTable.backgroundColor=[UIColor whiteColor];
    _MainTable.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    _MainTable.separatorColor=lightGrayBackColor;
    _MainTable.separatorInset = UIEdgeInsetsMake(0, 53, 0, 15);
    [self.view addSubview:_MainTable];
    [_MainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(@0);
        make.bottom.equalTo(@-45);
    }];

    UIView*footView=[[UIView alloc]initWithFrame:CGRectZero];
    footView.backgroundColor=grayBackgroundLightColor;
    _MainTable.tableFooterView = footView;
}

-(void)createBottomView
{
    UIView*backView=[[UIView alloc]initWithFrame:CGRectMake(0, ViewHeight-64-45, ViewWidth, 45)];
    backView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:backView];
    
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(15, 6, ViewWidth-30, 32)];
    view.backgroundColor=[UIColor whiteColor];
    view.layer.cornerRadius=8;
    view.layer.borderColor=darkTitleColor.CGColor;
    view.layer.borderWidth=0.5;
    view.layer.masksToBounds=YES;
    [backView addSubview:view];
    
    bottomLabel=[[UILabel alloc]initWithFrame:CGRectMake(5,0, ViewWidth-30, 32)];
    bottomLabel.font=[UIFont systemFontOfSize:15.0];
    bottomLabel.textColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    bottomLabel.text=pleaseLabel;
    [view addSubview:bottomLabel];
    
    UIButton*button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor=[UIColor clearColor];
    [button setFrame:view.frame];
    [button addTarget:self action:@selector(pressToWriteTheDiscuss) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:button];
}

-(void)createTapView
{
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    
    [self.navigationController.view addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    
    [self.navigationController.view addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    
    [self.navigationController.view addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    
    [self.navigationController.view addGestureRecognizer:recognizer];
    
}


-(void)pressToWriteTheDiscuss
{
    [self judgementTheUserInfo];
}

#pragma mark-判断用户信息是否完整
-(void)judgementTheUserInfo
{
    BOOL isloaded=[[[NSUserDefaults standardUserDefaults] objectForKey:isLoaded] boolValue];
    if (isloaded) {
        [self judgementToWrite];
    }
    else
    {
        //进行请求
        NSString*yuid=[[NSUserDefaults standardUserDefaults] objectForKey:@"userUID"];
        NSString*ytoken=[[NSUserDefaults standardUserDefaults] objectForKey:@"userToken"];
        NSString*url=[NSString stringWithFormat:@"%@/v3/task/isCPITaskCompleted?uid=%@&token=%@",Baseurl,yuid,ytoken];
        YiZhenLog(@"infoUrl==%@",url);
        [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            int res=[[source objectForKey:@"res"] intValue];
            if (res == 0) {
                if ([[source objectForKey:@"data"] boolValue]) {
                    //可以发帖
                    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:isLoaded];
                    [self judgementToWrite];
                }
                //如果用户没有登录，则出现完善信息view
                else
                {
                    [self getTheImageAndNickName];
                }
            }
        } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            YiZhenLog(@"%@",error);
            [[SetupView ShareInstance]hideHUD];
        }];
    }

}

-(void)judgementToWrite
{
    if (FirstJoin) {
        NSString * liveIdStr=[NSString stringWithFormat:@"%ld",_liveId];
 
        NSMutableArray * arr=[dataT selectAllLive];
        for (NSString * item in arr) {
            if ([item isEqualToString:liveIdStr]) {
                FirstJoin=NO;
            }
        }
        if (FirstJoin) {
            [self createHelpIntroView];
            [dataT insertALive:liveIdStr];
        }
        else{
            [self createCommentView];
            if (![bottomLabel.text isEqualToString:pleaseLabel]){
                _commentTextView.text=bottomLabel.text;
                pleaseHoldLabel.text=@"";
            }
        }
    }
    //不是第一次
    else{
        [self createCommentView];
        if (![bottomLabel.text isEqualToString:pleaseLabel])
        {
            _commentTextView.text=bottomLabel.text;
            pleaseHoldLabel.text=@"";
        }
    }
}

-(void)getTheImageAndNickName{
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@/v3/personal/mine/info?uid=%@&token=%@",Baseurl,[user objectForKey:@"userUID"],[user objectForKey:@"userToken"]];
    YiZhenLog(@"我的详情====%@",url);
    
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res == 0) {
            infoModel=[[myInfoModel alloc]initWithDictionary:[source objectForKey:@"data"]];
            [user setObject:infoModel.avatar forKey:userAvatar];
            [user setObject:infoModel.nickname forKey:userNickname];
            [self creatInfoView];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
}

#pragma mark-创建完善信息view
-(void)creatInfoView
{
    if (infoView.subviews.count>2) {
        [self closeTheInfoView];
    }
    UIView*backView=[[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    backView.backgroundColor=[UIColor colorWithWhite:0 alpha:0.3];
    backView.tag=888;
    [self.navigationController.view addSubview:backView];
    //具体数字均来自设计稿
    infoView=[[UIView alloc]init];
    [infoView setCenter:CGPointMake(ViewWidth/2, ViewHeight/2)];
    [infoView setBounds:CGRectMake(0, 0, 245, 300)];
    infoView.layer.cornerRadius=12;
    infoView.layer.masksToBounds=YES;
    infoView.backgroundColor=[UIColor whiteColor];
    [backView addSubview:infoView];
    UILabel*guideTitle=[[UILabel alloc]init];
    guideTitle.text=@"上传头像并设置一个昵称 才能提问";
    guideTitle.numberOfLines=2;
    guideTitle.font=YiZhenFont12;
    guideTitle.textColor=grayLabelColor;
    guideTitle.textAlignment=NSTextAlignmentCenter;
    [infoView addSubview:guideTitle];
    
    //取消按钮
    UIButton*cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:YiZhenFont];
    [cancelButton setTitleColor:grayLabelColor forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(closeTheInfoView) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:cancelButton];
    //加两根线
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, infoView.width, 0.5)];
    lineView.backgroundColor=lightGrayBackColor;
    [cancelButton addSubview:lineView];
    
    lineView=[[UIView alloc]initWithFrame:CGRectMake(infoView.width/2, 0, 0.5, 49)];
    lineView.backgroundColor=lightGrayBackColor;
    [cancelButton addSubview:lineView];
    
    //确定按钮
    UIButton*sureButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [sureButton setTitleColor:themeColor forState:UIControlStateNormal];
    [sureButton.titleLabel setFont:YiZhenFont];
    [sureButton setTitle:@"保存" forState:UIControlStateNormal];
    [sureButton addTarget:self action:@selector(toSaveTheInfo) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:sureButton];
    
    
    iconBtn=[[iconButton alloc]init];
    [iconBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:infoModel.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"upload_avatar"]];
    iconBtn.layer.cornerRadius=45;
    iconBtn.layer.masksToBounds=YES;
    [iconBtn addTarget:self action:@selector(pickTheIconImage) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:iconBtn];
    
    nameField=[[UITextField alloc]init];
    NSString*nickName=infoModel.nickname;
    if (nickName.length>0) {
        nameField.text=nickName;
    }
    else
    {
        nameField.placeholder=@"编辑昵称";
    }
    nameField.font=YiZhenFont;
    
    UIButton*editBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [editBtn setImage:[UIImage imageNamed:@"editor_files"] forState:UIControlStateNormal];
    [editBtn setBounds:CGRectMake(0, 0, 12, 12)];
    [nameField setRightView:editBtn];
    [nameField setRightViewMode:UITextFieldViewModeUnlessEditing];
    [infoView addSubview:nameField];
    //开始布局
    [guideTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@25);
        make.centerX.mas_equalTo(infoView);
        make.size.mas_equalTo(CGSizeMake(143, 38));
    }];
    [iconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(guideTitle.mas_bottom).with.offset(25);
        make.centerX.mas_equalTo(infoView);
        make.size.mas_equalTo(CGSizeMake(90, 90));
    }];
    [nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(cancelButton.mas_top).with.offset(-25);
        make.centerX.mas_equalTo(infoView);
        make.size.mas_equalTo(CGSizeMake(76, 25));
    }];
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.equalTo(@0);
        make.size.mas_equalTo(CGSizeMake(infoView.width/2, 49));
    }];
    [sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(@0);
        make.size.mas_equalTo(CGSizeMake(infoView.width/2, 49));
    }];
    
    [self createTapView];
}

-(void)createCommentView
{
    //创建阴影view
    shadowView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, ViewHeight)];
    shadowView.backgroundColor=[UIColor colorWithWhite:0.3 alpha:0.3];
    [self.navigationController.view addSubview:shadowView];
    
    //创建回复的view
    commentView=[[UIView alloc]initWithFrame:CGRectMake(0, ViewHeight-115, ViewWidth, 115)];
    commentView.backgroundColor=[UIColor whiteColor];
    [shadowView addSubview:commentView];
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 1)];
    lineView.backgroundColor=darkTitleColor;
    [commentView addSubview:lineView];
    
    _commentTextView=[[UITextView alloc]initWithFrame:CGRectMake(15, 9, ViewWidth-30, 56)];
    _commentTextView.layer.cornerRadius=8;
    _commentTextView.layer.borderColor=darkTitleColor.CGColor;
    _commentTextView.layer.borderWidth=0.5;
    _commentTextView.layer.masksToBounds=YES;
    _commentTextView.font=YiZhenFont14;
    __weak id weakSelf=self;
    _commentTextView.delegate=weakSelf;
    [commentView addSubview:_commentTextView];
    
    pleaseHoldLabel=[[UILabel alloc]initWithFrame:CGRectMake(4, 6.5, 210, 20)];
    pleaseHoldLabel.textColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    pleaseHoldLabel.font=YiZhenFont14;
    pleaseHoldLabel.text=pleaseLabel;
    [_commentTextView addSubview:pleaseHoldLabel];
    
    helpbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    [helpbutton setBackgroundColor:[UIColor clearColor]];
    [helpbutton setFrame:CGRectMake(15, 78, 22+4+45, 24)];
    [commentView addSubview:helpbutton];
    //求助的icon
    UIButton*helpIcon=[UIButton buttonWithType:UIButtonTypeCustom];
    [helpIcon setImage:[UIImage imageNamed:@"help_off"] forState:UIControlStateNormal];
    [helpIcon setFrame:CGRectMake(0, 0.5, 22, 22)];
    [helpIcon setImage:[UIImage imageNamed:@"help"] forState:UIControlStateSelected];
    [helpIcon addTarget:self action:@selector(pressToHelp:) forControlEvents:UIControlEventTouchUpInside];
    helpIcon.tag=200;
    [helpbutton addSubview:helpIcon];
    //求助的字样
    UIButton*titleBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [titleBtn setTitle:@"求助" forState:UIControlStateNormal];
    [titleBtn setFrame:CGRectMake(22+4,0, 45, 24)];
    [titleBtn.titleLabel setFont:YiZhenFont13];
    [titleBtn addTarget:self action:@selector(pressToHelp:) forControlEvents:UIControlEventTouchUpInside];
    [titleBtn setTitleColor:darkTitleColor forState:UIControlStateNormal];
    titleBtn.layer.borderWidth=0.5;
    titleBtn.layer.borderColor=darkTitleColor.CGColor;
    titleBtn.layer.cornerRadius=12;
    titleBtn.tag=201;
    [helpbutton addSubview:titleBtn];
    
    UIButton * helpInfoBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [helpInfoBtn setFrame:CGRectMake(helpbutton.x+helpbutton.width+10, helpbutton.y+1, 22, 22)];
    [helpInfoBtn setImage:[UIImage imageNamed:@"detail_live"] forState:UIControlStateNormal];
    [helpInfoBtn addTarget:self action:@selector(createHelpIntroView) forControlEvents:UIControlEventTouchUpInside];
    [commentView addSubview:helpInfoBtn];
    
    postBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [postBtn setTitle:@"发送" forState:UIControlStateNormal];
    [postBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [postBtn.titleLabel setFont:YiZhenFont];
    [postBtn setBackgroundColor:themeColor];
    [postBtn setFrame:CGRectMake(ViewWidth-15-64, 74, 64, 32)];
    postBtn.layer.cornerRadius=8;
    postBtn.layer.masksToBounds=YES;
    [postBtn addTarget:self action:@selector(postTheDiscuss) forControlEvents:UIControlEventTouchUpInside];
    [commentView addSubview:postBtn];
    [commentView bringSubviewToFront:helpbutton];
    
    [_commentTextView becomeFirstResponder];
}
-(void)creatNoDiscussView
{
    bgView=[[UIView alloc]initWithFrame:self.MainTable.frame];
    bgView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:bgView];
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 0.5)];
    lineView.backgroundColor=lightGrayBackColor;
    
    YiZhenLog(@"%lf",lineView.frame.origin.y);
    [bgView addSubview:lineView];
    
    UIImageView*image=[[UIImageView alloc]init];
    image.center=CGPointMake(ViewWidth/2, ViewHeight/2-64);
    image.bounds=CGRectMake(0, 0, 120, 120);
    image.image=[UIImage imageNamed:@"no_help"];
    image.contentMode=UIViewContentModeScaleAspectFit;
    [bgView addSubview:image];
    
    UILabel * zhanWeiLabel=[[UILabel alloc]init];
    zhanWeiLabel.font=[UIFont systemFontOfSize:14.0];
    zhanWeiLabel.textColor=grayLabelColor;
    zhanWeiLabel.text=@"暂无讨论";
    zhanWeiLabel.textAlignment=NSTextAlignmentCenter;
    [bgView addSubview:zhanWeiLabel];
    
    [zhanWeiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bgView);
        make.height.equalTo(@20);
        make.top.mas_equalTo(image.mas_bottom).with.offset(10);
    }];
}

-(void)createHelpIntroView
{
    [_commentTextView resignFirstResponder];
    //创建阴影view
    shadowView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, ViewHeight)];
    shadowView.backgroundColor=[UIColor colorWithWhite:0.3 alpha:0.3];
    [self.navigationController.view addSubview:shadowView];

    helpView=[[UIView alloc]init];
    helpView.center=CGPointMake(ViewWidth/2, ViewHeight/2);
    helpView.backgroundColor=[UIColor whiteColor];
    helpView.bounds=CGRectMake(0, 0, ViewWidth-40, 120);
    helpView.layer.cornerRadius=10;
    helpView.layer.masksToBounds=YES;
    [shadowView addSubview:helpView];
    
    UILabel * alterLabel=[[UILabel alloc]init];
    alterLabel.font=[UIFont systemFontOfSize:17.0];
    alterLabel.textColor=[UIColor blackColor];
    alterLabel.text=@"提醒";
    [helpView addSubview:alterLabel];
    
    UIButton * closeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"closed_web"] forState:UIControlStateNormal];
    [closeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 11, 22, 0)];

    [closeBtn addTarget:self action:@selector(closeTheHelpIntroView) forControlEvents:UIControlEventTouchUpInside];
    [helpView addSubview:closeBtn];
    
    UILabel * contentLabel=[[UILabel alloc]init];
    contentLabel.font=YiZhenFont13;
    contentLabel.textColor=grayLabelColor;
    contentLabel.textAlignment=NSTextAlignmentCenter;
    contentLabel.numberOfLines=0;
    contentLabel.text=[NSString stringWithFormat:@"请在同一段中描述病情和问题，\n标记求助可以引起医生注意，\n本场每人只有%ld次标记机会。",_questionM.myTotal];
    [helpView addSubview:contentLabel];
    
    //布局
    [alterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@15);
        make.centerX.mas_equalTo(helpView);
        make.height.equalTo(@17);
    }];
    
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@10);
        make.right.equalTo(@-10);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.right.equalTo(@-10);
        make.top.mas_equalTo(alterLabel.mas_bottom).with.offset(10);
    }];
}

-(void)setUpNavigationItem
{
    UIButton*backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:@"返回直播间" forState:UIControlStateNormal];
    [backBtn setTitleColor:themeColor forState:UIControlStateNormal];
    [backBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [backBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -18, 0, 0)];
    [backBtn setFrame:CGRectMake(0, 0, 90, 22)];
    [backBtn addTarget:self action:@selector(pressToBackTheLive) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*back=[[UIBarButtonItem alloc]initWithCustomView:backBtn];
    [self.navigationItem setLeftBarButtonItem:back];
    
    UIButton*mineBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [mineBtn setFrame:CGRectMake(0, 0, 60, 44)];
    [mineBtn setImage:[UIImage imageNamed:@"archive"] forState:UIControlStateNormal];
    mineBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [mineBtn addTarget:self action:@selector(pressToSeeMyInfo) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*mine=[[UIBarButtonItem alloc]initWithCustomView:mineBtn];
    [self.navigationItem setRightBarButtonItem:mine];
}

-(void)closeTheHelpIntroView
{
    [shadowView removeFromSuperview];
    [self createCommentView];
    if (![bottomLabel.text isEqualToString:pleaseLabel]){
        _commentTextView.text=bottomLabel.text;
        pleaseHoldLabel.text=@"";
        
    }
}

-(void)tapToHidenTheShadow
{
    if (shadowView) {
        [shadowView removeFromSuperview];
        [_commentTextView resignFirstResponder];
        bottomLabel.text=pleaseLabel;
        if (_commentTextView.text.length>0) {
            bottomLabel.text=[NSString stringWithFormat:@" %@",_commentTextView.text];
        }
        isHelp=NO;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title=@"提问";
    [self setUpNavigationItem];
    
    _header = [[MJRefreshHeaderView alloc]initWithScrollView:_MainTable];
    _footer = [[MJRefreshFooterView alloc]initWithScrollView:_MainTable];
    
    __weak id weakSelf=self;
    _header.delegate = weakSelf;
    _footer.delegate = weakSelf;
}

#pragma mark-navigationbar上的点击事件
-(void)pressToBackTheLive
{
    _backB(YES);
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)pressToSeeMyInfo
{
    userListViewController * userListVC=[[userListViewController alloc]init];
    userListVC.liveId=_liveId;
    [self.navigationController pushViewController:userListVC animated:YES];
}

#pragma mark-tabelView的代理方法
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_dataArray.count==0) {
        return 190;
    }
    else {
        liveDiscussModel*model=_dataArray[indexPath.row];
        return model.cellHeight;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    liveDiscussTableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"discussCell"];
    if (cell==nil) {
        cell=[[liveDiscussTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"answerCell"];
    }
    if (_dataArray.count==0) {
    }
    else
    {
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        liveDiscussModel*model=_dataArray[indexPath.row];
        [cell setDiscussModel:model];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableViewScrollToTop{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_MainTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)setUpData
{
    __weak typeof(self) weakSelf=self;
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@v3/live/%@/discuss?uid=%@&token=%@&page=%@",Baseurl,[NSString stringWithFormat:@"%ld",_liveId],[user objectForKey:@"userUID"],[user objectForKey:@"userToken"],[NSString stringWithFormat:@"%d",_currentpage]];
    YiZhenLog(@"讨论列表====%@",url);
    
    //获取病例界面的各种信息
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        
        NSMutableArray*arr;
        arr=[source objectForKey:@"data"];
        if (res == 0) {
            for (NSDictionary*dic in arr) {
                liveDiscussModel*model=[[liveDiscussModel alloc]initWithDictionary:dic];
                [_dataArray addObject:model];
            }
            if (_dataArray.count<1) {
                [weakSelf creatNoDiscussView];
                return ;
            }
            if (_dataArray.count>0&&bgView) {
                [bgView removeFromSuperview];
            }
            [_header endRefreshing];
            [_footer endRefreshing];
            [_MainTable reloadData];
            if (postSuccess) {
                [weakSelf tableViewScrollToTop];
                postSuccess=NO;
            }
        }
        else
        {
            if(res==102)
            {
                if (_header||_footer) {
                    [_header removeFromSuperview];
                    [_footer removeFromSuperview];
                }
            }
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:weakSelf];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
}

#pragma mark-用户求助标签使用权限查询
-(void)setUpForHelp
{
    __weak typeof(self) weakSelf=self;
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@v3/live/%@/queryHelp?uid=%@&token=%@",Baseurl,[NSString stringWithFormat:@"%ld",_liveId],[user objectForKey:@"userUID"],[user objectForKey:@"userToken"]];
    YiZhenLog(@"求助使用情况====%@",url);
    
    //获取病例界面的各种信息
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        
        NSDictionary *dic=[source objectForKey:@"data"];
        if (res == 0) {
            _questionM=[[questionModel alloc]initWithDictionary:dic];
        }
        else
        {
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:weakSelf];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
}

-(void)setupActionSheetWithTitle:(NSString *)title
{
    __weak id weakSelf=self;
    UIActionSheet*actionS=[[UIActionSheet alloc]initWithTitle:title delegate:weakSelf cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"继续", nil];
    actionS.tag=3333;
    
    [actionS showInView:self.view];
    
}

#pragma mark-actionSheet的代理方法

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%ld",buttonIndex);
    if (actionSheet.tag==3333) {
        if (buttonIndex==0) {
            toHelp=NO;
            [self performSelector:@selector(judgementToWrite)];
        }
    }
    else if (actionSheet.tag==2222)
    {
        if (buttonIndex==0) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.allowsEditing = YES;
            __weak id weakself=self;
            picker.delegate = weakself;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.navigationBar.tintColor=themeColor;
            [self presentViewController:picker animated:YES completion:nil];
        }
        else if (buttonIndex==1)
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.allowsEditing = YES;
            __weak id weakself=self;
            picker.delegate = weakself;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.navigationBar.tintColor=themeColor;
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
}

-(void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (refreshView==_header) {
        _currentpage=1;
        [_dataArray removeAllObjects];
        [self setUpData];
    }
    else if (refreshView==_footer)
    {
        _currentpage++;
        [self setUpData];
    }
}

#pragma mark-求助按钮的点击事件
-(void)pressToHelp:(UIButton*)button
{
    button.selected=!button.selected;
    isHelp=button.selected;
    UIButton*icon=[commentView viewWithTag:200];
    UIButton*titleBtn=[commentView viewWithTag:201];
    
    if (button.selected) {
        icon.layer.borderWidth=0;
        titleBtn.layer.borderWidth=0;
    }
    else
    {
        titleBtn.layer.borderWidth=0.5;
    }
    if (isHelp) {
        toHelp=YES;
        icon.selected=YES;
        [titleBtn setBackgroundColor:themeColor];
        [titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else
    {
        icon.selected=NO;
        icon.layer.borderWidth=0;
        [titleBtn setBackgroundColor:[UIColor whiteColor]];
        [titleBtn setTitleColor:darkTitleColor forState:UIControlStateNormal];
    }
}

#pragma mark-发送讨论
-(void)postTheDiscuss
{
    wangToast * toast=[[wangToast alloc]init];
    if (_commentTextView.text.length<1) {
        [self tapToHidenTheShadow];
        toast.titleStr=@"提问的内容不能为空";
        [toast show];
    }
    else{
        __weak typeof(self) weakSelf=self;
        NSString *url = [NSString stringWithFormat:@"%@v3/live/%@/sendDiscuss",Baseurl,[NSString stringWithFormat:@"%ld",_liveId]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *yzuid = [defaults objectForKey:@"userUID"];
        NSString *yztoken = [defaults objectForKey:@"userToken"];
        NSString *contentStr=_commentTextView.text;
        NSString *seekingHelp;
        seekingHelp=@"false";
        if (isHelp) {
            seekingHelp=@"true";
        }
        NSDictionary*dic=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:yzuid,yztoken,contentStr,seekingHelp,randomStr,nil] forKeys:[NSArray arrayWithObjects:@"uid",@"token",@"content",@"seekingHelp",@"random",nil]];
        [[HttpManager ShareInstance] AFNetPOSTNobodySupport:url Parameters:dic SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            __strong typeof(self) strongSelf=weakSelf;
            
            int res=[[source objectForKey:@"res"] intValue];
            if (res==0) {
                YiZhenLog(@"回复成功");
                isHelp=NO;
                postSuccess=YES;
                _commentTextView.text=@"";
                _currentpage=1;
                bottomLabel.text=@"提问";
                [_dataArray removeAllObjects];
                [strongSelf tapToHidenTheShadow];
                [strongSelf setUpData];
                randomStr=SuiJiShu;
            }
            else if (res==908){
                [strongSelf tapToHidenTheShadow];
                [_dataArray removeAllObjects];
                _currentpage=1;
                [strongSelf setUpData];
                toast.titleStr=@"提问暂未开放，请留意助理的提示";
                [toast show];
                bottomLabel.text=_commentTextView.text;
                randomStr=SuiJiShu;
            }
            else if (res==909){
                [strongSelf tapToHidenTheShadow];
                [_dataArray removeAllObjects];
                _currentpage=1;
                [strongSelf setUpData];
                toast.titleStr=@"您的求助数量已超本场每人最大次数，去掉求助标记才能发出问题";
                [toast show];
                bottomLabel.text=_commentTextView.text;
                randomStr=SuiJiShu;
            }
            else if (res==9010){
                [strongSelf tapToHidenTheShadow];
                [_dataArray removeAllObjects];
                _currentpage=1;
                [strongSelf setUpData];
                toast.titleStr=@"求助数量已到本场总数上限，去掉求助标记才能发出问题";
                [toast show];
                bottomLabel.text=_commentTextView.text;
                randomStr=SuiJiShu;
                
            }
            else
            {
                [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:strongSelf];
                randomStr=SuiJiShu;
            }
        } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error){
            YiZhenLog(@"%@",error);
        }];
    }
}

#pragma mark-UItextview的delegate

-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length>0) {
        pleaseHoldLabel.hidden=YES;
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView.text.length>0) {
        pleaseHoldLabel.hidden=YES;
    }
}

-(BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    return [_commentTextView becomeFirstResponder];
}

#pragma mark-键盘相关
- (void)regNotification
{
    //使用NSNotificationCenter 键盘将要出现
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:)name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //收到@的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reciveNotification:) name:liveMentionNof object:nil];
}

-(void)reciveNotification:(NSNotification*)notification
{
    
}

- (void)unregNotification
{
    //释放kvo
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)keyboardWasShown:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    
    CGRect keyFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat moveY = keyFrame.origin.y - self.view.frame.size.height-64;
    if (keyFrame.origin.y<ViewHeight) {
        [UIView animateWithDuration:duration animations:^{
            commentView.transform=CGAffineTransformMakeTranslation(0, moveY);
        }];
        //遮盖view的点击事件
        UIButton*tapButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [tapButton setBackgroundColor:[UIColor clearColor]];
        [tapButton setFrame:CGRectMake(0, 0, ViewWidth, commentView.y)];
        [tapButton addTarget:self action:@selector(tapToHidenTheShadow) forControlEvents:UIControlEventTouchUpInside];
        [shadowView addSubview:tapButton];
        [shadowView bringSubviewToFront:commentView];
    }
    else
    {
        [UIView animateWithDuration:duration animations:^{
            commentView.transform=CGAffineTransformMakeTranslation(0, moveY);
        }];
        [self tapToHidenTheShadow];
    }
}

#pragma mark-隐藏infoView并保存数据
-(void)toSaveTheInfo
{
    NSString*nameStr=[[NSUserDefaults standardUserDefaults]objectForKey:userNickname];
    NSString*iconStr=[[NSUserDefaults standardUserDefaults]objectForKey:userAvatar];
    //同时上传到服务器
    if (nameStr.length>2&&iconStr.length>2) {
        [self closeTheInfoView];
        [self judgementToWrite];
    }
    else
    {
        if (iconImage) {
            [self postImage:iconImage];
        }
        if (![nameField.text isEqualToString:nameStr]&&nameField.text.length>0)
        {
            [self postNickNameWithString:(nameField.text)];
        }
        
    }
    
}



-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage*image = [info objectForKey:UIImagePickerControllerEditedImage];
            iconImage=[self cutImage:image];
            [picker dismissViewControllerAnimated:YES completion:^{}];
            //头像同步修改,需做保存本地处理,或上传
            [self creatInfoView];
            [iconBtn setImage:iconImage forState:UIControlStateNormal];
        });
    });
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    [self creatInfoView];
}


#pragma mark- 上传照片

-(void)postImage:(UIImage *)image{
    
    __weak typeof(self) weakSelf=self;
    [[SetupView ShareInstance]showImageHUD:self];
    NSData *data= UIImageJPEGRepresentation(image , 1);
    NSString*url=@"http://img.augbase.com/";
    [[HttpManager ShareInstance]AFNetPOSTSupport:url Parameters:nil ConstructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:@"huati.png" mimeType:@"png"];
    } SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res==0) {
            YiZhenLog(@"上传成功");
            NSString*imageStr=[source objectForKey:@"data"];
            [weakSelf updateUserIconWithImageStr:imageStr];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
}

-(void)updateUserIconWithImageStr:(NSString*)imagStr
{
    __weak typeof(self) weakSelf=self;
    NSString *url = [NSString stringWithFormat:@"%@v3/personal/edit/avatar",Baseurl];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *yzuid = [defaults objectForKey:@"userUID"];
    NSString *yztoken = [defaults objectForKey:@"userToken"];
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:yzuid,yztoken,imagStr,randomStr,nil] forKeys:[NSArray arrayWithObjects:@"uid",@"token",@"avatar",@"random",nil]];
    [[HttpManager ShareInstance] AFNetPOSTNobodySupport:url Parameters:dic SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res==0) {
            YiZhenLog(@"上传头像成功");
            [[NSUserDefaults standardUserDefaults]setObject:imagStr forKey:userAvatar];
            NSString*nickName=[defaults objectForKey:userNickname];
            if (nickName.length>2) {
                [weakSelf judgementToWrite];
            }
            [weakSelf closeTheInfoView];
            [[SetupView ShareInstance]hideHUD];
        }
        else{
            randomStr=SuiJiShu;
            [[SetupView ShareInstance]hideHUD];
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:weakSelf];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error){
        randomStr=SuiJiShu;
        YiZhenLog(@"%@",error);
    }];
    
}
#pragma mark-修改昵称
-(void)postNickNameWithString:(NSString*)nickName
{
    __weak typeof(self) weakSelf=self;
    [[SetupView ShareInstance]showImageHUD:self];
    int bytes = [self stringConvertToInt:nameField.text];
    if (bytes<9) {
        NSString *url = [NSString stringWithFormat:@"%@v3/personal/edit/nickname",Baseurl];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *yzuid = [defaults objectForKey:@"userUID"];
        NSString *yztoken = [defaults objectForKey:@"userToken"];
        NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:yzuid,yztoken,nickName,randomStr,nil] forKeys:[NSArray arrayWithObjects:@"uid",@"token",@"nickname",@"random",nil]];
        [[HttpManager ShareInstance] AFNetPOSTNobodySupport:url Parameters:dic SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            int res=[[source objectForKey:@"res"] intValue];
            if (res==0) {
                YiZhenLog(@"上传昵称成功");
                [[NSUserDefaults standardUserDefaults]setObject:nickName forKey:userNickname];
                NSString*iconStr=[defaults objectForKey:userAvatar];
                if (iconStr.length>2) {
                    [weakSelf judgementToWrite];
                }
                [weakSelf closeTheInfoView];
                [[SetupView ShareInstance]hideHUD];
            }
            else
            {
                randomStr=SuiJiShu;
                [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:weakSelf];
            }
        } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error){
            randomStr=SuiJiShu;
            YiZhenLog(@"%@",error);
        }];
    }
    else
    {
        [[SetupView ShareInstance]showAlertViewNoButtonMessage:@"昵称过长" Title:@"提示" viewController:self];
        [self creatInfoView];
    }
    
    
}

#pragma mark-关闭infoView

-(void)closeTheInfoView
{
    UIView*view=[self.navigationController.view viewWithTag:888];
    [view removeFromSuperview];
}

-(void)pickTheIconImage
{
    [nameField resignFirstResponder];
    __weak id weakSelf=self;
    UIActionSheet*action=[[UIActionSheet alloc]initWithTitle:@"上传头像" delegate:weakSelf cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
    action.tag=2222;
    [action showInView:self.view];
}


-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    
    [nameField resignFirstResponder];
}

#pragma mark-键盘的监听事件
- (void)keyboardWillChange:(NSNotification *)note
{
    //    NSLog(@"%@", note.userInfo);
    NSDictionary *userInfo = note.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    
    CGRect keyFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat moveY = keyFrame.origin.y - self.view.frame.size.height-64;
    if (keyFrame.origin.y<ViewHeight) {
        [UIView animateWithDuration:duration animations:^{
            infoView.transform=CGAffineTransformMakeTranslation(0, moveY+150);
        }];
    }
    else
    {
        [UIView animateWithDuration:duration animations:^{
            infoView.transform=CGAffineTransformMakeTranslation(0, moveY);
        }];
    }
}

#pragma mark-字符串改变为字节
- (int)stringConvertToInt:(NSString*)strtemp
{
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++)
    {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return (strlength+1)/2;
}

- (UIImage *)cutImage:(UIImage*)image
{
    //压缩图片
    CGSize newSize;
    CGImageRef imageRef = nil;
    
    if ((image.size.width / image.size.height) < (iconBtn.size.width / iconBtn.size.height)) {
        newSize.width = image.size.width;
        newSize.height = image.size.width * iconBtn.size.height /iconBtn.size.width;
        
        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, fabs(image.size.height - newSize.height) / 2, newSize.width, newSize.height));
        
    } else {
        newSize.height = image.size.height;
        newSize.width = image.size.height * iconBtn.size.width / iconBtn.size.height;
        
        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(fabs(image.size.width - newSize.width) / 2, 0, newSize.width, newSize.height));
        
    }
    
    return [UIImage imageWithCGImage:imageRef];
}





-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_header removeFromSuperview];
    [_footer removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
