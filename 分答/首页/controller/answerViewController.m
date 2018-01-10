//
//  answerViewController.m
//  Yizhenapp
//
//  Created by augbase on 16/8/31.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "answerViewController.h"
#import "answerTableViewCell.h"
#import "answerModel.h"
#import "liveDetailViewController.h"
#import "LiveViewController.h"

#import "UITabBar+badge.h"

@interface answerViewController ()<UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate,NoNetWorkingDelegate,UIWebViewDelegate>

{
    NoNetworkingView * NoNetView;
    UIWebView *_webView;
    NSString * IntroUrl;//直播预告的url
    BOOL hadReviceNot;//接收到@通知
}

@property (strong,nonatomic)UITableView * MainTable;
@property (strong,nonatomic)NSMutableArray * dataArray;//数据数组
@property (strong, nonatomic)MJRefreshHeaderView *header;
@property (strong, nonatomic)MJRefreshFooterView *footer;
@property (assign ,nonatomic)int currentpage;

@end

@implementation answerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showRedPointNoTab];
    [self creatUI];
    _currentpage=1;
    _dataArray=[[NSMutableArray alloc]initWithCapacity:0];

    [self setUpData];
    
    //接受通知
    [self resinNotificationCenter];

}

-(void)resinNotificationCenter
{
    NSNotificationCenter*center=[NSNotificationCenter defaultCenter];
    //接收到微信支付成功的通知
    [center addObserver:self selector:@selector(refreshData) name:KWXPaySuccess object:nil];
}

-(void)showRedPointNoTab
{
    //判断我的Tab红点
    NSUserDefaults * user=[NSUserDefaults standardUserDefaults];
    NSInteger  mineCount=[[user objectForKey:KliveNtfMetionAmount] integerValue]+[[user objectForKey:KliveNtfIntroAmount] integerValue]+[[user objectForKey:KliveNtfReplyAmount] integerValue] +[[user objectForKey:KtopicAmount] integerValue]+[[user objectForKey:kCouponWillBadNtfAmount] integerValue] + [[user objectForKey:kNewCouponNtfAmount] integerValue];
    if (mineCount>0) {
        [self.tabBarController.tabBar showBadgeOnItemIndex:3];
    }
    //判断是病历Tab小红点
    NSInteger memoCount=[[[NSUserDefaults standardUserDefaults]objectForKey:KmemoboxAmount] integerValue];
    
    NSInteger chatAmount=[[[NSUserDefaults standardUserDefaults]objectForKey:KchatAmount] integerValue];
    NSInteger informationAmount=[[[NSUserDefaults standardUserDefaults]objectForKey:KinformationAmount] integerValue];
    
    NSInteger OcrSuccessAmount=[[[NSUserDefaults standardUserDefaults] objectForKey:KOcrSuccessAmount] integerValue];
    
    NSInteger OcrFailedAmount=[[[NSUserDefaults standardUserDefaults] objectForKey:KOcrFailedAmount] integerValue];
    
    if (OcrSuccessAmount+OcrFailedAmount+chatAmount+informationAmount+memoCount>0) {
        [self.tabBarController.tabBar showBadgeOnItemIndex:2];
    }
}



-(void)createWebview
{
    _webView = [[UIWebView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    _webView.delegate=self;
    _webView.backgroundColor=[UIColor whiteColor];
    _webView.scrollView.backgroundColor=[UIColor whiteColor];
    _webView.scrollView.showsVerticalScrollIndicator=NO;
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 0.5)];
    lineView.backgroundColor=lightGrayBackColor;
    [_webView addSubview:lineView];
    
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:IntroUrl]];
    [_webView loadRequest:request];

    [self.view addSubview:_webView];
    
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.bottom.equalTo(@-49);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
    }];
}

-(void)getIntroUrl
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@v3/live/intro?uid=%@&token=%@",Baseurl,[user objectForKey:@"userUID"],[user objectForKey:@"userToken"]];
    YiZhenLog(@"获取直播预告====%@",url);
    
    //获取病例界面的各种信息
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        
        [NoNetView removeFromSuperview];
        NoNetView=nil;
        if (res == 0) {
            IntroUrl=[source objectForKey:@"data"];
            [self createWebview];
            }
        else
        {
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:self];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
        if (error.code==-1009) {
            [_dataArray removeAllObjects];
            [_MainTable reloadData];
            [self createNoNetView];
        }
    }];
}

-(void)creatUI
{
    self.view.backgroundColor=[UIColor whiteColor];
    [self creatTableView];
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
    _MainTable.backgroundColor=grayBackgroundLightColor;
    [self.view addSubview:_MainTable];
    [_MainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(@0);
        make.bottom.equalTo(@-49);
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //添加莲子统计
    [Lotuseed onPageViewBegin:@"直播首页"];
    
    [self.tabBarController.navigationItem setLeftBarButtonItems:nil];
    [self.tabBarController.navigationItem setRightBarButtonItems:nil];
    
    self.tabBarController.title = NSLocalizedString(@"易诊", @"");
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    _header = [[MJRefreshHeaderView alloc]initWithScrollView:_MainTable];
    _footer = [[MJRefreshFooterView alloc]initWithScrollView:_MainTable];
    
    __weak id weakSelf=self;
    _header.delegate = weakSelf;
    _footer.delegate = weakSelf;
    //判断我的Tab红点是否消失
    NSUserDefaults * user=[NSUserDefaults standardUserDefaults];
    NSInteger  count=[[user objectForKey:KliveNtfMetionAmount] integerValue]+[[user objectForKey:KliveNtfIntroAmount] integerValue] +[[user objectForKey:KliveNtfReplyAmount] integerValue]+[[user objectForKey:KtopicAmount] integerValue]+[[user objectForKey:kNewCouponNtfAmount] integerValue]+[[user objectForKey:kCouponWillBadNtfAmount] integerValue];
    if (count==0) {
        [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
    }
}

#pragma mark-tabelView的代理方法
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_dataArray.count==0) {
        return 190;
    }
    else {
        answerModel*model=_dataArray[indexPath.section];
        return model.cellHeight;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    answerTableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"answerCell"];
    if (cell==nil) {
        cell=[[answerTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"answerCell"];
    }
    if (_dataArray.count<1) {
    }
    else
    {
        answerModel*model=_dataArray[indexPath.section];
        [cell setModel:model];
        //同时model中一个属性一起判断是否显示红点
        if (hadReviceNot) {
            cell.redPoint.hidden=NO;
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_dataArray.count<1) {return;}
    answerModel*model=_dataArray[indexPath.section];
    if (model.hasAttend) {
        LiveViewController*liveViewVC=[[LiveViewController alloc]init];
        liveViewVC.liveId=model.IDS;
        liveViewVC.ThemeTitle=model.title;
        liveViewVC.hasClosed=model.hasClosed;
        [self.navigationController pushViewController:liveViewVC animated:YES];
    }
    else
    {
        liveDetailViewController*liveDetailVC=[[liveDetailViewController alloc]init];
        liveDetailVC.IDS=model.IDS;
        [self.navigationController pushViewController:liveDetailVC animated:YES];
    }
}


-(void)setUpData
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@v3/live/list?uid=%@&token=%@&page=%@",Baseurl,[user objectForKey:@"userUID"],[user objectForKey:@"userToken"],[NSString stringWithFormat:@"%d",_currentpage]];
    YiZhenLog(@"直播列表====%@",url);
    __weak typeof(self) weakSelf=self;
    //获取病例界面的各种信息
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        
        __strong typeof(self) StrongSelf=weakSelf;
        [NoNetView removeFromSuperview];
        NoNetView=nil;
        
        NSMutableArray*arr;
        arr=[source objectForKey:@"data"];
        if (res == 0) {
            for (NSDictionary*dic in arr) {
                answerModel*model=[[answerModel alloc]initWithDictionary:dic];
                [_dataArray addObject:model];
            }
            [StrongSelf.header endRefreshing];
            [StrongSelf.footer endRefreshing];
            
            [_MainTable reloadData];
        }
        else
        {
            if(res==102)
            {
                if (_header||_footer) {
                    [StrongSelf.header removeFromSuperview];
                    [StrongSelf.footer removeFromSuperview];
                }
            }
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:StrongSelf];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
        if (error.code==-1009) {
            [_dataArray removeAllObjects];
            [_MainTable reloadData];
            [weakSelf createNoNetView];
        }
    }];
}
-(void)createNoNetView
{
    if (NoNetView==nil) {
        NoNetView=[[NoNetworkingView alloc]initWithFrame:self.view.frame];
        __weak id weakSelf=self;
        NoNetView.delegate=weakSelf;
        [_MainTable addSubview:NoNetView];
    }
}

#pragma mark-NoNetView的代理方法
-(void)functionView:(NoNetworkingView *)view refreshWithUrl:(NSString *)Url
{
    _currentpage=1;
    [self setUpData];
}

-(void)refreshData
{
    _currentpage=1;
    [_dataArray removeAllObjects];
    [self setUpData];
}

#pragma mark-mJ刷新代理
-(void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (refreshView==_header) {
        _currentpage=1;
        [_dataArray removeAllObjects];
        [self setUpData];
//        [self getIntroUrl];
    }
    else if (refreshView==_footer)
    {
        _currentpage++;
        [self setUpData];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //添加莲子统计
    [Lotuseed onPageViewEnd:@"直播首页"];
    
    if (self.header||self.footer) {
        [self.header removeFromSuperview];
        [self.footer removeFromSuperview];
    }
}

#pragma mark-webView代理方法

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [[SetupView ShareInstance]showImageHUD:self];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[SetupView ShareInstance]hideHUD];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
