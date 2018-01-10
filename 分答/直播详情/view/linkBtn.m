//
//  linkButton.m
//  Yizhenapp
//
//  Created by augbase on 16/9/23.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "linkBtn.h"

@implementation linkBtn

-(void)setLinkName:(NSString *)linkName
{
    _linkName=linkName;
    [self creatSubViews];
}

-(void)creatSubViews
{
    UILabel*nameLabel=[[UILabel alloc]init];
    nameLabel.text=_linkName;
    nameLabel.font=YiZhenFont12;
    nameLabel.textColor=grayLabelColor;
    [self addSubview:nameLabel];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(@0);
        make.bottom.equalTo(@-1);
    }];
    
    UIView*lineView=[[UIView alloc]init];
    lineView.backgroundColor=grayLabelColor;
    [self addSubview:lineView];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.top.mas_equalTo(nameLabel.mas_bottom).with.offset(0.5);
        make.height.equalTo(@0.5);
    }];
}
@end
