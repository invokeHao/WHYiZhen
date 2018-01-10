//
//  userListViewController.m
//  yizhenDoctor
//
//  Created by augbase on 16/9/14.
//  Copyright © 2016年 augbase. All rights reserved.
//

#import "userListViewController.h"
#import "userListTableViewCell.h"


@interface userListViewController ()<UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate>

{
    UIView * shadowView;//阴影view
    UIView * bgView;//占位图
    NSString * replayID;
    NSString * randomStr;
}
@property (strong,nonatomic)UITableView * MainTable;
@property (strong,nonatomic)NSMutableArray * dataArray;
@property (strong, nonatomic)MJRefreshHeaderView *header;
@property (strong, nonatomic)MJRefreshFooterView *footer;
@property (assign ,nonatomic)int currentpage;

@end

@implementation userListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    [self resinNotificationCenter];
    _currentpage=1;
    _dataArray=[[NSMutableArray alloc]initWithCapacity:0];
}

-(void)resinNotificationCenter
{
    //直播@我的通知数降到0
    NSInteger amount=[[[NSUserDefaults standardUserDefaults]objectForKey:KliveNtfMetionAmount] integerValue];
    [UIApplication sharedApplication].applicationIconBadgeNumber-=amount;
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:KliveNtfMetionAmount];
    //同步角标到个推服务器
    [GeTuiSdk setBadge:[UIApplication sharedApplication].applicationIconBadgeNumber];
}


-(void)creatUI
{
    self.view.backgroundColor=[UIColor whiteColor];
    [self creatTableView];
}

-(void)creatTableView
{
    _MainTable=[[UITableView alloc]init];
    _MainTable.delegate=self;
    _MainTable.dataSource=self;
    _MainTable.layer.borderColor=lightGrayBackColor.CGColor;
    _MainTable.layer.borderWidth=0.5;
    _MainTable.showsVerticalScrollIndicator=NO;
    _MainTable.separatorStyle=UITableViewCellSeparatorStyleNone;
    _MainTable.separatorColor=lightGrayBackColor;
    _MainTable.backgroundColor=[UIColor whiteColor];
    _MainTable.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    _MainTable.separatorInset = UIEdgeInsetsMake(0, 53, 0, 15);
    [self.view addSubview:_MainTable];
    [_MainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
    
    UIView*footView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 15)];
    footView.backgroundColor=[UIColor clearColor];
    _MainTable.tableFooterView = footView;
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(53, 0, ViewWidth-65+3, 0.5)];
    lineView.backgroundColor=lightGrayBackColor;
    [footView addSubview:lineView];

    _header = [[MJRefreshHeaderView alloc]initWithScrollView:_MainTable];
    _footer = [[MJRefreshFooterView alloc]initWithScrollView:_MainTable];
    
    _header.delegate = self;
    _footer.delegate = self;
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
    zhanWeiLabel.text=@"暂无内容";
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
    randomStr=SuiJiShu;
    self.title=@"与我相关";
    [self setUpData];
    
    UIButton*backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"closed_sb"] forState:UIControlStateNormal];
    [backBtn setFrame:CGRectMake(0, 0, 22, 22)];
    [backBtn addTarget:self action:@selector(pressToBackTheDiscuss) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*back=[[UIBarButtonItem alloc]initWithCustomView:backBtn];
    [self.navigationItem setLeftBarButtonItem:back];
}

-(void)pressToBackTheDiscuss
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark-tabelView的代理方法
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_dataArray.count==0) {
        return 190;
    }
    else {
        userListModel*model=_dataArray[indexPath.row];
        return model.cellHeight;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    userListTableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"userCell"];
    if (cell==nil) {
        cell=[[userListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userCell"];
    }
    if (_dataArray.count==0) {
        
    }
    else
    {
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        userListModel*model=_dataArray[indexPath.row];
        [cell setListModel:model];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)setUpData
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@/v3/live/%@/discuss/me?uid=%@&token=%@&page=%@",Baseurl,[NSString stringWithFormat:@"%ld",_liveId],[user objectForKey:@"userUID"],[user objectForKey:@"userToken"],[NSString stringWithFormat:@"%d",_currentpage]];
    YiZhenLog(@"讨论列表====%@",url);
    
    //获取病例界面的各种信息
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        
        NSMutableArray*arr;
        arr=[source objectForKey:@"data"];
        if (res == 0) {
            for (NSDictionary*dic in arr) {
                userListModel*model=[[userListModel alloc]initWithDictionary:dic];
                _themeTitle=model.creatorName;
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_header||_footer) {
        [_header removeFromSuperview];
        [_footer removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
