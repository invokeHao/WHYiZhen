//
//  MyTicketViewController.m
//  Yizhenapp
//
//  Created by 王浩 on 16/11/9.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "MyTicketViewController.h"
#import "HYSegmentedControl.h"
#import "TicketModel.h"
#import "TicketTableViewCell.h"
#import "WangWebViewController.h"

@interface MyTicketViewController ()<UITableViewDelegate,UITableViewDataSource,HYSegmentedControlDelegate,MJRefreshBaseViewDelegate>
{
    NSInteger chooseIndex;
    UIView*noTicketView;//没有优惠券占位view
    NSString*randomStr;
}
@property (strong,nonatomic)HYSegmentedControl*segmentedControl;
@property (strong,nonatomic)NSMutableArray*dataArray;
@property (strong,nonatomic)UITableView *MainTable;
@property (strong, nonatomic)MJRefreshHeaderView *header;
@property (strong, nonatomic)MJRefreshFooterView *footer;
@property (assign ,nonatomic)int currentpage;

@end

@implementation MyTicketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    chooseIndex=0;
    [self createUI];
    randomStr=SuiJiShu;
    
    NSUserDefaults * user=[NSUserDefaults standardUserDefaults];
    
    NSInteger amount=[[user objectForKey:kNewCouponNtfAmount] integerValue]+[[user objectForKey:kCouponWillBadNtfAmount] integerValue];
    [UIApplication sharedApplication].applicationIconBadgeNumber-=amount;
    [user setObject:@"0" forKey:kCouponWillBadNtfAmount];
    [user setObject:@"0" forKey:kNewCouponNtfAmount];
    //同步角标到个推服务器
    [GeTuiSdk setBadge:[UIApplication sharedApplication].applicationIconBadgeNumber];
}

-(void)createUI
{
    self.view.backgroundColor=[UIColor whiteColor];
    __weak id weakSelf=self;
    self.segmentedControl = [[HYSegmentedControl alloc] initWithOriginY:0 Titles:@[NSLocalizedString(@"可使用", @""), NSLocalizedString(@"已过期", @""),NSLocalizedString(@"已使用", @"")] delegate:weakSelf] ;
    [self.view addSubview:_segmentedControl];
    [self createTableView];
}

-(void)createTableView
{
    _MainTable=[[UITableView alloc]init];
    __weak id weakSelf=self;
    _MainTable.delegate=weakSelf;
    _MainTable.dataSource=weakSelf;
    _MainTable.layer.borderColor=lightGrayBackColor.CGColor;
    _MainTable.layer.borderWidth=0.5;
    _MainTable.separatorStyle=UITableViewCellSeparatorStyleNone;
    _MainTable.separatorInset = UIEdgeInsetsMake(0,15, 0, 15);
    _MainTable.backgroundColor=grayBackgroundLightColor;
    
    [self.view addSubview:_MainTable];
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 15)];
    footerView.backgroundColor = grayBackgroundLightColor;
    
    _MainTable.tableFooterView = footerView;
    
    [_MainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.top.mas_equalTo(_segmentedControl.mas_bottom).with.offset(0);
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.title=@"我的优惠券";
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
    TicketTableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"informationTableViewCell"];
    if (cell==nil) {
        cell=[[TicketTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"informationTableViewCell"];
    }
    if (_dataArray.count==0) {
    }
    else{
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        [cell setModle:_dataArray[indexPath.section]];
        __weak typeof(self) weakSelf=self;
        [cell setRuleB:^(NSString *ruleLink) {
            WangWebViewController*wangWebVC=[[WangWebViewController alloc]init];
            wangWebVC.url=ruleLink;
            wangWebVC.webType=@"使用规则";
            [weakSelf.navigationController pushViewController:wangWebVC animated:YES];
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
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *type;
    switch (chooseIndex) {
        case 0:
            type=@"0";
            break;
         case 1:
            type=@"1";
            break;
        case 2:
            type=@"2";
            break;
        default:
            break;
    }
    [noTicketView removeFromSuperview];
    NSString *url = [NSString stringWithFormat:@"%@v3/personal/coupons/%@?uid=%@&token=%@&page=%@",Baseurl,type,[user objectForKey:@"userUID"],[user objectForKey:@"userToken"],[NSString stringWithFormat:@"%d",_currentpage]];
    YiZhenLog(@"我的优惠券＝＝%@",url);
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res == 0) {
            NSArray*arr=[source objectForKey:@"data"];
            for (NSDictionary*dic in arr) {
                TicketModel*Model=[[TicketModel alloc]initWithDictionary:dic];
                [_dataArray addObject:Model];
            }
                if (_dataArray.count<1) {
                    [self creatNoMedicinesViewWithImage:@"no_vouchers" andTitle:@"暂无优惠券"];
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

#pragma mark-segement的代理方法
-(void)hySegmentedControlSelectAtIndex:(NSInteger)index
{
    chooseIndex=index;
    [_dataArray removeAllObjects];
    _currentpage=1;
    [self setUpData];
}

-(void)creatNoMedicinesViewWithImage:(NSString*)imageStr andTitle:(NSString*)title
{
    noTicketView=[[UIView alloc]initWithFrame:self.MainTable.frame];
    noTicketView.backgroundColor=grayBackgroundLightColor;
    [self.view addSubview:noTicketView];
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 0.5)];
    lineView.backgroundColor=lightGrayBackColor;
    
    YiZhenLog(@"%lf",lineView.frame.origin.y);
    [noTicketView addSubview:lineView];
    
    UIImageView*image=[[UIImageView alloc]init];
    image.center=CGPointMake(ViewWidth/2, ViewHeight/2-64-20);
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
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_header!=nil||_footer!=nil) {
        [_header removeFromSuperview];
        [_footer removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
