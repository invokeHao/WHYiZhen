//
//  informationTableViewCell.h
//  Yizhenapp
//
//  Created by augbase on 16/5/9.
//  Copyright © 2016年 wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "informationModel.h"

@interface informationTableViewCell : UITableViewCell
@property (strong,nonatomic)UILabel*titleLabel;
@property (strong,nonatomic)UIImageView*iconView;
@property (strong,nonatomic)UILabel*moduleLabel;
@property (strong,nonatomic)UILabel*timeLabel;
@property (strong,nonatomic)informationModel*model;

-(void)setModel:(informationModel *)model;

@end
