//
//  pointsHistroyTableViewCell.h
//  Yizhenapp
//
//  Created by augbase on 16/5/9.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "histroyModel.h"
#import <UIKit/UIKit.h>

@interface pointsHistroyTableViewCell : UITableViewCell

@property (strong,nonatomic)UILabel*timeLabel;
@property (strong,nonatomic)UILabel*nameLabel;
@property (strong,nonatomic)UILabel*scoreLabel;
@property (strong,nonatomic)histroyModel*model;

-(void)setModel:(histroyModel *)model;
@end
