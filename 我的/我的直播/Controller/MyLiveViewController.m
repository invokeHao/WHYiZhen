//
//  MyLiveViewController.m
//  Yizhenapp
//
//  Created by 王浩 on 16/11/9.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "MyLiveViewController.h"
#import "liveViewController.h"
#import "answerModel.h"
#import "answerTableViewCell.h"



@interface MyLiveViewController ()<UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate>
{
    UIView * bgView;
}

@property (strong,nonatomic)UITableView * MainTable;
@property (strong,nonatomic)NSMutableArray * dataArray;//数据数组
@property (strong, nonatomic)MJRefreshHeaderView *header;
@property (strong, nonatomic)MJRefreshFooterView *footer;
@property (assign ,nonatomic)int currentpage;

@end

@implementation MyLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    //接受到@的通知
    [center addObserver:self selector:@selector(reciveLiveNotification:) name:liveMentionNof object:nil];
    //接收到直播预告的通知
    [center addObserver:self selector:@selector(reciveLiveNotification:) name:liveIntroNof object:nil];
    //接收到直播回复的通知
    [center addObserver:self selector:@selector(reciveLiveNotification:) name:liveReplyNof object:nil];
    
}

-(void)reciveLiveNotification:(NSNotification*)notification
{
    [_MainTable reloadData];
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
    
    UIView * footView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 10)];
    footView.backgroundColor=[UIColor clearColor];
    _MainTable.tableFooterView=footView;
    
    [self.view addSubview:_MainTable];
    [_MainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
}

-(void)creatNoDiscussView
{
    bgView=[[UIView alloc]initWithFrame:self.MainTable.frame];
    bgView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:bgView];
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 0.5)];
    lineView.backgroundColor=lightGrayBackColor;
    
    [bgView addSubview:lineView];
    
    UIImageView*image=[[UIImageView alloc]init];
    image.center=CGPointMake(ViewWidth/2, ViewHeight/2-64);
    image.bounds=CGRectMake(0, 0, 120, 120);
    image.image=[UIImage imageNamed:@"live_dt_star"];
    image.contentMode=UIViewContentModeScaleAspectFit;
    [bgView addSubview:image];
    
    UILabel * zhanWeiLabel=[[UILabel alloc]init];
    zhanWeiLabel.font=[UIFont systemFontOfSize:14.0];
    zhanWeiLabel.textColor=grayLabelColor;
    zhanWeiLabel.text=@"暂无参加的直播";
    zhanWeiLabel.textAlignment=NSTextAlignmentCenter;
    [bgView addSubview:zhanWeiLabel];
    
    [zhanWeiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bgView);
        make.height.equalTo(@20);
        make.top.mas_equalTo(image.mas_bottom).with.offset(10);
    }];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title=@"我参与的直播";
    
    [_MainTable reloadData];
    
    _header = [[MJRefreshHeaderView alloc]initWithScrollView:_MainTable];
    _footer = [[MJRefreshFooterView alloc]initWithScrollView:_MainTable];
    
    __weak id weakSelf=self;
    _header.delegate = weakSelf;
    _footer.delegate = weakSelf;
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
        NSInteger livePushId=[[[NSUserDefaults standardUserDefaults]objectForKey:KLivePushId] integerValue];
        if (livePushId==model.IDS) {
            cell.redPoint.hidden=NO;
        }
        else
        {
            cell.redPoint.hidden=YES;
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    answerModel*model=_dataArray[indexPath.section];
    if (model.hasAttend) {
        LiveViewController*liveViewVC=[[LiveViewController alloc]init];
        liveViewVC.liveId=model.IDS;
        liveViewVC.ThemeTitle=model.title;
        liveViewVC.hasClosed=model.hasClosed;
        [self.navigationController pushViewController:liveViewVC animated:YES];
    }
}

-(void)setUpData
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@v3/personal/lives?uid=%@&token=%@&page=%@",Baseurl,[user objectForKey:@"userUID"],[user objectForKey:@"userToken"],[NSString stringWithFormat:@"%d",_currentpage]];
    YiZhenLog(@"我的直播====%@",url);
    
    //获取病例界面的各种信息
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        
        NSMutableArray*arr;
        arr=[source objectForKey:@"data"];
        if (res == 0) {
            for (NSDictionary*dic in arr) {
                answerModel*model=[[answerModel alloc]initWithDictionary:dic];
                [_dataArray addObject:model];
            }
            if (_dataArray.count<1) {
                [self creatNoDiscussView];
                return ;
            }
            if (_dataArray.count>0&&bgView) {
                [bgView removeFromSuperview];
            }
            [self.header endRefreshing];
            [self.footer endRefreshing];
            [_MainTable reloadData];
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
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:self];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
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
    
    if (self.header||self.footer) {
        [self.header removeFromSuperview];
        [self.footer removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
