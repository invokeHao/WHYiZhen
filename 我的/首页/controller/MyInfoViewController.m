//
//  ShootCaseViewController.m
//  ResultContained
//
//  Created by wang on 16/5/2.
//  Copyright (c) 2016年 wang. All rights reserved.
//

#import "MyInfoViewController.h"

#import "MineSettingInfoViewController.h"

#import "myPointsViewController.h"
#import "myCollectionViewController.h"
#import "MyTopicViewController.h"
#import "replyMeViewController.h"
#import "AdviceViewController.h"
#import "PrivateSettingViewController.h"
#import "MyLiveViewController.h"
#import "MyTicketViewController.h"

#import "redCircleView.h"
#import "UITabBar+badge.h"


#import "HomeCell.h"
#import "homeModel.h"

@interface MyInfoViewController ()

{
    NSMutableArray*imageNameArray;
    NSMutableArray*titleDataArray;
    redCircleView*redView;
    
}
@property (strong,nonatomic)homeModel*model;

@end

@implementation MyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    [self createloadingView];
    [self resinNotificationCenter];
    
}

-(void)resinNotificationCenter
{
    
    NSNotificationCenter*center=[NSNotificationCenter defaultCenter];
    //回复的通知
    [center addObserver:self selector:@selector(reciveNotifacation:) name:topicNof object:nil];
    //直播@我的通知
    [center addObserver:self selector:@selector(reciveNotifacation:) name:liveMentionNof object:nil];
    //直播直播预告的通知
    [center addObserver:self selector:@selector(reciveNotifacation:) name:liveIntroNof object:nil];
    //直播回复的通知
    [center addObserver:self selector:@selector(reciveNotifacation:) name:liveReplyNof object:nil];
    //新的代金券的通知
    [center addObserver:self selector:@selector(reciveNotifacation:) name:couponNewNof object:nil];
    //将要过期代金券的通知
    [center addObserver:self selector:@selector(reciveNotifacation:) name:couponOldNof object:nil];
}

-(void)reciveNotifacation:(NSNotification*)notification
{
    [self.tabBarController.tabBar showBadgeOnItemIndex:3];
    [_myInfoTable reloadData];
}

#pragma mark-确定
-(void)createloadingView
{
    
}

-(void)createUI
{
    __weak id weakSelf=self;
    self.view.backgroundColor=grayBackgroundLightColor;
    _myInfoTable=[[UITableView alloc]init];
    _myInfoTable.delegate=weakSelf;
    _myInfoTable.dataSource=weakSelf;
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 15)];
    headerView.backgroundColor = [UIColor clearColor];
    _myInfoTable.tableHeaderView =headerView;
    
    
    _myInfoTable.layer.borderColor=lightGrayBackColor.CGColor;
    _myInfoTable.layer.borderWidth=0.5;
    _myInfoTable.separatorColor=lightGrayBackColor;
    _myInfoTable.backgroundColor=grayBackgroundLightColor;
    _myInfoTable.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    _myInfoTable.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    //去除多余的分割线
    [self.view addSubview:_myInfoTable];
    [_myInfoTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(@0);
        make.bottom.equalTo(@-49);
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //添加莲子统计
    [Lotuseed onPageViewBegin:@"我的首页"];
    
    self.navigationController.navigationBarHidden = NO;
    [self setUpData];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"lineNav"] forBarMetrics:UIBarMetricsDefault];
    [self.tabBarController.navigationItem setRightBarButtonItems:nil];
    [self.tabBarController.navigationItem setLeftBarButtonItem:nil];
    [self.tabBarController.navigationItem setRightBarButtonItem:nil];
    self.tabBarController.title = NSLocalizedString(@"我的", @"");
    
    //判断我的Tab红点是否消失
    NSUserDefaults * user=[NSUserDefaults standardUserDefaults];
    NSInteger  count=[[user objectForKey:KliveNtfReplyAmount] integerValue]+[[user objectForKey:KliveNtfMetionAmount] integerValue]+[[user objectForKey:KliveNtfIntroAmount] integerValue] +[[user objectForKey:KtopicAmount] integerValue];
    if (count==0) {
        [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
    }

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else if (section == 1){
        return 5;
    }else{
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 &&indexPath.row == 0) {
        return 72;
    }
    else
    {
        return 50;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView*footView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 15)];
    footView.backgroundColor=[UIColor clearColor];
    return footView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"medicalCell";
    UITableViewCell*cell;
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
    }
    //头像
    UIImageView*iconView=[[UIImageView alloc]init];
    iconView.contentMode=UIViewContentModeScaleAspectFit;
    [cell addSubview:iconView];
    
    //标题
    UILabel*titleLabel=[[UILabel alloc]init];
    titleLabel.font= [UIFont fontWithName:@"PingFangSC-Light" size:15.0];
    [cell addSubview:titleLabel];
    //数量的label
    UILabel*mountLabel=[[UILabel alloc]init];
    mountLabel.font= [UIFont fontWithName:@"PingFangSC-Light" size:15.0];
    mountLabel.textColor=grayLabelColor;
    [cell addSubview:mountLabel];
    //更多icon
    UIImageView*moreView=[[UIImageView alloc]init];
    moreView.image=[UIImage imageNamed:@"goin"];
    [cell addSubview:moreView];
    
    UIView*lineView=[[UIView alloc]init];
    lineView.backgroundColor=[UIColor redColor];
    [cell addSubview:lineView];
    
    redView=[[redCircleView alloc]init];
    redView.cornerRadiu=6;
    redView.hidden=YES;
    [cell addSubview:redView];

    //适配控件
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(iconView.mas_right).with.offset(10);
//        make.right.mas_equalTo(moreView.mas_left).with.offset(-10);
        make.centerY.mas_equalTo(cell);
    }];
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.top.equalTo(@15);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    [mountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(cell);
        make.right.mas_equalTo(moreView.mas_left).with.offset(-6);
    }];

    [moreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-15);
        make.centerY.mas_equalTo(cell);
        make.size.mas_equalTo(CGSizeMake(8, 15));
    }];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@-2);
        make.left.equalTo(@15);
        make.right.equalTo(@-15);
    }];
    [redView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(cell);
        make.right.mas_equalTo(moreView.mas_left).with.offset(-6);
        make.size.mas_equalTo(CGSizeMake(12, 12));
    }];

    //此处做特殊判断
    
    if (indexPath.section==0&&indexPath.row==0) {
        static NSString *cellIndentify = @"bigCell";
        UITableViewCell*cell;
        if (cell==nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        }
        
        //头像
        UIImageView*iconView=[[UIImageView alloc]init];
        iconView.layer.cornerRadius=25;
        iconView.layer.masksToBounds=YES;
        [cell addSubview:iconView];
        
        //标题
        UILabel*titleLabel=[[UILabel alloc]init];
        titleLabel.font=[UIFont boldSystemFontOfSize:15.0];
        [cell addSubview:titleLabel];
        //更多icon
        UIImageView*moreView=[[UIImageView alloc]init];
        moreView.image=[UIImage imageNamed:@"goin"];
        [cell addSubview:moreView];
        
        //适配控件
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(iconView.mas_right).with.offset(10);
            make.centerY.mas_equalTo(cell);
        }];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15);
            make.top.equalTo(@11);
            make.size.mas_equalTo(CGSizeMake(50, 50));
        }];
        [moreView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@-15);
            make.centerY.mas_equalTo(cell);
            make.size.mas_equalTo(CGSizeMake(8, 15));
        }];
        redView.hidden=YES;
        
        [iconView sd_setImageWithURL:[NSURL URLWithString:_model.avatar] placeholderImage:[UIImage imageNamed:@"default_avatar2"]];
        
        if (_model&&_model.nickname==nil) {
            titleLabel.text=@"点击编辑头像和昵称";
        }
        else
        {
            titleLabel.text=_model.nickname;  
        }
        return cell;


    }
    else if (indexPath.section==0&&indexPath.row==1)
    {
        redView.hidden=YES;
        iconView.image=[UIImage imageNamed:imageNameArray[0]];
        titleLabel.text=titleDataArray[indexPath.row-1];
        mountLabel.text=[NSString stringWithFormat:@"%ld",_model.score];
    }
    if (indexPath.section==1) {
        redView.hidden=YES;
        NSUserDefaults * user=[NSUserDefaults standardUserDefaults];
        if (indexPath.row==0) {
            iconView.image=[UIImage imageNamed:imageNameArray[1]];
            titleLabel.text=titleDataArray[1];
            mountLabel.text=[NSString stringWithFormat:@"%ld",_model.collectAmount];
        }
        else if (indexPath.row==1)
        {
            iconView.image=[UIImage imageNamed:imageNameArray[2]];
            titleLabel.text=titleDataArray[2];
            mountLabel.text=[NSString stringWithFormat:@"%ld",_model.topicAmount];
        }
        else if (indexPath.row==2)
        {
            iconView.image=[UIImage imageNamed:imageNameArray[3]];
            titleLabel.text=titleDataArray[3];
            mountLabel.text=[NSString stringWithFormat:@"%ld",_model.replyAmount];
            
            NSInteger count=[[[NSUserDefaults standardUserDefaults] objectForKey:KtopicAmount] integerValue];
            if (count>0) {
                redView.hidden=NO;
                mountLabel.text=@"";
            }
        }
        //优惠券
        else if (indexPath.row==3)
        {
            iconView.image=[UIImage imageNamed:imageNameArray[4]];
            titleLabel.text=titleDataArray[4];
            mountLabel.text=[NSString stringWithFormat:@"%ld",_model.couponAmount];
            NSInteger count=[[user objectForKey:KliveNtfReplyAmount] integerValue]+[[user objectForKey:kNewCouponNtfAmount] integerValue]+[[user objectForKey:kCouponWillBadNtfAmount] integerValue];
            if (count>0) {
                redView.hidden=NO;
                mountLabel.text=@"";
            }
        }
        //我的直播
        else if (indexPath.row==4)
        {
            NSInteger count=[[user objectForKey:KliveNtfMetionAmount]integerValue]+[[user objectForKey:KliveNtfIntroAmount] integerValue]+[[user objectForKey:KliveNtfReplyAmount] integerValue];
            mountLabel.text=[NSString stringWithFormat:@"%ld",_model.liveAmount];
            if (count>0) {
                redView.hidden=NO;
                mountLabel.text=@"";
            }
            iconView.image=[UIImage imageNamed:imageNameArray[5]];
            titleLabel.text=titleDataArray[5];

        }
    }
    else if (indexPath.section==2) {
        redView.hidden=YES;

        cell.separatorInset=UIEdgeInsetsMake(0, ViewWidth, 0, 0);
        iconView.image=[UIImage imageNamed:imageNameArray[6]];
        titleLabel.text=titleDataArray[6];
    }
    else if(indexPath.section==3)
    {
        redView.hidden=YES;

        iconView.image=[UIImage imageNamed:imageNameArray[7]];
        titleLabel.text=titleDataArray[7];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf=self;
    if (indexPath.section == 0&&indexPath.row == 0) {
        MineSettingInfoViewController *msiv = [[MineSettingInfoViewController alloc]init];
        msiv.avatarUrl=_model.avatar;
        [self.navigationController pushViewController:msiv animated:YES];
    }
    else if (indexPath.section==0&&indexPath.row==1)
    {
        myPointsViewController*myPointVC=[[myPointsViewController alloc]init];
        [self.navigationController pushViewController:myPointVC animated:YES];
    }
    else if (indexPath.section==1&&indexPath.row==0)
    {
        myCollectionViewController*myCollectionVC=[[myCollectionViewController alloc]init];
        [self.navigationController pushViewController:myCollectionVC animated:YES];
    }
    else if (indexPath.section==1&&indexPath.row==1)
    {
        [self.navigationController pushViewController:[MyTopicViewController new] animated:YES];
    }
    else if (indexPath.section==1&&indexPath.row==2)
    {
        replyMeViewController*replyMeVC=[[replyMeViewController alloc]init];
        [replyMeVC setBlock:^{
            [weakSelf.myInfoTable reloadData];
        }];
        [self.navigationController pushViewController:replyMeVC animated:YES];
    }
    else if (indexPath.section==1&&indexPath.row==3)
    {
        //我的优惠券
        MyTicketViewController * myTicketVC=[[MyTicketViewController alloc]init];
        [self.navigationController pushViewController:myTicketVC animated:YES];
    }
    else if(indexPath.section==1&&indexPath.row==4)
    {
        //我参与的直播
        MyLiveViewController * myLiveVC=[[MyLiveViewController alloc]init];

        [self.navigationController pushViewController:myLiveVC animated:YES];
    }
    else if(indexPath.section == 2 && indexPath.row == 0){
        AdviceViewController *avc = [[AdviceViewController alloc]init];
        [self.navigationController pushViewController:avc animated:YES];
    }
    else if (indexPath.section==3 &&indexPath.row==0)
    {
        PrivateSettingViewController *psv = [[PrivateSettingViewController alloc]init];
        [self.navigationController pushViewController:psv animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark-去底部粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionFooterHeight = 15;
    if (scrollView.contentOffset.y>=sectionFooterHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, -sectionFooterHeight+1, 0);
    }
    [self.view endEditing:YES];
}

#pragma mark-数据请求
-(void)setUpData
{
    __weak typeof(self) weakSelf=self;
    titleDataArray = [@[NSLocalizedString(@"我的积分", @""),NSLocalizedString(@"我的收藏", @""),NSLocalizedString(@"我的话题", @""),NSLocalizedString(@"回复我的", @""),NSLocalizedString(@"我的优惠券", @""),NSLocalizedString(@"参与的直播", @""),NSLocalizedString(@"联系客服", @""),NSLocalizedString(@"设置", @"")] mutableCopy];
    imageNameArray = [@[@"my_scores",@"collectNew",@"posts_mine",@"reply_me",@"vouchers",@"participate_live",@"customer_service",@"set_upNew"]mutableCopy];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@/v3/personal/mine/statistics?uid=%@&token=%@",Baseurl,[user objectForKey:@"userUID"],[user objectForKey:@"userToken"]];
    YiZhenLog(@"我的主页====%@",url);
    
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res == 0) {
            weakSelf.model=[[homeModel alloc]initWithDictionary:[source objectForKey:@"data"]];
            [weakSelf.myInfoTable reloadData];
        }
        else
        {
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:weakSelf];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //添加莲子统计
    [Lotuseed onPageViewEnd:@"我的首页"];
        
    [[SetupView ShareInstance] setupNavigationLeftButton:self LeftButton:nil];
    [[SetupView ShareInstance] setupNavigationRightButton:self RightButton:nil];
}

@end
