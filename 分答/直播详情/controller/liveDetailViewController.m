//
//  liveDetailViewController.m
//  Yizhenapp
//
//  Created by augbase on 16/9/1.
//  Copyright © 2016年 Augbase. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import "liveDetailViewController.h"
#import "WangWebViewController.h"
#import "LivePayViewController.h"
#import "WXApi.h"
#import "liveDiscussViewController.h"
#import "LiveViewController.h"
#import "linkBtn.h"
#import "shareObject.h"

@interface liveDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>
{
    UILabel*titlelabel;//cell上的控件
    UILabel*liveLabel;
    UILabel*attendsLabel;
    UILabel*docLabel;
    UIImageView*iconImage;
    UILabel*docIntrolabel;
    UIButton*joinButton;
    UIButton*Qbutton;
    UILabel*Jlable;
    UILabel*introLabel;
    
    //动画相关view
    NSString *randomStr;
    UIView *shadowView;//阴影View
    UIView * shareView;//分享View
    UIView * visualEffectView;//遮盖view
    
    //支付orderView
    UIView * orderView;
    //直播结束后的弹出自定义提示框
    UIView * actionSheetView;
    
    shareObject * shareModel;//分享的model
    
}
@property (strong,nonatomic)UITableView * MainTable;
@property (strong,nonatomic)NSMutableArray * dataArray;
@property (strong,nonatomic)UITextField *ticketText;


@end

@implementation liveDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
}

-(void)creatUI
{
    NSNotificationCenter*center=[NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(setUpData) name:KWXPaySuccess object:nil];
    self.view.backgroundColor=[UIColor whiteColor];
    [self creatTableView];
}

-(void)creatTableView
{
    _MainTable=[[UITableView alloc]init];
    __weak id wealSelf=self;
    _MainTable.delegate=wealSelf;
    _MainTable.dataSource=wealSelf;
    _MainTable.layer.borderColor=lightGrayBackColor.CGColor;
    _MainTable.layer.borderWidth=0.5;
    _MainTable.showsVerticalScrollIndicator=NO;
    _MainTable.separatorStyle=UITableViewCellSeparatorStyleNone;
    _MainTable.backgroundColor=grayBackgroundLightColor;
    _MainTable.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    _MainTable.separatorColor=lightGrayBackColor;
    _MainTable.separatorInset = UIEdgeInsetsMake(0,15, 0, 15);
    _MainTable.sectionFooterHeight = 15;
    //去除多余的分割线
    UIView*footView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 15)];
    footView.backgroundColor=grayBackgroundLightColor;
    _MainTable.tableFooterView = footView;

    [self.view addSubview:_MainTable];
    [_MainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(@0);
    }];
}

-(void)addKVO
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

//创建actioinSheet
-(void)setupActionSheetWithTitle:(NSString *)title
{
    __weak id weakSelf=self;
    UIActionSheet*actionS=[[UIActionSheet alloc]initWithTitle:title delegate:weakSelf cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"前往", nil];

    [actionS showInView:self.view];
    
}
-(void)createTapView
{
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    
    [self.navigationController.view addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    
    [self.navigationController.view addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    
    [self.navigationController.view addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    
    [self.navigationController.view addGestureRecognizer:recognizer];
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer*)swip
{
    [_ticketText resignFirstResponder];
}


//关闭checkView
-(void)closeTheCheckView
{
    [shadowView removeFromSuperview];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUpData];
    randomStr=SuiJiShu;
    self.navigationItem.title = NSLocalizedString(@"直播详情", @"");
    
    UIButton*moreButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage imageNamed:@"topic_set"] forState:UIControlStateNormal];
    [moreButton setFrame:CGRectMake(0, 0, 22, 22)];
    [moreButton addTarget:self action:@selector(pressToShowMore) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem*reply=[[UIBarButtonItem alloc]initWithCustomView:moreButton];
    [self.navigationItem setRightBarButtonItem:reply];

}

#pragma mark-tabelView的代理方法
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            CGFloat H=[self textHeightWithText:_liveModel.title andMagin:2*15 andRegularFont:16.0];
            return H+15+9+40+10;
        }
        else
        {
            CGFloat textH=[self textHeightWithText:_liveModel.doctorIntro andMagin:93 andFont:14.0];
            if (textH>53) {
                textH=53;
            }
            return textH+15+17+3+15+2.5;
        }
    }
    else if(indexPath.section==1)
    {
        if (indexPath.row==0) {
            return 70;
        }
        else
        {
            return 50;
        }
    }
    else
    {
        CGFloat textH=[self textHeightWithAtrributedText:_liveModel.intro andMagin:30 andFont:14.0];
    
        return textH+10+10+15+20;
    
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 2;
    }
    else if (section==1){
        return 1;
    }
    else
    {
        return 1;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 15)];
    headerView.backgroundColor = grayBackgroundLightColor;
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section==2) {
        return 0;
    }
    else
    {
        return 8;
    }
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"answerCell"];
    cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"answerCell"];
    //标题lable
    titlelabel=[[UILabel alloc]init];
    titlelabel.font=[UIFont boldSystemFontOfSize:16.0];
    titlelabel.textColor=[UIColor blackColor];
    titlelabel.numberOfLines=0;
    [cell.contentView addSubview:titlelabel];
    
    //live label
    liveLabel=[[UILabel alloc]init];
    liveLabel.font=YiZhenFont13;
    liveLabel.textColor=grayLabelColor;
    
    [cell.contentView addSubview:liveLabel];
    //attends label
    attendsLabel=[[UILabel alloc]init];
    attendsLabel.font=YiZhenFont13;
    attendsLabel.textColor=grayLabelColor;
    [cell.contentView addSubview:attendsLabel];
    
    //讲者label
    docLabel=[[UILabel alloc]init];
    docLabel.font=YiZhenFont14;
    docLabel.textColor=[UIColor blackColor];
    [cell.contentView addSubview:docLabel];
    
    //医生icon
    iconImage=[[UIImageView alloc]init];
    iconImage.contentMode=UIViewContentModeScaleAspectFit;
    iconImage.layer.cornerRadius=24;
    iconImage.layer.masksToBounds=YES;
    [cell.contentView addSubview:iconImage];
    //医生简介
    docIntrolabel=[[UILabel alloc]init];
    docIntrolabel.font=YiZhenFont13;
    docIntrolabel.textColor=grayLabelColor;
    docIntrolabel.numberOfLines=3;
    [cell.contentView addSubview:docIntrolabel];
    
    joinButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    joinButton.layer.cornerRadius=5;
    joinButton.layer.masksToBounds=YES;
    joinButton.titleLabel.font=[UIFont systemFontOfSize:16.0];
    joinButton.titleLabel.textAlignment=NSTextAlignmentCenter;
    [joinButton addTarget:self action:@selector(pressToJoinTheLive) forControlEvents:UIControlEventTouchUpInside];
    
    //创建入场券button
    Qbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    [Qbutton setTitleColor:themeColor forState:UIControlStateNormal];
    Qbutton.titleLabel.font=[UIFont systemFontOfSize:15.0];
    [Qbutton setBackgroundColor:[UIColor whiteColor]];
    [Qbutton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [Qbutton addTarget:self action:@selector(pressCheckToJoin) forControlEvents:UIControlEventTouchUpInside];
    
    Jlable=[[UILabel alloc]init];
    Jlable.font=[UIFont systemFontOfSize:15.0];
    Jlable.textColor=[UIColor blackColor];
    [cell.contentView addSubview:Jlable];
    introLabel=[[UILabel alloc]init];
    introLabel.font=YiZhenFont13;
    introLabel.textColor=[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
    introLabel.numberOfLines=0;
    [cell.contentView addSubview:introLabel];
    
    if (indexPath.section==0) {
        
        if (indexPath.row==0) {
            
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            if (_liveModel.IDS>0) {
                titlelabel.text=_liveModel.title;
                liveLabel.text=[NSString stringWithFormat:@"直播时间：%@",_liveModel.startShowTime];
                attendsLabel.text=[NSString stringWithFormat:@"%ld人参与",_liveModel.attends];
            }
            [titlelabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.equalTo(@15);
                make.right.equalTo(@-15);
            }];
            
            [liveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@15);
                make.top.mas_equalTo(titlelabel.mas_bottom).with.offset(9);
                make.height.equalTo(@20);
            }];
            
            [attendsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@15);
                make.top.mas_equalTo(liveLabel.mas_bottom).with.offset(0);
                make.height.equalTo(@20);
            }];
        }
        else if (indexPath.row==1)
        {
            //更多按钮

            UIImageView *tailImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 8, 15)];
            tailImageView.image = [UIImage imageNamed:@"goin"];
            cell.accessoryView=tailImageView;
            //赋值
            if (_liveModel.IDS>0) {
                [iconImage sd_setImageWithURL:[NSURL URLWithString:_liveModel.doctorAvatar] placeholderImage:[UIImage imageNamed:@"default_avatar3"]];
                docLabel.text=[NSString stringWithFormat:@"讲者：%@",_liveModel.doctorName];
                docIntrolabel.text=_liveModel.doctorIntro;
            }
            
            //开始布局
            [iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@15);
                make.centerY.mas_equalTo(cell);
                make.size.mas_equalTo(CGSizeMake(48, 48));
            }];
            
            [docLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@15);
                make.left.mas_equalTo(iconImage.mas_right).with.offset(10);
                make.height.equalTo(@17);
            }];
            
            [docIntrolabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(docLabel.mas_bottom).with.offset(3);
                make.right.equalTo(@-20);
                make.left.mas_equalTo(docLabel);
            }];
        }
    }
    else if(indexPath.section==1)
    {
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        if (_liveModel.hasAttend) {
            if (_liveModel.IDS>0) {
                joinButton.backgroundColor=themeColor;
                [joinButton setTitle:@"进入直播" forState:UIControlStateNormal];
            }
            if (_hadJoin) {
                joinButton.backgroundColor=darkTitleColor;
                [joinButton setTitle:@"已加入" forState:UIControlStateNormal];
            }
            [cell.contentView addSubview:joinButton];
            [joinButton mas_makeConstraints:^(MASConstraintMaker *make){
                make.left.equalTo(@15);
                make.right.equalTo(@-15);
                make.centerY.mas_equalTo(cell);
                make.height.equalTo(@40);
            }];
        }
        else
        {
            if (indexPath.row==0) {
                //创建参与button
                if (_liveModel.IDS>0) {
                    joinButton.backgroundColor=themeColor;
                    [joinButton setTitle:@"赞助并参与直播" forState:UIControlStateNormal];
                }
                [cell.contentView addSubview:joinButton];
                [joinButton mas_makeConstraints:^(MASConstraintMaker *make){
                    make.left.equalTo(@15);
                    make.right.equalTo(@-15);
                    make.centerY.mas_equalTo(cell);
                    make.height.equalTo(@40);
                }];
            }
        }
    }
    else
    {
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        [Jlable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(@15);
            make.height.equalTo(@16);
        }];

        [introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15);
            make.right.equalTo(@-15);
            make.top.mas_equalTo(Jlable.mas_bottom).with.offset(10);
        }];
        
        if (_liveModel.IDS>0) {
            Jlable.text=@"直播简介";
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 4;// 字体的行间距

            NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"PingFangSC-Light" size:14.0],NSParagraphStyleAttributeName:paragraphStyle,};
            introLabel.attributedText = [[NSAttributedString alloc] initWithString:_liveModel.intro attributes:attributes];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf=self;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {
        if (indexPath.row==1) {
            //跳转到医生的webView
            WangWebViewController*wangWebVC=[[WangWebViewController alloc]init];
            wangWebVC.webType=@"医生详情";
            wangWebVC.url=_liveModel.doctorIntroLink;
            [weakSelf.navigationController pushViewController:wangWebVC animated:YES];
        }
    }
}

-(void)setUpData
{
    if (orderView) {
        [self popHidenView:orderView];
    }
    __weak typeof(self) weakSelf=self;
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@v3/live/%@?uid=%@&token=%@",Baseurl,[NSString stringWithFormat:@"%ld",_IDS],[user objectForKey:@"userUID"],[user objectForKey:@"userToken"]];
    YiZhenLog(@"直播详情====%@",url);
    
    //获取病例界面的各种信息
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
            if (res == 0) {
            _liveModel=[[liveDetailModel alloc]initWithDictionary:[source objectForKey:@"data"]];
            [_MainTable reloadData];
        }
        else
        {
            if(res==102)
            {
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:weakSelf];
            }
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
}


#pragma mark-动态计算label高度

-(CGFloat)textHeightWithText:(NSString*)text andMagin:(CGFloat)magin andRegularFont:(CGFloat)font
{
    // 文字的最大尺寸
    CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - magin, MAXFLOAT);
    // 计算文字的高度
    CGFloat titleH = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:font] } context:nil].size.height;
    return titleH;
}

-(CGFloat)textHeightWithText:(NSString*)text andMagin:(CGFloat)magin andFont:(CGFloat)font
{
    // 文字的最大尺寸
    CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - magin, MAXFLOAT);
    // 计算文字的高度
    
    CGFloat titleH = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont fontWithName:@"PingFangSC-Light" size:font] } context:nil].size.height;

    return titleH;
}

//需要特殊处理的行距
-(CGFloat)textHeightWithAtrributedText:(NSString*)text andMagin:(CGFloat)magin andFont:(CGFloat)font
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4;// 字体的行间距
    // 文字的最大尺寸
    CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - magin, MAXFLOAT);
    // 计算文字的高度
    CGFloat titleH = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont fontWithName:@"PingFangSC-Light" size:font] ,NSParagraphStyleAttributeName:paragraphStyle,} context:nil].size.height;
    return titleH;
}

#pragma mark-掉支付的功能
//点击报名
-(void)pressToJoinTheLive
{
    if (_liveModel.hasAttend) {
        LiveViewController*liveViewVC=[[LiveViewController alloc]init];
        liveViewVC.liveId=_IDS;
        liveViewVC.ThemeTitle=_liveModel.title;
        liveViewVC.hasClosed=_liveModel.hasClosed;
        [self.navigationController pushViewController:liveViewVC animated:YES];
    }
    else
    {
        NSInteger leftQ=_liveModel.totalQ-_liveModel.askedQ;
        
        if ([self liveIsOpen]) {
            if (_liveModel.hasClosed) {
                [self setupActionSheetWithTitle:@"回顾直播精华\n本次直播内容非常精彩，赶紧去听下里面的精彩问答!"];
            }
            //直播中
            else
            {
                NSString * remindStr=[NSString stringWithFormat:@"直播进行中\n本场直播医生总共将回复%ld个带有求助标记的问题，现在还有很多机会",_liveModel.totalQ];
                if (leftQ<1) {
                    //弹出支付的信息
                    remindStr=[NSString stringWithFormat:@"直播进行中\n本场直播医生总共将回复%ld个带有求助标记的问题，已经有很多人提问了，要抓紧机会哟!",_liveModel.totalQ];
                }
                [self setupActionSheetWithTitle:remindStr];
            }
        }
        //直播还未开始
        else if(![self liveIsOpen])
        {
            //弹出支付的信息
            NSString * remindStr=[NSString stringWithFormat:@"直播暂未开始\n本场直播医生总共将回复%ld个带有求助标记的问题，现在还有很多机会",_liveModel.totalQ];
            if (leftQ<1) {
                //弹出支付的信息
                remindStr=[NSString stringWithFormat:@"直播暂未开始\n本场直播医生总共将回复%ld个带有求助标记的问题，已经有很多人提问了，要抓紧机会哟!",_liveModel.totalQ];
            }
            [self setupActionSheetWithTitle:remindStr];
        }
 
    }
    if (_hadJoin) {
        return;
    }
}

#pragma mark- 点击查看用户协议
-(void)pressToSeeTheUserAgreement
{
}

#pragma mark-actionSheet的代理方法

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%ld",buttonIndex);
    if (buttonIndex==0) {
        //跳转支付页
        LivePayViewController * livePayVC=[[LivePayViewController alloc]init];
        livePayVC.liveId=_liveModel.IDS;
        [self.navigationController pushViewController:livePayVC animated:YES];
    }
}

#pragma mark-键盘的监听事件
- (void)keyboardWillChange:(NSNotification *)note
{
    //    NSLog(@"%@", note.userInfo);
    NSDictionary *userInfo = note.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    
    CGRect keyFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGFloat moveY = keyFrame.origin.y - self.view.frame.size.height-64;
    UIView*backView=[self.navigationController.view viewWithTag:8888];
    if (keyFrame.origin.y<ViewHeight) {
        [UIView animateWithDuration:duration animations:^{
            backView.transform=CGAffineTransformMakeTranslation(0, moveY+150);
        }];
    }
    else
    {
        [UIView animateWithDuration:duration animations:^{
            backView.transform=CGAffineTransformMakeTranslation(0, moveY);
        }];
    }
}

-(void)pressToShowMore
{
    [self setupShareView];
    [self popOutShareView:shareView];  
}


#pragma mark-分享微信相关
-(void)setupShareView{
    
    [self getShareUrl];

    shareView = [[UIView alloc]initWithFrame:CGRectMake(0, ViewHeight, ViewWidth, 185)];
    shareView.backgroundColor = grayBackgroundLightColor;
    [self.navigationController.view addSubview:shareView];
    
    UIScrollView *shareScroller = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, shareView.bounds.size.width, 128)];
    shareScroller.contentSize = CGSizeMake(shareView.bounds.size.width, 128);
    [shareView addSubview:shareScroller];
    
    NSArray*imageArray=@[@"wechat3",@"circle_of_friends",@"copy_link"];
    NSArray*titleArray=@[@"微信好友",@"朋友圈",@"复制链接"];
    
    CGFloat margin=(ViewWidth-4*60)/5;
    
    NSInteger k=0;
    for (int i=0; i<1; i++) {
        for (int j=0; j<titleArray.count; j++) {
            UIButton*button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(margin+(60+margin)*j, 19+(70+60)*i, 60, 60)];
            button.tag=600+k;
            button.backgroundColor=[UIColor whiteColor];
            [button setImage:[UIImage imageNamed:imageArray[k]] forState:UIControlStateNormal];
            [button setImageEdgeInsets:UIEdgeInsetsMake(14, 14, 14, 14)];
            button.layer.cornerRadius=10;
            button.layer.masksToBounds=YES;
            [button addTarget:self action:@selector(pressTheShareButton:) forControlEvents:UIControlEventTouchUpInside];
            [shareScroller addSubview:button];
            
            UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(button.frame.origin.x, button.frame.origin.y+button.height+7, button.width, 14)];
            label.text=titleArray[k];
            label.textAlignment=NSTextAlignmentCenter;
            label.font=YiZhenFont12;
            [shareScroller addSubview:label];
            k++;
            if (k>3) {
                break;
            }
        }
    }
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 128, ViewWidth, 0.5)];
    lineView.backgroundColor=grayBackgroundDarkColor;
    [shareScroller addSubview:lineView];
    
    UIButton*cancelBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 128, ViewWidth, 57)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:themeColor forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Light" size:20.0]];
    [cancelBtn setBackgroundColor:[UIColor whiteColor]];
    [cancelBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [cancelBtn addTarget:self action:@selector(cancelShare:) forControlEvents:UIControlEventTouchUpInside];
    [shareView addSubview:cancelBtn];
    
}

-(void)pressTheShareButton:(UIButton*)button
{
    switch (button.tag) {
        case 600:
            [self shareWechatFriend:button];
            break;
        case 601:
            [self shareWechatGroup:button];
            break;
        case 602:
            [self copyTheLink:button];
        default:
            break;
    }
}

#pragma mark-分享到微信好友
-(void)shareWechatFriend:(UIButton*)button
{
    if ([WXApi isWXAppInstalled]&& [WXApi isWXAppSupportApi])
    {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title =shareModel.shareTitle;;
        message.description = shareModel.shareContent;
        [message setThumbImage:[UIImage imageNamed:@"weixinIcon"]];
        
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = shareModel.shareUrl;
        
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = WXSceneSession;//WXSceneTimeline
        
        [WXApi sendReq:req];
        [self popHidenView:shareView];
    }
    else
    {
        [[SetupView ShareInstance]showAlertViewOneButton:NSLocalizedString(@"您不能使用分享功能", @"") Title:NSLocalizedString(@"您没有安装微信", @"") ViewController:self];
    }
}
#pragma mark-分享到微信朋友圈
-(void)shareWechatGroup:(UIButton *)sender{
    
    if ([WXApi isWXAppInstalled]&& [WXApi isWXAppSupportApi]) {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = shareModel.shareTitle;
        message.description = shareModel.shareContent;;
        [message setThumbImage:[UIImage imageNamed:@"weixinIcon"]];
        
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = shareModel.shareUrl;
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = WXSceneTimeline;//
        
        [WXApi sendReq:req];
        [self popHidenView:shareView];
    }
    else
    {
        [[SetupView ShareInstance]showAlertViewOneButton:NSLocalizedString(@"您不能使用分享功能", @"") Title:NSLocalizedString(@"您没有安装微信", @"") ViewController:self];
    }
}

-(void)copyTheLink:(UIButton*)button
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = shareModel.shareUrl;
    [self popHidenView:shareView];
    [[SetupView ShareInstance] showTextHUD:self Title:@"复制成功"];
}

-(void)cancelShare:(UIButton*)button
{
    [self popHidenView:shareView];
}

#pragma mark－获取分享直播的url
-(void)getShareUrl
{
    __weak typeof(self) weakSelf=self;
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@v3/live/%@/share?uid=%@&token=%@&fromRemote=%@",Baseurl,[NSString stringWithFormat:@"%ld",_IDS],[user objectForKey:@"userUID"],[user objectForKey:@"userToken"],@"true"];
    YiZhenLog(@"直播分享的url====%@",url);
    
    //获取病例界面的各种信息
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res == 0) {
            NSDictionary * dic=[source objectForKey:@"data"];
            shareModel=[[shareObject alloc]initWithDictionary:dic];
        }
        else
        {
            if(res==102)
            {
                [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:weakSelf];
            }
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];

}

#pragma mark-底部view出现和隐藏
-(void)popOutShareView:(UIView *)targetView{
    visualEffectView = [[UIView alloc] init];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHidenvisualEffectView:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [visualEffectView addGestureRecognizer:singleTapGestureRecognizer];
    visualEffectView.frame = [UIScreen mainScreen].bounds;
    visualEffectView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    [self.navigationController.view insertSubview:visualEffectView belowSubview:targetView];
    
    POPSpringAnimation *anim = [POPSpringAnimation animation];
    anim.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
    anim.toValue = [NSValue valueWithCGRect:CGRectMake(targetView.frame.origin.x,ViewHeight-targetView.bounds.size.height,targetView.bounds.size.width,targetView.bounds.size.height)];
    if (targetView==orderView) {
       anim.toValue=[NSValue valueWithCGRect:CGRectMake(targetView.frame.origin.x,ViewHeight-targetView.bounds.size.height-10,targetView.bounds.size.width,targetView.bounds.size.height)];
    }
    anim.velocity = [NSValue valueWithCGRect:targetView.frame];
    anim.springBounciness = 5.0;
    anim.springSpeed = 10;
    anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
        }
    };
    
    [targetView pop_addAnimation:anim forKey:@"slider"];
}

-(void)tapHidenvisualEffectView:(UIView *)sender{
    [self popHidenView:shareView];
    [self popHidenView:orderView];
}

-(void)popHidenView:(UIView *)targetView{
    if (visualEffectView != nil) {
        [visualEffectView removeFromSuperview];
    }
    POPSpringAnimation *anim = [POPSpringAnimation animation];
    anim.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
    anim.toValue = [NSValue valueWithCGRect:CGRectMake(0,ViewHeight,targetView.bounds.size.width,targetView.bounds.size.height)];
    anim.velocity = [NSValue valueWithCGRect:targetView.frame];
    anim.springBounciness = 5.0;
    anim.springSpeed = 10;
    
    anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
        }
    };
    [targetView pop_addAnimation:anim forKey:@"slider"];
}

#pragma mark- 判断直播是否开始
-(BOOL)liveIsOpen
{
    NSDate *create = [NSDate dateWithTimeIntervalSince1970:[_liveModel.startTime longLongValue] /1000];
    
    NSDate *date=[NSDate date];
    
    NSInteger interval = [date timeIntervalSince1970];
    NSInteger intervalS=  [create timeIntervalSince1970];
    if (interval-intervalS>=0) {
        return YES;
    }
    else
    {
        return NO;
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationItem.title=@"";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
