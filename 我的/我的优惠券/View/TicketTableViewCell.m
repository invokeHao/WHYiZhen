//
//  TicketTableViewCell.m
//  Yizhenapp
//
//  Created by 王浩 on 16/11/9.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "TicketTableViewCell.h"
#import "dashLineView.h"

@implementation TicketTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}

-(void)createUI
{
    self.backgroundColor=grayBackgroundLightColor;
    _backImageView=[[UIImageView alloc]init];
    UIImage * backImage=[[UIImage imageNamed:@"vouchers_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(75, 15, 10, 10)];
    _backImageView.userInteractionEnabled=YES;
    [_backImageView setImage:backImage];
    [self.contentView addSubview:_backImageView];
    
    _ticketTitleLabel=[[UILabel alloc]init];
    _ticketTitleLabel.font=YiZhenFont;
    _ticketTitleLabel.textColor=[UIColor blackColor];
    [_backImageView addSubview:_ticketTitleLabel];
    
    UILabel * amountLabel=[[UILabel alloc]init];
    amountLabel.font=[UIFont fontWithName:@"PingFangSC-Light" size:12.0];
    amountLabel.textColor=[UIColor blackColor];
    amountLabel.text=@"每场限用1张代金券";
    [_backImageView addSubview:amountLabel];
    
    UILabel * symbolLabel=[[UILabel alloc]init];
    symbolLabel.font=YiZhenFont12;
    symbolLabel.textColor=[UIColor blackColor];
    symbolLabel.text=@"¥";
    [_backImageView addSubview:symbolLabel];
    
    _priceTitleLabel=[[UILabel alloc]init];
    _priceTitleLabel.font=[UIFont systemFontOfSize:48.0];
    _priceTitleLabel.textColor=themeColor;

    [_backImageView addSubview:_priceTitleLabel];
    
    _lastTimeLabel=[[UILabel alloc]init];
    _lastTimeLabel.font=YiZhenFont12;
    _lastTimeLabel.textColor=grayLabelColor;
    [_backImageView addSubview:_lastTimeLabel];
    
    _ruleBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [_ruleBtn setTitle:@"使用规则" forState:UIControlStateNormal];
    [_ruleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_ruleBtn.titleLabel setFont:YiZhenFont12];
    [_ruleBtn addTarget:self action:@selector(pressTheRuleBtn) forControlEvents:UIControlEventTouchUpInside];
    [_backImageView addSubview:_ruleBtn];
    
    UIImageView * goinView=[[UIImageView alloc]init];
    [goinView setImage:[UIImage imageNamed:@"goin"]];
    [_backImageView addSubview:goinView];
    
    //开始布局
    [_backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(@0);
        make.left.equalTo(@15);
        make.right.equalTo(@-15);
    }];
    
    [_ticketTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@12);
        make.left.equalTo(@10);
        make.height.equalTo(@18);
    }];
    
    [amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_ticketTitleLabel.mas_bottom).with.offset(5);
        make.left.equalTo(@10);
        make.height.equalTo(@14);
    }];
    
    [_priceTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@7);
        make.right.equalTo(@-10);
        make.height.equalTo(@50);
    }];
    
    [symbolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_priceTitleLabel.mas_left).with.offset(-7.5);
        make.top.equalTo(@34);
        make.height.equalTo(@16);
    }];
    
    [_lastTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.bottom.equalTo(@-8);
        make.height.equalTo(@16);
    }];
    
    [goinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-10);
        make.bottom.equalTo(@-11);
        make.size.mas_equalTo(CGSizeMake(4, 8));
    }];
    
    [_ruleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(goinView.mas_left).with.offset(-6);
        make.bottom.equalTo(@-8);
        make.size.mas_equalTo(CGSizeMake(52, 16));
    }];
    
    //虚线
    dashLineView *line=[[dashLineView alloc]init];
    line.backgroundColor=[UIColor clearColor];
    [_backImageView addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@13);
        make.top.equalTo(@63);
        make.right.equalTo(@-13);
        make.height.equalTo(@0.5);
    }];
}
-(void)setModle:(TicketModel *)modle
{
    _modle=modle;
    _ticketTitleLabel.text=_modle.name;

    NSInteger price=modle.price;
    if (price<100) {
        int a= price%100;
        _priceTitleLabel.text=[NSString stringWithFormat:@"0.%.2d",a];
    }
    else
    {
        int b=(int)price/100;
        _priceTitleLabel.text=[NSString stringWithFormat:@"%d",b];
    }
    _lastTimeLabel.text=[NSString stringWithFormat:@"有效期至%@",[modle create_time:modle.endTime]];
    
}


-(void)pressTheRuleBtn
{
    _ruleB(_modle.ruleLink);
}

-(void)setFrame:(CGRect)frame
{
    frame.origin.y +=10;
    frame.size.height -=10;
    [super setFrame:frame];
}


@end
