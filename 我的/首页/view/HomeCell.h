//
//  HomeCell.h
//  Yizhenapp
//
//  Created by augbase on 16/5/4.
//  Copyright © 2016年 wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "homeModel.h"

@interface HomeCell : UITableViewCell

@property (strong,nonatomic)UIImageView*iconView;
@property (strong,nonatomic)UILabel *tiltleLabel;
@property (strong,nonatomic)UILabel *countLabel;
@property (strong,nonatomic)UIView *moreView;//右箭头的view
@property (strong,nonatomic)homeModel*HModel;

-(void)setHModel:(homeModel *)HModel;
@end
