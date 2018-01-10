//
//  TicketTableViewCell.h
//  Yizhenapp
//
//  Created by 王浩 on 16/11/9.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TicketModel.h"

typedef void(^RuleBlock)(NSString * ruleLink);

@interface TicketTableViewCell : UITableViewCell

@property (strong,nonatomic)UIImageView * backImageView;
@property (strong,nonatomic)UILabel * ticketTitleLabel;//优惠券title
@property (strong,nonatomic)UILabel * priceTitleLabel;//金额
@property (strong,nonatomic)UILabel * lastTimeLabel;//有效期
@property (strong,nonatomic)UIButton * ruleBtn;//使用规则btn

@property(strong,nonatomic)TicketModel * modle;

@property (strong,nonatomic)RuleBlock ruleB;

-(void)setModle:(TicketModel *)modle;

-(void)setRuleB:(RuleBlock)ruleB;
@end
