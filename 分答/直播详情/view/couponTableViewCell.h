//
//  couponTableViewCell.h
//  Yizhenapp
//
//  Created by 王浩 on 16/11/10.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TicketModel.h"

typedef void(^selectBlock)(NSInteger cellId);
typedef void(^RuleBlock)(NSString * ruleUrl);

@interface couponTableViewCell : UITableViewCell

@property (strong,nonatomic)UIView * selectedView;//选中的背景view
@property (strong,nonatomic)UIImageView * backImageView;//票券背景
@property (strong,nonatomic)UILabel * ticketTitleLabel;//优惠券title
@property (strong,nonatomic)UILabel * priceTitleLabel;//金额
@property (strong,nonatomic)UILabel * lastTimeLabel;//有效期
@property (strong,nonatomic)UIButton * ruleBtn;//使用规则btn

@property (assign,nonatomic)NSInteger cellId;//cell的id

@property(strong,nonatomic)TicketModel * modle;

@property (strong,nonatomic)selectBlock selectB;

@property (strong,nonatomic)RuleBlock RuleB;

-(void)setModle:(TicketModel *)modle;

-(void)setSelectB:(selectBlock)selectB;

-(void)setRuleB:(RuleBlock)RuleB;

@end
