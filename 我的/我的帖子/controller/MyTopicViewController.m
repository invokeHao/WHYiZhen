//
//  MyTopicViewController.m
//  Yizhenapp
//
//  Created by augbase on 16/5/9.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "MyTopicViewController.h"
#import "topicModel.h"
#import "topicTableViewCell.h"
#import "moduleListViewController.h"
#import "OcrWebViewController.h"
#import "personInfoViewController.h"
#import "replyViewController.h"
#import "MytopicViewTableViewCell.h"

@interface MyTopicViewController ()<UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate>
{
    UIView*noTopicView;
}
@property (strong,nonatomic)NSMutableArray*dataArray;
@property (strong,nonatomic)UITableView *MainTable;
@property (strong, nonatomic)MJRefreshHeaderView *header;
@property (strong, nonatomic)MJRefreshFooterView *footer;
@property (assign ,nonatomic)int currentpage;

@end

@implementation MyTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    _currentpage=1;
    _dataArray=[[NSMutableArray alloc]initWithCapacity:0];
//    [self createUI];

}
-(void)createUI
{
    self.title=@"我的话题";
    _MainTable=[[UITableView alloc]init];
    __weak id weakSelf=self;
    _MainTable.delegate=weakSelf;
    _MainTable.dataSource=weakSelf;
    _MainTable.layer.borderColor=lightGrayBackColor.CGColor;
    _MainTable.layer.borderWidth=0.5;

    _MainTable.separatorStyle=UITableViewCellSeparatorStyleNone;
    _MainTable.backgroundColor=grayBackgroundLightColor;
    [self.view addSubview:_MainTable];

    
    [_MainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.top.equalTo(@0);
    }];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _header = [[MJRefreshHeaderView alloc]initWithScrollView:_MainTable];
    _footer = [[MJRefreshFooterView alloc]initWithScrollView:_MainTable];
    
    __weak id weakSelf=self;
    _header.delegate = weakSelf;
    _footer.delegate = weakSelf;
    [self setUpData];
}

#pragma mark-tableView的代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_dataArray.count==0)
    {
        return  200;
    }
    else
    {
        topicModel*model=_dataArray[indexPath.section];
        return model.cellHeight;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MytopicViewTableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"topicTableViewCell"];
    if (cell==nil) {
        cell=[[MytopicViewTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"topicTableViewCell"];
    }
    __weak typeof(self) weakSelf=self;
    //这个block用来查看个人资料
    [cell setPersonB:^(NSString *iconUrl){
//        personInfoViewController*personVC=[[personInfoViewController alloc]init];
//        personVC.iconUrl=iconUrl;
//        [self.navigationController pushViewController:personVC animated:YES];
    }];
    //这个block用来跳转webView
    //这个block用来跳转webView
    [cell setWebB:^(NSString *url, NSInteger type) {
        OcrWebViewController*ocrWebVc=[[OcrWebViewController alloc]init];
        if (type==1) {
            ocrWebVc.url=url;
            ocrWebVc.nameType=@"大表格";
        }
        else if (type==2)
        {
            ocrWebVc.url=url;
            ocrWebVc.nameType=@"用药记录";
        }
        [weakSelf.navigationController pushViewController:ocrWebVc animated:YES];
    }];
    if (_dataArray.count==0) {
        
    }
    else
    {
        cell.model=_dataArray[indexPath.section];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    replyViewController*replyVC=[[replyViewController alloc]init];
    topicModel*model=_dataArray[indexPath.section];
    replyVC.topicId=model.IDS;
    [self.navigationController pushViewController:replyVC animated:YES];
}

-(void)setUpData
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@/v3/personal/topics?uid=%@&token=%@&page=%@",Baseurl,[user objectForKey:@"userUID"],[user objectForKey:@"userToken"],[NSString stringWithFormat:@"%d",_currentpage]];
    YiZhenLog(@"我的帖子%@",url);
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res == 0) {
            NSArray*arr=[source objectForKey:@"data"];
            for (NSDictionary*dic in arr) {
                topicModel*model=[[topicModel alloc]initWithDictionary:dic];
                [_dataArray addObject:model];
            }
            if (_dataArray.count<1) {
                [self creatNoMedicinesViewWithImage:@"no_reply" andTitle:@"没有发过话题"];
            }
            else
            {
                [noTopicView removeFromSuperview];
            }
            [_MainTable reloadData];
            [_header endRefreshing];
            [_footer endRefreshing];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
}

-(void)creatNoMedicinesViewWithImage:(NSString*)imageStr andTitle:(NSString*)title
{
    noTopicView=[[UIView alloc]initWithFrame:self.MainTable.frame];
    noTopicView.backgroundColor=grayBackgroundLightColor;
    [self.view addSubview:noTopicView];
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 0.5)];
    lineView.backgroundColor=lightGrayBackColor;
    
//    NSLog(@"%lf",lineView.frame.origin.y);
    [noTopicView addSubview:lineView];
    
    UIImageView*image=[[UIImageView alloc]init];
    image.center=CGPointMake(ViewWidth/2, ViewHeight/2-64);
    image.bounds=CGRectMake(0, 0, 95, 95);
    image.image=[UIImage imageNamed:imageStr];
    image.contentMode=UIViewContentModeScaleAspectFit;
    [noTopicView addSubview:image];
    
    UILabel*noticeLabel=[[UILabel alloc]init];
    noticeLabel.center=CGPointMake(ViewWidth/2, image.center.y+image.height/2+20);
    noticeLabel.bounds=CGRectMake(0, 0, 120, 17);
    noticeLabel.textAlignment=NSTextAlignmentCenter;
    noticeLabel.font=[UIFont boldSystemFontOfSize:16.0];
    noticeLabel.textColor=darkTitleColor;
    noticeLabel.text=title;
    [noTopicView addSubview:noticeLabel];
    
}


-(void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (refreshView==_header) {
        _currentpage=1;
        [_dataArray removeAllObjects];
        [self setUpData];
    }
    else 
    {
        _currentpage++;
        [self setUpData];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_dataArray removeAllObjects];
    if (_header!=nil||_footer!=nil) {
        [_header removeFromSuperview];
        [_footer removeFromSuperview];
    }
}
@end
