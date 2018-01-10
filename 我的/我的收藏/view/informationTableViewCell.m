//
//  informationTableViewCell.m
//  Yizhenapp
//
//  Created by augbase on 16/5/9.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "informationTableViewCell.h"

@implementation informationTableViewCell

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
    _moduleLabel=[[UILabel alloc]init];
    _moduleLabel.font=[UIFont boldSystemFontOfSize:15.0];
    [self.contentView addSubview:_moduleLabel];
    
    _timeLabel=[[UILabel alloc]init];
    _timeLabel.font=YiZhenFont12;
    _timeLabel.textColor=grayLabelColor;
    [self.contentView addSubview:_timeLabel];
    
    _titleLabel=[[UILabel alloc]init];
    _titleLabel.font=YiZhenFont;
    _titleLabel.numberOfLines=0;
    [self.contentView addSubview:_titleLabel];
    
    _iconView=[[UIImageView alloc]init];
    _iconView.contentMode=UIViewContentModeScaleToFill;
    [self.contentView addSubview:_iconView];
    //构建约束
    [_moduleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.top.equalTo(@10);
    }];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-10);
        make.top.mas_equalTo(@10);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.right.mas_equalTo(_iconView.mas_left).with.offset(-10);
        make.centerY.mas_equalTo(self.contentView).with.offset(7);
    }];
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@-12);
        make.right.equalTo(@-10);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
}

-(void)setModel:(informationModel *)model
{
    _model=model;
    _moduleLabel.text=_model.moduleName;
    _timeLabel.text=[_model create_time];
    _titleLabel.text=_model.title;
    [_iconView sd_setImageWithURL:[NSURL URLWithString:_model.picURL] placeholderImage:[UIImage imageNamed:@"yulantu_5"]];
}

//-(void)setFrame:(CGRect)frame
//{
//    frame.origin.y +=10;
//    frame.size.height -=10;
//    [super setFrame:frame];
//}


@end
