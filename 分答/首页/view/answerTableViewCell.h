//
//  answerTableViewCell.h
//  Yizhenapp
//
//  Created by augbase on 16/8/31.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "answerModel.h"
#import "redCircleView.h"

@interface answerTableViewCell : UITableViewCell
{
    UIImageView *liveIcon;//直播的图像
    UILabel * liveLabel;//直播的label
    UIImageView * onLineView;//直播中的icon
}

@property (strong,nonatomic)UIButton *iconButton;//头像icon
@property (strong,nonatomic)UILabel * timesLabel;//期数label
@property (strong,nonatomic)UILabel * statueLabel;//状态label
@property (strong,nonatomic)redCircleView *redPoint;//通知红点
@property (strong,nonatomic)UILabel * themeLabel;//主题Label
@property (strong,nonatomic)UILabel * introduceLabel;//介绍的label
@property (strong,nonatomic)UIView * liveView;//直播状态的view（包含还有几天开始直播，直播中，直播已结束）
@property (strong,nonatomic)UILabel * amountLabel;//有多少人入场
@property (strong,nonatomic)answerModel *model;

-(void)setModel:(answerModel *)model;

@end
