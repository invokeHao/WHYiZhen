//
//  myCollectionViewController.m
//  Yizhenapp
//
//  Created by augbase on 16/5/9.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "myCollectionViewController.h"
#import "HYSegmentedControl.h"
#import "informationModel.h"
#import "informationTableViewCell.h"
#import "topicModel.h"
#import "topicCollectionTableViewCell.h"
#import "detailGuideViewController.h"
#import "replyViewController.h"
#import "OcrWebViewController.h"
#import "detailModel.h"
//#import "topicTableViewCell.h"

@interface myCollectionViewController ()<UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate,HYSegmentedControlDelegate>
{
    NSInteger chooseIndex;
    UIView*noCollectView;
    NSString*randomStr;
    BOOL hasDelete;//已经删除
    BOOL didSelected;//已经点击过了，防止重复点击
}

@property (strong,nonatomic)HYSegmentedControl*segmentedControl;
@property (strong,nonatomic)NSMutableArray*dataArray;
@property (strong,nonatomic)UITableView *MainTable;
@property (strong, nonatomic)MJRefreshHeaderView *header;
@property (strong, nonatomic)MJRefreshFooterView *footer;
@property (assign ,nonatomic)int currentpage;

@end

@implementation myCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     chooseIndex=0;
    [self createUI];
    randomStr=SuiJiShu;
}
-(void)createUI
{
    self.view.backgroundColor=[UIColor whiteColor];
    __weak id weakSelf=self;
    self.segmentedControl = [[HYSegmentedControl alloc] initWithOriginY:0 Titles:@[NSLocalizedString(@"资讯", @""), NSLocalizedString(@"话题", @"")] delegate:weakSelf] ;
    [self.view addSubview:_segmentedControl];
    [self createTableView];
}
-(void)createTableView
{
    self.title=@"我的收藏";
    _MainTable=[[UITableView alloc]init];
    __weak id weakSelf=self;
    _MainTable.delegate=weakSelf;
    _MainTable.dataSource=weakSelf;
    _MainTable.layer.borderColor=lightGrayBackColor.CGColor;
    _MainTable.layer.borderWidth=0.5;
    _MainTable.separatorStyle=UITableViewCellSeparatorStyleNone;
    _MainTable.separatorInset = UIEdgeInsetsMake(0,15, 0, 15);
    _MainTable.backgroundColor=grayBackgroundLightColor;
    _MainTable.sectionFooterHeight = 15;

    [self.view addSubview:_MainTable];
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 15)];
    headerView.backgroundColor = grayBackgroundLightColor;
    
    _MainTable.tableHeaderView = headerView;

    [_MainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.top.mas_equalTo(_segmentedControl.mas_bottom).with.offset(0);
    }];

}

-(void)viewWillAppear:(BOOL)animated
{
    _currentpage=1;
    _header = [[MJRefreshHeaderView alloc]initWithScrollView:_MainTable];
    _footer = [[MJRefreshFooterView alloc]initWithScrollView:_MainTable];
    
    __weak id weakSelf=self;
    _header.delegate = weakSelf;
    _footer.delegate = weakSelf;

    hasDelete=NO;
    didSelected=NO;
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
    if (_dataArray.count==0) {
        return 100;
    }
    if (chooseIndex==1) {
        topicModel*model=_dataArray[indexPath.section];
        return model.cellHeight;
    }
    else
    {
        return 115;
    }

}
#pragma 添加头和尾
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 15)];
        headerView.backgroundColor = grayBackgroundLightColor;
        return headerView;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (chooseIndex==0) {
        informationTableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"informationTableViewCell"];
        if (cell==nil) {
            cell=[[informationTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"informationTableViewCell"];
            if (_dataArray.count==0) {
            }
            else
            {
                [cell setModel:_dataArray[indexPath.section]];
            }
            }
        return cell;
    }
    else
    {
        topicCollectionTableViewCell*topicCell=[tableView dequeueReusableCellWithIdentifier:@"topicCollectionTableViewCell"];
        if (topicCell==nil) {
            topicCell=[[topicCollectionTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"topicCollectionTableViewCell"];
        }
        __weak typeof(self) weakSelf=self;
        [topicCell setWebB:^(NSString *url) {
            OcrWebViewController*ocrWebVc=[[OcrWebViewController alloc]init];
            ocrWebVc.url=url;
            ocrWebVc.nameType=@"大表格";
            [weakSelf.navigationController pushViewController:ocrWebVc animated:YES];
        }];

        if (_dataArray.count==0) {
            
        }
        else{
           [topicCell setModel:_dataArray[indexPath.section]];
        }
        return topicCell;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(didSelected)
    {
        return;
    }
    if (chooseIndex==0) {
        informationModel*inforModel=_dataArray[indexPath.section];
        [self getURl:inforModel.IDS AndWithTitle:inforModel.title];
    }
    else
    {
        if (_dataArray.count==0) {
            return;
        }
        replyViewController*replyVC=[[replyViewController alloc]init];
        topicModel*model=_dataArray[indexPath.section];
        replyVC.topicId=model.IDS;
        [self.navigationController pushViewController:replyVC animated:YES];
    }
}

-(void)setUpData
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    if (chooseIndex==0) {
        [noCollectView removeFromSuperview];
        NSString *url = [NSString stringWithFormat:@"%@/v3/personal/collects/news?uid=%@&token=%@&page=%@",Baseurl,[user objectForKey:@"userUID"],[user objectForKey:@"userToken"],[NSString stringWithFormat:@"%d",_currentpage]];
        YiZhenLog(@"%@",url);
        [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            int res=[[source objectForKey:@"res"] intValue];
            if (res == 0) {
                NSArray*arr=[source objectForKey:@"data"];
                for (NSDictionary*dic in arr) {
                    informationModel*inforModel=[[informationModel alloc]initWithDictionary:dic];
                    [_dataArray addObject:inforModel];
                }
                if (_dataArray.count<1) {
                    [self creatNoMedicinesViewWithImage:@"no_collect" andTitle:@"没有收藏资讯"];
                }
                else
                {
                    [noCollectView removeFromSuperview];
                }
                [_MainTable reloadData];
                [_header endRefreshing];
                [_footer endRefreshing];
            }
        } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            YiZhenLog(@"%@",error);
            
        }];
    }
    else if (chooseIndex==1)
    {
        [noCollectView removeFromSuperview];
        NSString *url = [NSString stringWithFormat:@"%@/v3/personal/collects/topic?uid=%@&token=%@&page=%@",Baseurl,[user objectForKey:@"userUID"],[user objectForKey:@"userToken"],[NSString stringWithFormat:@"%d",_currentpage]];
        YiZhenLog(@"收藏的帖子%@",url);
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
                    [self creatNoMedicinesViewWithImage:@"no_collect" andTitle:@"没有收藏话题"];
                }
                else
                {
                    [noCollectView removeFromSuperview];
                }
                [_MainTable reloadData];
                [_header endRefreshing];
                [_footer endRefreshing];
            }
        } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            YiZhenLog(@"%@",error);            
        }];
    }
}

-(void)creatNoMedicinesViewWithImage:(NSString*)imageStr andTitle:(NSString*)title
{
    noCollectView=[[UIView alloc]initWithFrame:self.MainTable.frame];
    noCollectView.backgroundColor=grayBackgroundLightColor;
    [self.view addSubview:noCollectView];
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 0.5)];
    lineView.backgroundColor=lightGrayBackColor;
    
    YiZhenLog(@"%lf",lineView.frame.origin.y);
    [noCollectView addSubview:lineView];
    
    UIImageView*image=[[UIImageView alloc]init];
    image.center=CGPointMake(ViewWidth/2, ViewHeight/2-64-20);
    image.bounds=CGRectMake(0, 0, 95, 95);
    image.image=[UIImage imageNamed:imageStr];
    image.contentMode=UIViewContentModeScaleAspectFit;
    [noCollectView addSubview:image];
    
    UILabel*noticeLabel=[[UILabel alloc]init];
    noticeLabel.center=CGPointMake(ViewWidth/2, image.center.y+image.height/2+20);
    noticeLabel.bounds=CGRectMake(0, 0, 120, 17);
    noticeLabel.textAlignment=NSTextAlignmentCenter;
    noticeLabel.font=[UIFont boldSystemFontOfSize:16.0];
    noticeLabel.textColor=darkTitleColor;
    noticeLabel.text=title;
    [noCollectView addSubview:noticeLabel];
    
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

#pragma mark-获取url
-(void)getURl:(NSInteger)newId AndWithTitle:(NSString*)title
{
    [[SetupView ShareInstance]showHUD:self Title:@""];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@/v3/news/%@?uid=%@&token=%@",Baseurl,[NSString stringWithFormat:@"%ld",newId],[user objectForKey:@"userUID"],[user objectForKey:@"userToken"]];
    YiZhenLog(@"指南详情url====%@",url);
    [[HttpManager ShareInstance] AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res==0) {
            detailModel*model=[[detailModel alloc]initWithDictionary:[source objectForKey:@"data"]];
            //跳转详情
            detailGuideViewController*detailVC=[[detailGuideViewController alloc]init];
            detailVC.url=model.linkURL;
            detailVC.Dmodel=model;
            detailVC.themeTitle=title;
            detailVC.newsId=newId;
            [[SetupView ShareInstance]hideHUD];
            [self.navigationController pushViewController:detailVC animated:YES];
        }
        if (res==502) {
            //跳转详情
            detailGuideViewController*detailVC=[[detailGuideViewController alloc]init];
            detailVC.isDelete=YES;
            [[SetupView ShareInstance]hideHUD];
            [self.navigationController pushViewController:detailVC animated:YES];
        }
        
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[SetupView ShareInstance]hideHUD];

    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_header!=nil||_footer!=nil) {
        [_header removeFromSuperview];
        [_footer removeFromSuperview];
    }
}


//cell可编辑模式
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
////定义编辑样式
//
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath

{
    return UITableViewCellEditingStyleDelete;
}
//进入编辑模式，按下出现的编辑按钮后

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        [_MainTable beginUpdates];
        hasDelete=YES;
        NSIndexSet *indexsets = [NSIndexSet indexSetWithIndex:indexPath.section]; // 构建 索引处的行数 的数组
        // 删除 索引的方法 后面是动画样式
        [_MainTable deleteSections:indexsets withRowAnimation:UITableViewRowAnimationLeft];
        //调用删除的方法
        if (chooseIndex==0) {
            informationModel*model=_dataArray[indexPath.section];
            [self resignCollectionWithNewsId:model.IDS];
        }
        else
        {
            topicModel*topicModel=_dataArray[indexPath.section];
            [self resignTopicWithTopicId:topicModel.IDS];
        }
        [_dataArray removeObjectAtIndex:indexPath.section];
        [_MainTable endUpdates];
    }
}
//以下方法可以不是必须要实现，添加如下方法可实现特定效果：
//修改编辑按钮文字

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"取消收藏";
}

-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!hasDelete&&!didSelected) {
        didSelected=YES;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_MainTable endEditing:YES];
}

-(void)resignCollectionWithNewsId:(NSInteger)newsId
{
    NSString *url = [NSString stringWithFormat:@"%@v3/news/%@/cancelCollect",Baseurl,[NSString stringWithFormat:@"%ld",newsId]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *yzuid = [defaults objectForKey:@"userUID"];
    NSString *yztoken = [defaults objectForKey:@"userToken"];
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:yzuid,yztoken,randomStr,nil] forKeys:[NSArray arrayWithObjects:@"uid",@"token",@"random",nil]];
    [[HttpManager ShareInstance] AFNetPOSTNobodySupport:url Parameters:dic SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res==0) {
            YiZhenLog(@"取消收藏成功");
            [_MainTable reloadData];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error){
        YiZhenLog(@"%@",error);
    }];
}

-(void)resignTopicWithTopicId:(NSInteger)topicId
{
    NSString *url = [NSString stringWithFormat:@"%@v3/topic/%@/cancelCollect",Baseurl,[NSString stringWithFormat:@"%ld",topicId]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *yzuid = [defaults objectForKey:@"userUID"];
    NSString *yztoken = [defaults objectForKey:@"userToken"];
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:yzuid,yztoken,randomStr,nil] forKeys:[NSArray arrayWithObjects:@"uid",@"token",@"random",nil]];
    [[HttpManager ShareInstance] AFNetPOSTNobodySupport:url Parameters:dic SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res==0) {
            YiZhenLog(@"取消收藏帖子成功");
            [_MainTable reloadData];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error){
        YiZhenLog(@"%@",error);
    }];
}

@end
