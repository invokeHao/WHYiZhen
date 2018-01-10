//
//  LiveViewController.m
//  Yizhenapp
//
//  Created by augbase on 16/9/5.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "LiveViewController.h"
#import "liveCellFrameModel.h"
#import "LiveTableViewCell.h"
#import "liveDiscussViewController.h"
#import "liveDiscussModel.h"
#import "discussTableViewCell.h"
#import "UUAVAudioPlayer.h"
#import "liveDetailViewController.h"

#define discussTabelWith 170
#define discussTabelHeight 150
#define KcloseBtnWith 32

@interface LiveViewController ()<UITableViewDataSource,UITableViewDelegate,MJRefreshBaseViewDelegate>
{
    BOOL toRefresh;//判断是否刷新
    BOOL hasNewData;//有新的数据
    BOOL tableViewAtBottom;//tableView在当前
    BOOL isBackFromDiscussVC;//从提问页面返回
    BOOL isFirstTime;//第一次进入且没有提问消息
    BOOL hasZhanWei;//有占位图
    
    NSInteger firstMessageId;//第一个messageId
    NSInteger lastMessageId;//最后一个messageId
    NSInteger lastDiscussId;//最新的discussId
    NSInteger cellNum; //标记cell用
    
    UIVisualEffectView * discussView; //讨论tabelView的背景view
    UIImageView *discussBackImageView;
    redCircleView*redpoint;//提问上的红点
    
    UIButton * closeBtn;//控制讨论板按钮
    UIButton * newmessageBtn;//新消息的按钮
    
    //定时刷新器
    NSTimer *timer;
    NSString *randomStr;
    NSString * checkTime;//用来检测时间是否显示
}
@property (strong,nonatomic)UITableView * MainTable;//主tableView
@property (strong,nonatomic)UITableView * discussTable;//讨论的tableView
@property (strong,nonatomic)NSMutableArray * dataArray;//直播数据数组
@property (strong,nonatomic)NSMutableArray * discussArray;//讨论数据数组
@property (strong,nonatomic)MJRefreshHeaderView *header;
@property (strong,nonatomic)MJRefreshFooterView *footer;

@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    [self resinNotificationCenter];
    if (_hasClosed) {
        [self syncTheLiveData];
    }
    else
    {
        [self initData];
    }
    _dataArray=[[NSMutableArray alloc]initWithCapacity:0];
    _discussArray=[[NSMutableArray alloc]initWithCapacity:0];
    lastDiscussId=0;
    lastMessageId=0;
    randomStr=SuiJiShu;
    cellNum=0;
    
}

-(void)resinNotificationCenter
{
    NSNotificationCenter*center=[NSNotificationCenter defaultCenter];
    //直播@我的通知
    [center addObserver:self selector:@selector(reciveLiveMentionNotifacation:) name:liveMentionNof object:nil];
    NSUserDefaults * user=[NSUserDefaults standardUserDefaults];
    
    NSInteger amount=[[user objectForKey:KliveNtfIntroAmount] integerValue] +[[user objectForKey:KliveNtfReplyAmount]integerValue];
    [UIApplication sharedApplication].applicationIconBadgeNumber-=amount;
    [user setObject:@"0" forKey:KliveNtfReplyAmount];
    [user setObject:@"0" forKey:KliveNtfIntroAmount];
    //同步角标到个推服务器
    [GeTuiSdk setBadge:[UIApplication sharedApplication].applicationIconBadgeNumber];
    
    //消除掉推送的直播ID
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:KLivePushId];
}

-(void)reciveLiveMentionNotifacation:(NSNotification*)notification
{
    //显示“提问”上的红点
    redpoint.hidden=NO;
}


-(void)creatUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self createTableView];
    [self creatDiscussTableView];
    [self creatCloseBtn];//创建控制讨论板的按钮
    [self creatNewMessageBtn];//创建刷新的button
}
-(void)createTableView
{
    //创建主table
    _MainTable = [[UITableView alloc] init];
    _MainTable.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64);
    _MainTable.backgroundColor = [UIColor whiteColor];
    __weak id weakSlef=self;
    _MainTable.delegate = weakSlef;
    _MainTable.dataSource = weakSlef;
    _MainTable.layer.borderColor=lightGrayBackColor.CGColor;
    _MainTable.layer.borderWidth=0.5;
    _MainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _MainTable.allowsSelection = NO;
    [self.view addSubview:_MainTable];
    
    UIView*footView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 15)];
    footView.backgroundColor=[UIColor whiteColor];
    _MainTable.tableFooterView = footView;

}

- (void)creatDiscussTableView{
    
    UIBlurEffect *beffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    discussView= [[UIVisualEffectView alloc]initWithEffect:beffect];
    discussView.frame=CGRectMake(ViewWidth-10-discussTabelWith, 6, discussTabelWith, discussTabelHeight);
    discussView.layer.cornerRadius=8;
    discussView.layer.masksToBounds=YES;
    [self.view addSubview:discussView];
    
    discussBackImageView=[[UIImageView alloc]initWithFrame:CGRectMake(ViewWidth-35, 0, 15, 6)];
    discussBackImageView.image=[UIImage imageNamed:@"combined _shape2"];
    [self.view addSubview:discussBackImageView];
    
    //创建讨论的tableView
    _discussTable=[[UITableView alloc]init];
    _discussTable.frame=CGRectMake(0,5, discussTabelWith , discussTabelHeight-5);
    _discussTable.backgroundColor=[UIColor clearColor];
    _discussTable.layer.cornerRadius=8;
    _discussTable.layer.masksToBounds=YES;
    _discussTable.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    _discussTable.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    _discussTable.separatorColor =[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.2];
    __weak id weakSelf=self;
    _discussTable.delegate=weakSelf;
    _discussTable.dataSource=weakSelf;
    _discussTable.scrollEnabled=NO;
    
    [discussView addSubview:_discussTable];
}

-(void)creatCloseBtn
{
    closeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"retractable"] forState:UIControlStateNormal];
    [closeBtn setFrame:CGRectMake(ViewWidth-10-KcloseBtnWith, 164, KcloseBtnWith, KcloseBtnWith)];
    [closeBtn addTarget:self action:@selector(closeOrOpenTheDiscussBoard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
}

-(void)creatNewMessageBtn
{
    newmessageBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [newmessageBtn setFrame:CGRectMake(ViewWidth/2-60, ViewHeight-20-40-64, 120, 40)];
    [newmessageBtn setTitle:@"有新内容" forState:UIControlStateNormal];
    [newmessageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [newmessageBtn setBackgroundColor:themeColor];
    [newmessageBtn.titleLabel setFont:YiZhenFont16];
    [newmessageBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    newmessageBtn.layer.cornerRadius=20;
    newmessageBtn.layer.masksToBounds=YES;
    [newmessageBtn addTarget:self action:@selector(pressToSeeTheNewMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newmessageBtn];
    newmessageBtn.hidden=YES;
}

-(void)creatTimer
{
    if (timer==nil) {
        timer=[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(syncTheLiveData) userInfo:nil repeats:YES];
    }
    [timer fire];
}

-(UIButton*)createTitleBtn
{
    UIButton*titleBtnView=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 130, 44)];
    titleBtnView.backgroundColor=[UIColor clearColor];
    [titleBtnView addTarget:self action:@selector(pressToShowLiveDetail) forControlEvents:UIControlEventTouchUpInside];
    UILabel*titleL=[[UILabel alloc]init];
    titleL.font=[UIFont boldSystemFontOfSize:17.0];
    titleL.textColor=[UIColor blackColor];
    titleL.text=_ThemeTitle;
    [titleBtnView addSubview:titleL];
    //自定义分享view
    UIImageView * titleIcon=[[UIImageView alloc]init];
    [titleIcon setImage:[UIImage imageNamed:@"detail_live"]];
    [titleBtnView addSubview:titleIcon];
    //位置适配
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(@12);
        make.right.equalTo(@-22);
        make.height.equalTo(@20);
    }];
    [titleIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleL.mas_right).with.offset(0);
        make.top.equalTo(@12);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    return titleBtnView;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (timer==nil&&isBackFromDiscussVC) {
        [self creatTimer];
    }
    _header=[[MJRefreshHeaderView alloc]initWithScrollView:_MainTable];
    _footer=[[MJRefreshFooterView alloc]initWithScrollView:_MainTable];
    
    __weak id weakSelf=self;
    _header.delegate=weakSelf;
    _footer.delegate=weakSelf;
//自定义titleView
    UIButton*titleBtnView=[self createTitleBtn];
    self.navigationItem.titleView=titleBtnView;
    //讨论的按钮
    UIButton*discussBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [discussBtn setTitle:@"提问" forState:UIControlStateNormal];
    [discussBtn setTitleColor:themeColor forState:UIControlStateNormal];
    [discussBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [discussBtn setFrame:CGRectMake(0, 0, 35, 22)];
    [discussBtn addTarget:self action:@selector(pressToDiscussTheTheme) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*discuss=[[UIBarButtonItem alloc]initWithCustomView:discussBtn];
    [self.navigationItem setRightBarButtonItem:discuss];
    
    UIButton*backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(0, 0, 28, 22)];
    [backBtn setImage:[UIImage imageNamed:@"back_w"] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    [backBtn addTarget:self action:@selector(pressToBackTheList) forControlEvents:UIControlEventTouchUpInside];
    [[SetupView ShareInstance] setupNavigationLeftButton:self LeftButton:backBtn];
    
    redpoint=[[redCircleView alloc]init];
    redpoint.cornerRadiu=4;
    [discussBtn addSubview:redpoint];
    [redpoint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@-1.5);
        make.right.equalTo(@2.5);
        make.size.mas_equalTo(CGSizeMake(8, 8));
    }];
    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
    NSInteger count=[[user objectForKey:KliveNtfMetionAmount] integerValue];
    if (count>0) {
        redpoint.hidden=NO;
    }
    else
    {
        redpoint.hidden=YES;
    }
}

#pragma mark-view上的点击事件
-(void)closeOrOpenTheDiscussBoard
{
    if (closeBtn.y>150) {
        CGRect viewRect=discussView.frame;
        CGRect buttonRect=closeBtn.frame;
        viewRect.size.height=0;
        buttonRect.origin.y=10;
        [UIView animateWithDuration:0.5 animations:^{
            discussView.frame=viewRect;
            closeBtn.frame=buttonRect;
            [closeBtn setImage:[UIImage imageNamed:@"retractable2"] forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            discussBackImageView.hidden=YES;
        }];
    }
    else
    {
        CGRect viewRect=discussView.frame;
        CGRect buttonRect=closeBtn.frame;
        viewRect.size.height=discussTabelHeight;
        buttonRect.origin.y=164;
        [UIView animateWithDuration:0.5 animations:^{
            discussView.frame=viewRect;
            closeBtn.frame=buttonRect;
        }];
        
        [closeBtn setImage:[UIImage imageNamed:@"retractable"] forState:UIControlStateNormal];
        discussBackImageView.hidden=NO;
    }
}

-(void)pressToBackTheList
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)pressToSeeTheNewMessage
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_dataArray.count-1 inSection:0];
    [_MainTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    newmessageBtn.hidden=YES;
}

-(void)pressToDiscussTheTheme
{
    liveDiscussViewController*discussVC=[[liveDiscussViewController alloc]init];
    discussVC.liveId=_liveId;
    discussVC.hasClosed=_hasClosed;
    [discussVC setBackB:^(BOOL isBack) {
        isBackFromDiscussVC=isBack;
    }];
    [self.navigationController pushViewController:discussVC animated:YES];
}

//点击查看直播详情
-(void)pressToShowLiveDetail
{
    liveDetailViewController*livewDetailVC=[[liveDetailViewController alloc]init];
    livewDetailVC.hadJoin=YES;
    livewDetailVC.IDS=_liveId;
    [self.navigationController pushViewController:livewDetailVC animated:YES];
}

#pragma mark-tableView的delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==_MainTable) {
        if (_dataArray.count==0) {
            return 20;
        }
        liveCellFrameModel*model=_dataArray[indexPath.row];
        //保证直播简介和医生简介的连接
        if (model.messageModel.type==3) {
            return model.cellHeght-10;
        }
        else
        {
            return model.cellHeght;
        }
    }
    else
    {
        return 50;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==_MainTable) {
        return _dataArray.count;
    }
    else
    {
        return _discussArray.count;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==_MainTable) {
        static NSString *cellIdentifier = @"cell";
        
        LiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[LiveTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if (_dataArray.count==0) {
        }
        else
        {
            liveCellFrameModel*model=_dataArray[indexPath.row];
            cell.liveCellFrame = model;
            cell.IDS=model.messageModel.IDS;
            cell.isPlaying=NO;
            if (cell.IDS==cellNum) {
                [cell.voiceButton didLoadVoice];
                cell.isPlaying=YES;
            }
        }
        __weak typeof(self) weakSelf=self;
        //标记已读
        [cell setVoiceBlock:^(BOOL hasreaded, NSInteger messageID,BOOL needRefrsh) {
            if (needRefrsh) {
                [weakSelf markTheMessageWithMessageId:messageID];
            }
            liveCellFrameModel*model=_dataArray[indexPath.row];
            model.messageModel.hasRead=hasreaded;
        }];
        //开始播放声音
        [cell setBeginBlock:^(BOOL hasBegin) {
            if (hasBegin) {
                timer.fireDate=[NSDate distantFuture];
                //标记下播放中的cell的IDS
                cellNum=cell.IDS;
            }
        }];
        //结束播放
        [cell setEndBlock:^(BOOL hasEnd) {
            if (hasEnd) {
                timer.fireDate=[NSDate distantPast];
                cellNum=0;
            }
        }];
//        NSLog(@"cellNum==%ld",cellNum);
        return cell;
    }
    else
    {
       static NSString *cellIdentifier = @"discussCell";
        discussTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell=[[discussTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if (_discussArray.count==0) {
        }
        else
        {
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.model=_discussArray[indexPath.row];
        }
        return cell;
    }
}

- (void)tableViewScrollToBottom{
    if (_discussArray.count == 0)
        return;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_discussArray.count-1 inSection:0];
    [_discussTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    NSIndexPath *mIndexPath = [NSIndexPath indexPathForRow:_dataArray.count-1 inSection:0];
    [_MainTable scrollToRowAtIndexPath:mIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark-讨论版滚动到最下面
-(void)discussTabelScrollToBottom
{
    if(_discussArray.count==0){
        return;
    }
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:_discussArray.count-1 inSection:0];
    [_discussTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView==_MainTable) {
        CGFloat height=_MainTable.height+64;
        CGFloat contentOffSet=_MainTable.contentOffset.y;
        CGFloat distanceFromeBottom=_MainTable.contentSize.height-contentOffSet+64;
        if (distanceFromeBottom<height+50) {
            tableViewAtBottom=YES;
            hasNewData=NO;
            newmessageBtn.hidden=YES;
        }
        if (distanceFromeBottom>height+50) {
            tableViewAtBottom=NO;
        }
    }
}

#pragma mark-获取列表数据（next是true向下翻页，next为false向上翻页）
-(void)setUpDataWithMessageId:(NSInteger)messageId andNext:(BOOL)nextpage
{
    NSString * next=@"false";
    if (nextpage) {
        next=@"true";
    }
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@v3/live/%@/message?uid=%@&token=%@&messageId=%@&next=%@",Baseurl,[NSString stringWithFormat:@"%ld",_liveId],[user objectForKey:@"userUID"],[user objectForKey:@"userToken"],[NSString stringWithFormat:@"%ld",messageId],next];
    YiZhenLog(@"直播内容列表====%@",url);
    
    //获取病例界面的各种信息
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        
        NSMutableArray*arr;
        arr=[source objectForKey:@"data"];
        NSMutableArray*recoderArr=[NSMutableArray arrayWithArray:_dataArray];
        [_dataArray removeAllObjects];
        
        BOOL first=YES;
        
        if (res == 0) {
            for (NSDictionary*dic in arr) {
                if (first) {
                    LiveModel*firstModel=[[LiveModel alloc]initWithDictionary:dic];
                    firstMessageId=firstModel.IDS;
                    liveCellFrameModel * cellFrameModel=[[liveCellFrameModel alloc]init];
                    cellFrameModel.messageModel=firstModel;
                    [_dataArray addObject:cellFrameModel];
                    first=NO;
                }
                else
                {
                    LiveModel*model=[[LiveModel alloc]initWithDictionary:dic];
                    liveCellFrameModel * cellFrameModel=[[liveCellFrameModel alloc]init];
                    cellFrameModel.messageModel=model;
                    [_dataArray addObject:cellFrameModel];

                }
            }
            for (liveCellFrameModel*model in recoderArr) {
                [_dataArray addObject:model];
            }
            [_MainTable reloadData];
            timer.fireDate=[NSDate distantPast];
            [_header endRefreshing];
            [_footer endRefreshing];
        }
        else
        {
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:self];
            [_header endRefreshing];
            [_footer endRefreshing];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
}

#pragma mark-初始化数据（直接到正在直播的页）
-(void)initData
{
    __weak typeof(self) weakSelf=self;
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@v3/live/%@/sync?uid=%@&token=%@",Baseurl,[NSString stringWithFormat:@"%ld",_liveId],[user objectForKey:@"userUID"],[user objectForKey:@"userToken"]];
    YiZhenLog(@"当前直播列表====%@",url);
    
    //获取病例界面的各种信息
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        
        __strong typeof(self) StrongSelf=weakSelf;
        NSMutableDictionary*listdic=[source objectForKey:@"data"];
        NSMutableArray*messageArr=listdic[@"messageList"];
        NSMutableArray*discussArr=listdic[@"discussList"];
        if (res == 0) {
            for (int i=0; i<messageArr.count; i++) {
                if (i==0) {
                    LiveModel*model=[[LiveModel alloc]initWithDictionary:messageArr[0]];
                    model.showTime=YES;
                    checkTime=model.createTime;
                    firstMessageId=model.IDS;
                    liveCellFrameModel * cellFrameModel=[[liveCellFrameModel alloc]init];
                    cellFrameModel.messageModel=model;
                    [_dataArray addObject:cellFrameModel];
                }
                else if(i>0)
                {
                    LiveModel*model1=[[LiveModel alloc]initWithDictionary:messageArr[i-1]];
                    LiveModel*model2=[[LiveModel alloc]initWithDictionary:messageArr[i]];
                    if ([StrongSelf checkTime:model1.createTime ToAfterTime:model2.createTime]) {
                        model2.showTime=YES;
                    }
                    else
                    {
                        model2.showTime=NO;
                    }
                    liveCellFrameModel * cellFrameModel=[[liveCellFrameModel alloc]init];
                    cellFrameModel.messageModel=model2;
                    [_dataArray addObject:cellFrameModel];
                    checkTime=model2.createTime;
                }
            }
            if (messageArr.count==1) {
                liveCellFrameModel * firstCellModel=_dataArray[0];
                LiveModel * firstModel=firstCellModel.messageModel;
                
                LiveModel * model=[[LiveModel alloc]init];
                model.type=4;
                NSString* timeStr=[firstModel showStartTime:firstModel.liveStartTime];
                model.createTime=[NSString stringWithFormat:@"直播时间 %@",timeStr];

                model.IDS=firstModel.IDS;
                liveCellFrameModel * cellFrameModel=[[liveCellFrameModel alloc]init];
                cellFrameModel.messageModel=model;
                [_dataArray addObject:cellFrameModel];
                hasZhanWei=YES;
            }
            for (NSDictionary*dic in discussArr) {
                liveDiscussModel*discussModel=[[liveDiscussModel alloc]initWithDictionary:dic];
                [_discussArray addObject:discussModel];
            }
            if (_discussArray.count<1&&closeBtn.y>150) {
                [StrongSelf closeOrOpenTheDiscussBoard];
                [closeBtn setImage:[UIImage imageNamed:@"retractable"] forState:UIControlStateNormal];
                isFirstTime=YES;
            }
            [_MainTable reloadData];
            [_discussTable reloadData];
            
            //拿到最新的id
            liveCellFrameModel*messageModel=[_dataArray lastObject];
            lastMessageId=messageModel.messageModel.IDS;
            liveDiscussModel*discussModel=[_discussArray lastObject];
            lastDiscussId=discussModel.IDS;
            
            if (_dataArray.count>0) {
                [StrongSelf tableViewScrollToBottom];
            }
            [StrongSelf creatTimer];
        }
        else
        {
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:StrongSelf];
            [StrongSelf.navigationController popViewControllerAnimated:YES];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
}


#pragma mark-同步刷新列表
-(void)syncTheLiveData
{
    __weak typeof(self) weakSelf=self;
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url= [NSString stringWithFormat:@"%@v3/live/%@/sync?uid=%@&token=%@&messageId=%@&discussId=%@",Baseurl,[NSString stringWithFormat:@"%ld",_liveId],[user objectForKey:@"userUID"],[user objectForKey:@"userToken"],[NSString stringWithFormat:@"%ld",lastMessageId],[NSString stringWithFormat:@"%ld",lastDiscussId]];
//    YiZhenLog(@"直播同步列表====%@",url);
    
    //获取病例界面的各种信息
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        __strong typeof(self) strongSelf=weakSelf;
        NSMutableDictionary*listdic=[source objectForKey:@"data"];
        NSMutableArray*messageArr=listdic[@"messageList"];
        NSMutableArray*discussArr=listdic[@"discussList"];
        if (res == 0) {
            for (int i=0; i<messageArr.count; i++) {
                if (i==0) {
                    
                    //移除占位图
                    if (hasZhanWei) {
                        [_dataArray removeLastObject];
                        hasZhanWei=NO;
                    }

                    LiveModel*model=[[LiveModel alloc]initWithDictionary:messageArr[0]];
                    if ([strongSelf checkTime:checkTime ToAfterTime:model.createTime]) {
                        model.showTime=YES;
                        checkTime=model.createTime;
                    }
                    else
                    {
                        model.showTime=NO;
                    }
                    liveCellFrameModel * cellFrameModel=[[liveCellFrameModel alloc]init];
                    cellFrameModel.messageModel=model;
                    [_dataArray addObject:cellFrameModel];
                }
                else if(i>0)
                {
                    LiveModel*model1=[[LiveModel alloc]initWithDictionary:messageArr[i-1]];
                    LiveModel*model2=[[LiveModel alloc]initWithDictionary:messageArr[i]];
                    if ([strongSelf checkTime:model1.createTime ToAfterTime:model2.createTime]) {
                        model2.showTime=YES;
                    }
                    else
                    {
                        model2.showTime=NO;
                    }
                    liveCellFrameModel * cellFrameModel=[[liveCellFrameModel alloc]init];
                    cellFrameModel.messageModel=model2;
                    
                    [_dataArray addObject:cellFrameModel];
                }
            }
            for (NSDictionary*dic in discussArr) {
                liveDiscussModel*discussModel=[[liveDiscussModel alloc]initWithDictionary:dic];
                [_discussArray addObject:discussModel];
            }
            if (_discussArray.count>0&&isFirstTime&&closeBtn.y<100) {
                [strongSelf closeOrOpenTheDiscussBoard];
                isFirstTime=NO;
            }

            [_MainTable reloadData];
            [_discussTable reloadData];
            [_footer endRefreshing];
            
            if (messageArr.count>0) {
                hasNewData=YES;
                if (!tableViewAtBottom) {
                    if (_hasClosed) {
                        newmessageBtn.hidden=YES;
                    }
                    else{
                        newmessageBtn.hidden=NO;
                    }
                }
                else
                {
                    if (_hasClosed){}
                    else
                    {
                        [strongSelf tableViewScrollToBottom];
                    }
                }
            }
            [strongSelf discussTabelScrollToBottom];

            //拿到最新的id
            liveCellFrameModel*messageModel=[_dataArray lastObject];
            lastMessageId=messageModel.messageModel.IDS;
            liveDiscussModel*discussModel=[_discussArray lastObject];
            lastDiscussId=discussModel.IDS;
        }
        else
        {
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:strongSelf];
            [strongSelf.navigationController popViewControllerAnimated:YES];
            [_footer endRefreshing];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
}

#pragma mark-标记为已读
-(void)markTheMessageWithMessageId:(NSInteger)messageId
{
    __weak typeof(self) weakSelf=self;
    NSString *url = [NSString stringWithFormat:@"%@v3/live/%@/%@",Baseurl,[NSString stringWithFormat:@"%ld",_liveId],[NSString stringWithFormat:@"%ld",messageId]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *yzuid = [defaults objectForKey:@"userUID"];
    NSString *yztoken = [defaults objectForKey:@"userToken"];
    NSDictionary *dic;
    dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:yzuid,yztoken,randomStr,nil] forKeys:[NSArray arrayWithObjects:@"uid",@"token",@"random",nil]];
    
    [[HttpManager ShareInstance] AFNetPOSTNobodySupport:url Parameters:dic SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res==0) {
            randomStr=SuiJiShu;
            YiZhenLog(@"success");
        }
        else
        {
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:weakSelf];
            randomStr=SuiJiShu;
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error){
        YiZhenLog(@"%@",error);
        randomStr=SuiJiShu;
    }];
}

#pragma mark-mj刷新的代理
-(void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    timer.fireDate=[NSDate distantFuture];
    if (refreshView==_header) {
        [self setUpDataWithMessageId:firstMessageId andNext:NO];
    }
    else if (refreshView==_footer)
    {
        [self syncTheLiveData];
        timer.fireDate=[NSDate distantPast];
    }
}

- (BOOL)checkTime:(NSString*)time ToAfterTime:(NSString*)afterTime
{
    long presentTime = [time longLongValue] /1000;
    
    long lastTime=[afterTime longLongValue] /1000;
    
    
    if (lastTime-presentTime>60*5) {
        return YES;
    }
    return NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_header||_footer) {
        [_header removeFromSuperview];
        [_footer removeFromSuperview];
    }
    if (timer.isValid) {
        [timer invalidate];
    }
    timer=nil;
    [[UUAVAudioPlayer sharedInstance] stopSound];
    //关闭红外
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];}

@end
