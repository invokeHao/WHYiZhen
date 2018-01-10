//
//  pointsHistroyTableViewCell.m
//  Yizhenapp
//
//  Created by augbase on 16/5/9.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "pointsHistroyTableViewCell.h"

@implementation pointsHistroyTableViewCell

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
    _timeLabel=[[UILabel alloc]init];
    _timeLabel.font=YiZhenFont;
    [self.contentView addSubview:_timeLabel];
    
    _nameLabel=[[UILabel alloc]init];
    _nameLabel.font=YiZhenFont;
    [self.contentView addSubview:_nameLabel];
    
    _scoreLabel=[[UILabel alloc]init];
    _scoreLabel.font=YiZhenFont;
    [self.contentView addSubview:_scoreLabel];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.centerY.mas_equalTo(self);
    }];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_timeLabel.mas_right).with.offset(5);
        make.centerY.mas_equalTo(self);
    }];
    [_scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-15);
        make.centerY.mas_equalTo(self);
    }];
}

-(void)setModel:(histroyModel *)model
{
    _model=model;
    _timeLabel.text=[_model create_time];
   // NSLog(@"日期%@",_timeLabel.text);
    _nameLabel.text=_model.desc;
    if (_model.score>0) {
        _scoreLabel.text=[NSString stringWithFormat:@"+%d",_model.score];
       // NSLog(@"大于0的%@",_scoreLabel.text);
        _scoreLabel.textColor=themeColor;
    }
        else if (_model.score<0)
    {
        _scoreLabel.text=[NSString stringWithFormat:@"%d",_model.score];
        _scoreLabel.textColor=[UIColor redColor];
    }
        
}

@end
