//
//  myPointsViewController.m
//  Yizhenapp
//
//  Created by augbase on 16/5/6.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "myPointsViewController.h"
#import "rankView.h"
#import "pointButton.h"
#import "MaskPointsViewController.h"
#import "pointsModel.h"
#import "PointsHistoryViewController.h"
#import "OcrWebViewController.h"

@interface myPointsViewController ()

{
    UILabel*totalPointsLabel;//总积分的label
    UILabel*rankLabel;//排名的label
    UILabel*currentName;//当前称谓
    UILabel*nextName;//下一个称谓
}
@property (strong,nonatomic)rankView* rankCircle;
@property (strong,nonatomic)NSMutableArray *dataArray;
@property (strong,nonatomic)pointsModel *model;


@end

@implementation myPointsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    [self.tabBarController.navigationItem setLeftBarButtonItem:nil];
    [self.tabBarController.navigationItem setRightBarButtonItem:nil];
    
    //这里的标题根据获取的数据显示
    self.title = NSLocalizedString(@"积分", @"");
    [self setUpData];
    //设置NavigationItem
    //添加按钮
    UIButton* addBtn =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 22)];
    [addBtn setTitle:@"记录" forState:UIControlStateNormal];
    [addBtn setTitleColor:themeColor forState:UIControlStateNormal];
    [addBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [addBtn addTarget:self action:@selector(pressToSeeTheHistory:) forControlEvents:UIControlEventTouchUpInside];
    addBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem*addBar=[[UIBarButtonItem alloc]initWithCustomView:addBtn];
    
    [self.navigationItem setRightBarButtonItem:addBar];
}

-(void)createUI
{
    self.view.backgroundColor=[UIColor whiteColor];
    
    UIView*navigationLineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 0.5)];
    navigationLineView.backgroundColor=lightGrayBackColor;
    [self.view addSubview:navigationLineView];
    
    UIView*leftView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width/2, 75)];
    leftView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:leftView];
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(self.view.width/2, 10, 0.5, 55)];
    lineView.backgroundColor=lightGrayBackColor;
    [self.view addSubview:lineView];
    
    UIView*rightView=[[UIView alloc]initWithFrame:CGRectMake(self.view.width/2, 0, self.view.width/2, 75)];
    rightView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:rightView];
    UIView*lineView2=[[UIView alloc]initWithFrame:CGRectMake(15, 75, self.view.width-30, 0.5)];
    lineView2.backgroundColor=lightGrayBackColor;
    [self.view addSubview:lineView2];
    
    totalPointsLabel=[[UILabel alloc]init];
    totalPointsLabel.center=CGPointMake(leftView.center.x, 30);
    totalPointsLabel.bounds=CGRectMake(0, 0, 100, 18);
    totalPointsLabel.textColor=themeColor;
    totalPointsLabel.textAlignment=NSTextAlignmentCenter;
    totalPointsLabel.font=[UIFont systemFontOfSize:17.0];
    totalPointsLabel.text=[NSString stringWithFormat:@"%ld",_model.totalScore];
    [leftView addSubview:totalPointsLabel];
    
    UILabel*Ulabel=[[UILabel alloc]init];
    Ulabel.center=CGPointMake(leftView.center.x, 30+20);
    Ulabel.bounds=CGRectMake(0, 0, 100, 16);
    Ulabel.text=@"累计积分";
    Ulabel.font=YiZhenFont;
    Ulabel.textAlignment=NSTextAlignmentCenter;
    [leftView addSubview:Ulabel];
    
    rankLabel=[[UILabel alloc]init];
    rankLabel.center=CGPointMake(leftView.center.x, 30);
    rankLabel.bounds=CGRectMake(0, 0, 100, 18);
    rankLabel.font=[UIFont systemFontOfSize:17.0];
    rankLabel.textColor=themeColor;
    rankLabel.textAlignment=NSTextAlignmentCenter;
    rankLabel.text=[NSString stringWithFormat:@"%ld％",_model.ranking];
    [rightView addSubview:rankLabel];
    
    Ulabel=[[UILabel alloc]init];
    Ulabel.center=CGPointMake(leftView.center.x, 30+20);
    Ulabel.bounds=CGRectMake(0, 0, 100, 16);
    Ulabel.textAlignment=NSTextAlignmentCenter;
    Ulabel.font=YiZhenFont;
    Ulabel.text=@"社区排名";
    [rightView addSubview:Ulabel];
    
    [self createRankCircle];
    
    UILabel*Ulabel1=[[UILabel alloc]init];
    Ulabel1.center=CGPointMake(self.view.center.x, _rankCircle.center.y+118);
    Ulabel1.bounds=CGRectMake(0, 0, 150, 13);
    Ulabel1.text=@"积分兑换不影响等级变化";
    Ulabel1.textColor=[UIColor colorWithRed:120/255.0f green:120/255.0f blue:120/255.0f alpha:1];
    Ulabel1.textAlignment=NSTextAlignmentCenter;
    Ulabel1.font=YiZhenFont12;
    [self.view addSubview:Ulabel1];
 
    
    pointButton*pointBtn=[pointButton buttonWithType:UIButtonTypeCustom];
    [pointBtn setTitle:@"获取积分" forState:UIControlStateNormal];
    [pointBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [pointBtn.titleLabel setFont:YiZhenFont17];
    [pointBtn setImage:[UIImage imageNamed:@"my_scores_w"] forState:UIControlStateNormal];
    [pointBtn setCenter:CGPointMake(self.view.center.x,self.view.height-78-25)];
    [pointBtn setBounds:CGRectMake(0, 0, 170, 45)];
    [pointBtn.titleLabel setFont:[UIFont systemFontOfSize:17.0]];
    [pointBtn addTarget:self action:@selector(pressToseeThePointsMask) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pointBtn];
    
    UIView*btnBack=[[UIView alloc]initWithFrame:pointBtn.frame];
    btnBack.backgroundColor=themeColor;
    btnBack.layer.cornerRadius=10;
    btnBack.layer.masksToBounds=YES;
    [self.view addSubview:btnBack];
    [self.view bringSubviewToFront:pointBtn];

    UIButton*ruleBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [ruleBtn setCenter:CGPointMake(self.view.center.x, self.view.height-25-7)];
    [ruleBtn setBounds:CGRectMake(0, 0, 80, 16)];
    [ruleBtn setTitleColor:themeColor forState:UIControlStateNormal];
    [ruleBtn setTitle:@"积分规则" forState:UIControlStateNormal];
    [ruleBtn.titleLabel setFont:YiZhenFont14];
    [ruleBtn addTarget:self action:@selector(pressToSeeTheRule) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ruleBtn];
#pragma mark-4s另作修改
    if (ViewHeight==480) {
        [ruleBtn setCenter:CGPointMake(self.view.center.x, self.view.height-15-7)];
        [pointBtn setCenter:CGPointMake(self.view.center.x, self.view.height-22-20-45/2)];
        [btnBack setCenter:pointBtn.center];
        [_rankCircle setCenter:CGPointMake(self.view.center.x, self.view.height/2-20)];
        Ulabel1.center=CGPointMake(self.view.center.x, _rankCircle.center.y+105);
    }
}


-(void)createRankCircle
{
    _rankCircle=[[rankView alloc]initWithLineColor:themeColor loopColor:lightGrayBackColor];
    //设置frame
    _rankCircle.center=CGPointMake(ViewWidth/2, self.view.height/2-64);
    _rankCircle.bounds=CGRectMake(0, 0, 175, 175);
    
    //开启动画（可选,建议在百分比前面设置，否则一开始没有动画）
    _rankCircle.animatable = YES;
    //百分比，超过100，按照100算
    CGFloat maxFen=_model.maxScore;
    CGFloat minFen=_model.minScore;
    CGFloat scoreFen=_model.totalScore;
    CGFloat fen=((scoreFen-minFen)/(maxFen-minFen))*100;
    self.rankCircle.percent = fen;

    
    //属性可选的，可以不设置，设置透明就是圆环
    _rankCircle.backgroundColor = [UIColor clearColor];
    //设置标题
    self.rankCircle.title = _model.currentLevel;
    //设置单位
    self.rankCircle.percentUnit = [NSString stringWithFormat:@"下一个等级%@",_model.nextLevel];
    self.rankCircle.lessPoint=[NSString stringWithFormat:@"还差%ld分",_model.maxScore-_model.totalScore];
    
    [self.view addSubview:self.rankCircle];
}



-(void)setUpData
{
    _dataArray=[[NSMutableArray alloc]initWithCapacity:0];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@/v3/personal/score/statistics?uid=%@&token=%@",Baseurl,[user objectForKey:@"userUID"],[user objectForKey:@"userToken"]];
    YiZhenLog(@"积分%@",url);
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res == 0) {
            _model=[[pointsModel alloc]init];
            [_model setValuesForKeysWithDictionary:[source objectForKey:@"data"]];
        }
        [self createUI];
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
}


#pragma mark-NavigationBar上面的按钮时间
-(void)pressToSeeTheHistory:(UIButton*)button
{
    PointsHistoryViewController*pointHVC=[[PointsHistoryViewController alloc]init];
    [self.navigationController pushViewController:pointHVC animated:YES];
  
}

#pragma mark-点击查看积分任务
-(void)pressToseeThePointsMask
{
    MaskPointsViewController*maskVC=[[MaskPointsViewController alloc]init];
    [self.navigationController pushViewController:maskVC animated:YES];
}

#pragma mark-点击查看积分规则
-(void)pressToSeeTheRule
{
    OcrWebViewController*ocrWebVC=[[OcrWebViewController alloc]init];
    ocrWebVC.url=[NSString stringWithFormat:@"%@/v3/webview/scoresRule",Baseurl];
    ocrWebVC.nameType=@"积分规则";
    [self.navigationController pushViewController:ocrWebVC animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [_rankCircle removeFromSuperview];
}

@end
