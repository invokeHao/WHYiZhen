//
//  couponsListViewController.m
//  Yizhenapp
//
//  Created by 王浩 on 16/11/10.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "couponsListViewController.h"
#import "couponTableViewCell.h"
#import "WangWebViewController.h"

@interface couponsListViewController ()<UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate>
{
    NSInteger chooseIndex;
    UIView*noTicketView;//没有优惠券占位view
    UILabel * countLable;//可用票数
    NSString*randomStr;

    
    BOOL DontUseCoupon;//不使用优惠券
    
    UISwitch * couponSwith;
}

@property (strong,nonatomic)NSMutableArray*dataArray;
@property (strong,nonatomic)UITableView *MainTable;
@property (strong, nonatomic)MJRefreshHeaderView *header;
@property (strong, nonatomic)MJRefreshFooterView *footer;
@property (assign ,nonatomic)int currentpage;

@end

@implementation couponsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DontUseCoupon=[[[NSUserDefaults standardUserDefaults] objectForKey:DonotUseCoupon] boolValue];
    [self createUI];
}

-(void)createUI
{
    //创建选择器
    [self creatSwith];
    
    self.view.backgroundColor=grayBackgroundLightColor;
    //navgationBar下面的线
    UIView * line=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 0.5)];
    line.backgroundColor=lightGrayBackColor;
    [self.view addSubview:line];
    
    _MainTable=[[UITableView alloc]init];
    __weak id weakSelf=self;
    _MainTable.delegate=weakSelf;
    _MainTable.dataSource=weakSelf;
    _MainTable.separatorStyle=UITableViewCellSeparatorStyleNone;
    _MainTable.separatorInset = UIEdgeInsetsMake(0,15, 0, 15);
    _MainTable.backgroundColor=grayBackgroundLightColor;
    _MainTable.sectionFooterHeight = 15;
    
    [self.view addSubview:_MainTable];
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 30)];
    headerView.backgroundColor = [UIColor clearColor];
    _MainTable.tableHeaderView = headerView;
    
    UILabel * label1=[[UILabel alloc]init];
    label1.font=YiZhenFont13;
    label1.textColor=grayLabelColor;
    label1.text=@"有";
    [headerView addSubview:label1];
    
    countLable=[[UILabel alloc]init];
    countLable.font=YiZhenFont13;
    countLable.textColor=themeColor;
    [headerView addSubview:countLable];
    
    UILabel * label2=[[UILabel alloc]init];
    label2.font=YiZhenFont13;
    label2.textColor=grayLabelColor;
    label2.text=@"张代金券可用";
    [headerView addSubview:label2];
    
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@15);
        make.height.equalTo(@20);
    }];
    
    [countLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(label1.mas_right).with.offset(2);
        make.top.equalTo(@0);
        make.height.equalTo(@20);
    }];
    
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(countLable.mas_right).with.offset(2);
        make.top.equalTo(@0);
        make.height.equalTo(@20);
    }];
    
    [_MainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.top.equalTo(@72);
    }];
}

-(void)creatSwith
{
    UIView * swithBackView=[[UIView alloc]initWithFrame:CGRectMake(0, 8, ViewWidth, 48)];
    swithBackView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:swithBackView];
    
    UILabel * label=[[UILabel alloc]init];
    label.font=YiZhenFont;
    label.textColor=[UIColor blackColor];
    label.text=@"不使用优惠券";
    [swithBackView addSubview:label];
    
    couponSwith=[[UISwitch alloc]init];
    couponSwith.onTintColor=themeColor;
    couponSwith.on=DontUseCoupon;
    [couponSwith addTarget:self action:@selector(doNotUseCoupons:) forControlEvents:UIControlEventValueChanged];
    [swithBackView addSubview:couponSwith];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.centerY.mas_equalTo(swithBackView);
        make.height.equalTo(@22);
    }];
    
    [couponSwith mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-15);
        make.centerY.mas_equalTo(swithBackView);
        make.size.mas_equalTo(CGSizeMake(51, 31));
    }];
}

-(void)doNotUseCoupons:(UISwitch*)swith
{
    NSUserDefaults * user=[NSUserDefaults standardUserDefaults];
    if (swith.isOn) {
        DontUseCoupon=YES;
        _couBlock(0);
        _checkId=0;
        [_MainTable reloadData];
        [user setObject:@YES forKey:DonotUseCoupon];
    }
    else
    {
        DontUseCoupon=NO;
        if (_dataArray.count<1) {
            return;
        }
        TicketModel*model=_dataArray[0];
        _checkId=model.IDS;
        [_MainTable reloadData];
        _couBlock(_checkId);
        [user setObject:@NO forKey:DonotUseCoupon];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    self.title=@"使用优惠券";
    _currentpage=1;
    _header = [[MJRefreshHeaderView alloc]initWithScrollView:_MainTable];
    _footer = [[MJRefreshFooterView alloc]initWithScrollView:_MainTable];
    
    __weak id weakSelf=self;
    _header.delegate = weakSelf;
    _footer.delegate = weakSelf;
    
    _dataArray=[[NSMutableArray alloc]initWithCapacity:0];
    [self setUpData];
    [super viewWillAppear:animated];
}
#pragma mark-tableView的代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArray.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    couponTableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"informationTableViewCell"];
    if (cell==nil) {
        cell=[[couponTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"informationTableViewCell"];
    }
    if (_dataArray.count==0) {
    }
    else
    {
        [cell setModle:_dataArray[indexPath.section]];
        TicketModel *model=_dataArray[indexPath.section];
        cell.cellId=model.IDS;
        
        if (DontUseCoupon) {
            _checkId=0;
        }
        
        if (cell.cellId==_checkId) {
            cell.selectedView.hidden=NO;
            _couBlock(cell.cellId);
        }
        else{
            cell.selectedView.hidden=YES;
        }
        __weak typeof(self) weakSelf=self;
        [cell setSelectB:^(NSInteger cellId) {
            _checkId=cellId;
            [weakSelf.MainTable reloadData];
        }];
        [cell setRuleB:^(NSString *ruleUrl) {
            WangWebViewController * wangWebVC=[[WangWebViewController alloc]init];
            wangWebVC.url=ruleUrl;
            wangWebVC.webType=@"使用规则";
            [weakSelf.navigationController pushViewController:wangWebVC animated:self];
        }];
    }
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(void)setUpData
{
    __weak typeof(self) weakSelf=self;
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [noTicketView removeFromSuperview];
    NSString *url = [NSString stringWithFormat:@"%@v3/live/%@/coupons?uid=%@&token=%@&page=%@",Baseurl,[NSString stringWithFormat:@"%ld",_liveId],[user objectForKey:@"userUID"],[user objectForKey:@"userToken"],[NSString stringWithFormat:@"%d",_currentpage]];
    YiZhenLog(@"直播可用优惠券＝＝%@",url);
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res == 0) {
            NSArray*arr=[source objectForKey:@"data"];
            for (NSDictionary*dic in arr) {
                TicketModel*Model=[[TicketModel alloc]initWithDictionary:dic];
                [_dataArray addObject:Model];
            }
            if (_dataArray.count>0&&_checkId<0) {
                TicketModel *firstModel=_dataArray[0];
                _checkId=firstModel.IDS;
            }
            countLable.text=[NSString stringWithFormat:@"%ld",_dataArray.count];
            if (_dataArray.count<1) {
                [weakSelf creatNoMedicinesViewWithImage:@"no_vouchers" andTitle:@"暂无优惠券"];
            }
            else
            {
                [noTicketView removeFromSuperview];
            }
            [_MainTable reloadData];
            [_header endRefreshing];
            [_footer endRefreshing];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
}

#pragma mark－刷新代理
-(void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView{
    if (refreshView == _header) {
        self.currentpage =1;
        [_dataArray removeAllObjects];
        [self setUpData];
    }else{
        self.currentpage++;
        [self setUpData];
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_header!=nil||_footer!=nil) {
        [_header removeFromSuperview];
        [_footer removeFromSuperview];
    }
}

-(void)creatNoMedicinesViewWithImage:(NSString*)imageStr andTitle:(NSString*)title
{
    noTicketView=[[UIView alloc]initWithFrame:CGRectMake(0, _MainTable.y+30, ViewWidth, _MainTable.height)];
    noTicketView.backgroundColor=grayBackgroundLightColor;
    [self.view addSubview:noTicketView];
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 0.5)];
    lineView.backgroundColor=lightGrayBackColor;
    
    YiZhenLog(@"%lf",lineView.frame.origin.y);
    [noTicketView addSubview:lineView];
    
    UIImageView*image=[[UIImageView alloc]init];
    image.center=CGPointMake(ViewWidth/2, ViewHeight/2-64-20-30);
    image.bounds=CGRectMake(0, 0, 95, 95);
    image.image=[UIImage imageNamed:imageStr];
    image.contentMode=UIViewContentModeScaleAspectFit;
    [noTicketView addSubview:image];
    
    UILabel*noticeLabel=[[UILabel alloc]init];
    noticeLabel.center=CGPointMake(ViewWidth/2, image.center.y+image.height/2+20);
    noticeLabel.bounds=CGRectMake(0, 0, 120, 17);
    noticeLabel.textAlignment=NSTextAlignmentCenter;
    noticeLabel.font=[UIFont boldSystemFontOfSize:16.0];
    noticeLabel.textColor=darkTitleColor;
    noticeLabel.text=title;
    [noTicketView addSubview:noticeLabel];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
