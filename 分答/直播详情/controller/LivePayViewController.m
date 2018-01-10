//
//  LivePayViewController.m
//  Yizhenapp
//  Created by 王浩 on 16/11/8.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "LivePayViewController.h"
#import "LiveViewController.h"
#import "couponsListViewController.h"

#import "PayDetailModel.h"
#import "WXpayModel.h"

@interface LivePayViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
    UILabel * titlelabel;
    UILabel * liveLabel;
    UILabel * attendsLabel;
    UILabel * usingTicket;
    UILabel * priceLabel;
    
    NSInteger couponId;//couponId 优惠券Id
    
    UIView * PayView;//最后的结算view
    
    NSString * randomStr;
}
@property (strong,nonatomic)UITableView * MainTable;
@property (strong,nonatomic)PayDetailModel * payModel;//支付详情Model

@end

@implementation LivePayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    couponId=-100;
    
    NSNotificationCenter*center=[NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(gotoTheLiveView) name:KWXPaySuccess object:nil];
    [self createUI];
    [self setupdata];
}

-(void)createUI
{
    [self createTableView];
    [self createPayView];
}

-(void)createTableView
{
    _MainTable=[[UITableView alloc]init];
    __weak id weakSlef=self;
    _MainTable.delegate=weakSlef;
    _MainTable.dataSource=weakSlef;
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
        make.left.right.top.equalTo(@0);
        make.bottom.equalTo(@-49);
    }];
}

-(void)createPayView
{
    PayView=[[UIView alloc]initWithFrame:CGRectMake(0, ViewHeight-64-49, ViewWidth, 49)];
    PayView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:PayView];
    
    UILabel * leftlabel=[[UILabel alloc]init];
    leftlabel.font=YiZhenFont;
    leftlabel.textColor=[UIColor blackColor];
    leftlabel.text=@"还需支付";
    [PayView addSubview:leftlabel];
    
    UILabel * symbolLable=[[UILabel alloc]init];
    symbolLable.font=[UIFont systemFontOfSize:13.0];
    symbolLable.textColor=[UIColor blackColor];
    symbolLable.text=@"¥";
    [PayView addSubview:symbolLable];
    
    priceLabel=[[UILabel alloc]init];
    priceLabel.font=[UIFont systemFontOfSize:22.0];
    priceLabel.textColor=themeColor;
    
    [PayView addSubview:priceLabel];
    
    UIButton * payBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    payBtn.backgroundColor=themeColor;
    [payBtn setTitle:@"支付" forState:UIControlStateNormal];
    [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [payBtn.titleLabel setFont:YiZhenFont16];
    [payBtn addTarget:self action:@selector(getTheOrder) forControlEvents:UIControlEventTouchUpInside];
    [PayView addSubview:payBtn];
    //布局
    [leftlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.centerY.mas_equalTo(PayView);
        make.height.equalTo(@22);
    }];
    [symbolLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftlabel.mas_right).with.offset(3.5);
        make.top.equalTo(@19);
        make.height.equalTo(@16);
    }];
    
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(symbolLable.mas_right).with.offset(3.5);
        make.centerY.mas_equalTo(PayView);
        make.height.equalTo(@26);
    }];
    [payBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.top.equalTo(@0);
        make.width.equalTo(@100);
    }];
}

#pragma mark-tableView的代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 2;
    }
    else if (section==1)
    {
        return 2;
    }
    else
    {
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section==3) {
        return 0;
    }
    else
    {
        return 15;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            CGFloat H=[self textHeightWithText:_payModel.liveName andMagin:2*15 andRegularFont:16.0];
            return H+15+9+40+10;
        }
        else{
            return 50;
        }
    }
    else if (indexPath.section==1){
        if(indexPath.row==0){
            return 40;
        }
        else{
            return 50;
        }
    }
    else if(indexPath.section==2){
        return 50;
    }
    
    else{
        CGFloat textH=[self textHeightWithAtrributedText:_payModel.liveIntro andMagin:30 andFont:14.0];
        
        return textH+10+10+15+20;
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView*footView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 15)];
    footView.backgroundColor=grayBackgroundLightColor;
    return footView;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"answerCell"];
    cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"answerCell"];
    if (indexPath.section==0) {
        cell.selectionStyle=UITableViewCellSelectionStyleNone;

        if (indexPath.row==0) {
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

            if (_payModel.liveId>0) {
                titlelabel.text=_payModel.liveName;
                liveLabel.text=[NSString stringWithFormat:@"直播时间：%@",[_payModel create_time:_payModel.liveStartTime]];
                attendsLabel.text=[NSString stringWithFormat:@"%ld人参与",_payModel.liveAttends];
            }
        }
        else{
            //价格的label
            UILabel * priceLable=[[UILabel alloc]init];
            priceLable.font=[UIFont systemFontOfSize:22.0];
            priceLable.textColor=themeColor;
            [cell.contentView addSubview:priceLable];
            
            UILabel * symbolLable=[[UILabel alloc]init];
            symbolLable.text=@"¥";
            symbolLable.font=[UIFont systemFontOfSize:13.0];
            symbolLable.textColor=[UIColor blackColor];
            [cell.contentView addSubview:symbolLable];

            [symbolLable mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@17);
                make.top.equalTo(@19);
                make.height.equalTo(@18);
            }];
            [priceLable mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(symbolLable.mas_right).with.offset(2);
                make.height.equalTo(@30);
                make.centerY.mas_equalTo(cell);
            }];
            NSInteger price=_payModel.goodPrice;
            if (price<100) {
                int a= price%100;
                priceLable.text=[NSString stringWithFormat:@"0.%.2d",a];
            }
            else
            {
                int a=price%100;
                int b=(int)price/100;
                priceLable.text=[NSString stringWithFormat:@"%d.%.2d",b,a];
            }
        }
    }
    else if (indexPath.section==1)
    {
        cell.selectionStyle=UITableViewCellSelectionStyleNone;

        if (indexPath.row==0) {
            //支付方式
            UILabel * payTitleLabel=[[UILabel alloc]init];
            payTitleLabel.font=YiZhenFont13;
            payTitleLabel.textColor=grayLabelColor;
            payTitleLabel.text=@"支付方式";
            [cell.contentView addSubview:payTitleLabel];
            
            [payTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@15);
                make.centerY.mas_equalTo(cell);
                make.height.equalTo(@20);
            }];
        }
        else{
            //微信钱包
            UIImageView * WXIcon=[[UIImageView alloc]init];
            [WXIcon setImage:[UIImage imageNamed:@"wechat_vallet"]];
            [WXIcon setContentMode:UIViewContentModeScaleAspectFit];
            [cell.contentView addSubview:WXIcon];
            
            //微信钱包
            UILabel * WXlabel=[[UILabel alloc]init];
            WXlabel.font=YiZhenFont;
            WXlabel.textColor=[UIColor blackColor];
            WXlabel.text=@"微信钱包";
            [cell.contentView addSubview:WXlabel];
            //对勾
            UIImageView * selectedView=[[UIImageView alloc]init];
            [selectedView setImage:[UIImage imageNamed:@"help_solve"]];
            [selectedView setContentMode:UIViewContentModeScaleAspectFit];
            [cell.contentView addSubview:selectedView];
            
            [WXIcon mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@15);
                make.size.mas_equalTo(CGSizeMake(22, 22));
                make.centerY.mas_equalTo(cell);
            }];
            [WXlabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(WXIcon.mas_right).with.offset(5);
                make.centerY.mas_equalTo(cell);
                make.height.equalTo(@22);
            }];
            [selectedView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(@-15);
                make.centerY.mas_equalTo(cell);
                make.size.mas_equalTo(CGSizeMake(22, 22));
            }];
        }
    }
    else if (indexPath.section==2)
    {
        UIImageView * ticketIcon=[[UIImageView alloc]init];
        [ticketIcon setImage:[UIImage imageNamed:@"vouchers"]];
        [ticketIcon setContentMode:UIViewContentModeScaleAspectFit];
        [cell.contentView addSubview:ticketIcon];
        
        UILabel * ticketLabel=[[UILabel alloc]init];
        ticketLabel.font=YiZhenFont;
        ticketLabel.textColor=[UIColor blackColor];
        ticketLabel.text=@"优惠券";
        [cell.contentView addSubview:ticketLabel];
        
        usingTicket=[[UILabel alloc]init];
        usingTicket.font=YiZhenFont;
        usingTicket.textColor=themeColor;
        [cell.contentView addSubview:usingTicket];
        
        UIImageView * moreView=[[UIImageView alloc]init];
        [moreView setContentMode:UIViewContentModeScaleAspectFit];
        [moreView setImage:[UIImage imageNamed:@"goin"]];
        [cell.contentView addSubview:moreView];
        
        [ticketIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15);
            make.size.mas_equalTo(CGSizeMake(22, 22));
            make.centerY.mas_equalTo(cell);
        }];
        
        [ticketLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ticketIcon.mas_right).with.offset(5);
            make.centerY.mas_equalTo(cell);
            make.height.equalTo(@22);
        }];
        
        [moreView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@-15);
            make.centerY.mas_equalTo(cell);
            make.size.mas_equalTo(CGSizeMake(8, 16));
        }];
        [usingTicket mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(moreView.mas_left).with.offset(-6);
            make.centerY.mas_equalTo(cell);
            make.height.equalTo(@22);
        }];
        NSInteger price=_payModel.goodPrice-_payModel.realPrice;
        NSString * priceStr;
        if (price<100) {
            int a= price%100;
            priceStr=[NSString stringWithFormat:@"0.%.2d",a];
        }
        else
        {
            int a=price%100;
            int b=(int)price/100;
            priceStr=[NSString stringWithFormat:@"%d.%.2d",b,a];
        }
        usingTicket.text=[NSString stringWithFormat:@"可用%@元代金券",priceStr];
        if (price==0) {
            usingTicket.text=@"";
        }
    }
    else
    {
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;

        UILabel*Jlable=[[UILabel alloc]init];
        Jlable.font=[UIFont systemFontOfSize:15.0];
        Jlable.textColor=[UIColor blackColor];
        [cell.contentView addSubview:Jlable];
        
        UILabel*introLabel=[[UILabel alloc]init];
        introLabel.font=YiZhenFont13;
        introLabel.textColor=[UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
        introLabel.numberOfLines=0;
        [cell.contentView addSubview:introLabel];
        
        [Jlable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(@15);
            make.height.equalTo(@16);
        }];
        
        [introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15);
            make.right.equalTo(@-15);
            make.top.mas_equalTo(Jlable.mas_bottom).with.offset(10);
        }];
        if (_payModel.liveId>0) {
            Jlable.text=@"直播简介";
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = 4;// 字体的行间距
            
            NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"PingFangSC-Light" size:14.0],NSParagraphStyleAttributeName:paragraphStyle,};
            introLabel.attributedText = [[NSAttributedString alloc] initWithString:_payModel.liveIntro attributes:attributes];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==2) {
        couponsListViewController *couponListVC=[[couponsListViewController alloc]init];
        couponListVC.liveId=_payModel.liveId;
        couponListVC.checkId=couponId;
        __weak typeof(self) weakSelf=self;
        [couponListVC setCouBlock:^(NSInteger couId) {
            couponId=couId;
            [weakSelf setupdata];
        }];
        [self.navigationController pushViewController:couponListVC animated:YES];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title=@"支付";
    randomStr=SuiJiShu;

}

#pragma mark-数据获取

-(void)setupdata
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url;
    url= [NSString stringWithFormat:@"%@v3/live/%@/order?uid=%@&token=%@",Baseurl,[NSString stringWithFormat:@"%ld",_liveId],[user objectForKey:@"userUID"],[user objectForKey:@"userToken"]];
    if (couponId>0||couponId==0) {
        url= [NSString stringWithFormat:@"%@v3/live/%@/order?uid=%@&token=%@&&couponId=%@",Baseurl,[NSString stringWithFormat:@"%ld",_liveId],[user objectForKey:@"userUID"],[user objectForKey:@"userToken"],[NSString stringWithFormat:@"%ld",couponId]];
    }
    YiZhenLog(@"支付详情====%@",url);
    
    //获取病例界面的各种信息
    [[HttpManager ShareInstance]AFNetGETSupport:url Parameters:nil SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        if (res == 0) {
            _payModel=[[PayDetailModel alloc]initWithDictionary:[source objectForKey:@"data"]];
            couponId=_payModel.couponId;
            [_MainTable reloadData];
            
            NSInteger price=_payModel.realPrice;
            if (price<100) {
                int a= price%100;
                priceLabel.text=[NSString stringWithFormat:@"0.%.2d",a];
            }
            else
            {
                int a=price%100;
                int b=(int)price/100;
                priceLabel.text=[NSString stringWithFormat:@"%d.%.2d",b,a];
            }

        }
        else
        {
            __weak typeof(self) weakSelf=self;
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:weakSelf];
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        YiZhenLog(@"%@",error);
    }];
}

#pragma mark-进入到直播界面
-(void)gotoTheLiveView
{
    LiveViewController*liveViewVC=[[LiveViewController alloc]init];
    liveViewVC.liveId=_payModel.liveId;
    liveViewVC.ThemeTitle=_payModel.liveName;
    [self.navigationController pushViewController:liveViewVC animated:YES];
}

#pragma mark-拉取订单
-(void)getTheOrder
{
    __weak typeof(self) weakSelf=self;
    randomStr=SuiJiShu;
    [[SetupView ShareInstance]showImageHUD:self];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@v3/live/%@/order",Baseurl,[NSString stringWithFormat:@"%ld",_payModel.liveId]];
    YiZhenLog(@"拉起订单prepareId====%@",url);
    NSString *yzuid = [user objectForKey:@"userUID"];
    NSString *yztoken = [user objectForKey:@"userToken"];
    NSString *couponIdStr=[NSString stringWithFormat:@"%ld",couponId];
    
    NSDictionary*dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:yzuid,yztoken,couponIdStr,randomStr,nil] forKeys:[NSArray arrayWithObjects:@"uid",@"token",@"couponId",@"random",nil]];
    
    [[HttpManager ShareInstance] AFNetPOSTNobodySupport:url Parameters:dic SucessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *source = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        int res=[[source objectForKey:@"res"] intValue];
        NSDictionary*dic=[source objectForKey:@"data"];
        if (res==0) {
            [[SetupView ShareInstance]hideHUD];
            WXpayModel *payModel=[[WXpayModel alloc]initWithDictionary:dic];
            NSLog(@"dic==%@",dic);
            //如果0元直接进入直播
            if (payModel.skipPayment) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付结果" message:@"已经支付成功" delegate:weakSelf cancelButtonTitle:NSLocalizedString(@"前往直播", @"") otherButtonTitles:nil, nil];
                alert.tag=8888;
                [alert show];
            }
            else{
                [weakSelf goToTheWXPayWithThePayModel:payModel];
            }
            YiZhenLog(@"success");
        }
        else if (res==9011){
            [[SetupView ShareInstance]showTextHUD:self Title:@"支付出现异常，请重试"];
        }
        else
        {
            [[SetupView ShareInstance]hideHUD];
            [[SetupView ShareInstance]showAlertView:res Hud:nil ViewController:weakSelf];
            randomStr=SuiJiShu;
        }
    } FailedBlock:^(AFHTTPRequestOperation *operation, NSError *error){
        YiZhenLog(@"%@",error);
        randomStr=SuiJiShu;
    }];
}

#pragma mark-生成订单
-(void)goToTheWXPayWithThePayModel:(WXpayModel*)payModel
{
    //    @property (nonatomic, retain) NSString *partnerId;
    //    /** 预支付订单 */
    //    @property (nonatomic, retain) NSString *prepayId;
    //    /** 随机串，防重发 */
    //    @property (nonatomic, retain) NSString *nonceStr;
    //    /** 时间戳，防重发 */
    //    @property (nonatomic, assign) UInt32 timeStamp;
    //    /** 商家根据财付通文档填写的数据和签名 */
    //    @property (nonatomic, retain) NSString *package;
    //    /** 商家根据微信开放平台文档对数据做的签名 */
    //    @property (nonatomic, retain) NSString *sign;
    
    //调起支付
    PayReq*request=[[PayReq alloc]init];
    request.partnerId=payModel.wx_partnerid;
    request.prepayId=payModel.wx_prepayid; /** 预支付订单 */
    request.nonceStr=payModel.wx_noncestr;/** 随机串，防重发 */
    request.timeStamp=[payModel.wx_timestamp intValue];/** 时间戳，防重发 */
    NSString* string1=payModel.wx_package;
    NSString* str=[string1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    request.package=str;/** 商家根据财付通文档填写的数据和签名(暂时写死) */
        
    request.sign=payModel.wx_sign;/** 商家根据微信开放平台文档对数据做的签名 */
    [WXApi sendReq:request];
    
}

#pragma mark-AlterView的代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==8888) {
        if (buttonIndex==0) {
            NSNotificationCenter*center=[NSNotificationCenter defaultCenter];
            [center postNotificationName:KWXPaySuccess object:nil];
        }
    }
}

#pragma mark-返回32位随机数
-(NSString *)ret32bitString
{
    char data[32];
    for (int x=0; x<32; x++) {
        int i=arc4random()%3;
        switch (i) {
            case 0:
                data[x]=(char)('1' + (arc4random_uniform(9)));
                break;
            case 1:
                data[x]=(char)('A' + (arc4random_uniform(26)));
                break;
            case 2:
                data[x]=(char)('a' + (arc4random_uniform(26)));
                break;
            default:
                break;
        }
    }
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
}

-(NSString*)getTimeSpNow
{
    NSDate*sendDate=[NSDate date];
    //    NSLog(@"date时间戳 = %@",sendDate);
    NSString *date2 = [NSString stringWithFormat:@"%ld", (long)[sendDate timeIntervalSince1970]];
    
    NSLog(@"date2时间戳 = %@",date2);
    
    return date2;
}

#pragma mark-MD5加密
-(NSString *)md5HexDigest:(NSString *)input
{
    const char* str = [input UTF8String];
    unsigned char result[16];
    CC_MD5( str, (CC_LONG)strlen(str), result );
    return [[NSString stringWithFormat:
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] uppercaseString];
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
