//
//  PointsHistoryViewController.m
//  Yizhenapp
//
//  Created by augbase on 16/5/9.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "PointsHistoryViewController.h"
#import "histroyModel.h"
#import "pointsHistroyTableViewCell.h"

@interface PointsHistoryViewController ()<UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate>

{
    NSString*leftScore;
}
@property (strong,nonatomic)NSMutableArray*dataArray;
@property (strong,nonatomic)UITableView *MainTable;
@property (strong, nonatomic)MJRefreshHeaderView *header;
@property (strong, nonatomic)MJRefreshFooterView *footer;
@property (assign ,nonatomic)int currentpage;

@end

@implementation PointsHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    _currentpage=1;
    _dataArray=[[NSMutableArray alloc]initWithCapacity:0];
    [self setUpData];
    [self createUI];

    
}

-(void)createUI
{
    self.title=@"记录";
    _MainTable=[[UITableView alloc]init];
    _MainTable.delegate=self;
    _MainTable.dataSource=self;
    _MainTable.layer.borderColor=lightGrayBackColor.CGColor;
    _MainTable.layer.borderWidth=0.5;
    _MainTable.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    _MainTable.backgroundColor=[UIColor whiteColor];
    _MainTable.separatorInset = UIEdgeInsetsMake(0,15, 0, 15);
    _MainTable.separatorColor=lightGrayBackColor;
    //去除多余的分割线
    _MainTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    
    [self.view addSubview:_MainTable];
    _header = [[MJRefreshHeaderView alloc]initWithScrollView:_MainTable];
    _footer = [[MJRefreshFooterView alloc]initWithScrollView:_MainTable];
    
    _header.delegate = self;
    _footer.delegate = self;

    [_MainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.top.equalTo(@0);
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count+1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return 124;
    }
    else
    {
        return 50;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
    {
        static NSString *cellIndentify = @"titleCell";
        UITableViewCell*cell;
        if (cell==nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        UIImageView*iconView=[[UIImageView alloc]init];
        iconView.image=[UIImage imageNamed:@"diamond"];
        [cell addSubview:iconView];
        
        UILabel*descLabel=[[UILabel alloc]init];
        descLabel.textColor=[UIColor colorWithRed:120/255.0f green:120/255.0f blue:120/255.0f alpha:1];
        descLabel.font=[UIFont systemFontOfSize:12.0];
        descLabel.text=[NSString stringWithFormat:@"累计积分: %@",leftScore];
        [cell addSubview:descLabel];
        
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(cell);
            make.centerY.mas_equalTo(cell.mas_centerY).with.offset(-10);
            make.size.mas_equalTo(CGSizeMake(57, 63));
        }];
        [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(iconView);
            make.top.mas_equalTo(iconView.mas_bottom).with.offset(10);
        }];
        return cell;
    }
     else{
        pointsHistroyTableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"pointsHistroyTableViewCell"];
        if (cell==nil) {
            cell=[[pointsHistroyTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pointsHistroyTableViewCell"];
        }
         cell.selectionStyle=UITableViewCellSelectionStyleNone;
         if (_dataArray.count==0) {
             
         }
         else
         {
             [cell setModel:_dataArray[indexPath.row-1]];
         }
        return cell;
    }


}


-(void)setUpData
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@/v3/personal/score/history?uid=%@&token=%@&page=%@",Baseurl,[user objectForKey:@"userUID"],[user objectForKey:@"userToken"],[NSString stringWithFormat:@"%d",_currentpage]];
    YiZhenLog(@"%@",url);
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res == 0) {
            NSDictionary*scoreDic=[source objectForKey:@"data"];
            leftScore=[scoreDic objectForKey:@"leftScore"];
            for (NSDictionary*dic in [scoreDic objectForKey:@"scores"]) {
                histroyModel*Hmodel=[[histroyModel alloc]initWithDictionary:dic];
                if (Hmodel.score==0) {
                    
                }
                else
                {
                    [_dataArray addObject:Hmodel];

                }
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
    [_header free];
    [_footer free];
}
@end
