//
//  topicCollectionTableViewCell.h
//  Yizhenapp
//
//  Created by augbase on 16/5/9.
//  Copyright © 2016年 wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "topicModel.h"

typedef void (^TagBlock) (NSInteger tagId);
//暂时没有参数
typedef void (^personBlock) (NSString *iconUrl);

typedef void (^webBlock) (NSString *url);

//求助变迁的block
typedef void (^tagBlock) (NSInteger tagID);

@interface topicCollectionTableViewCell : UITableViewCell

{
    NSString *webUrl;//webView的url
    
}
@property (strong,nonatomic) UILabel *nameLabel;
@property (strong,nonatomic) UILabel *TimeLabel;
@property (strong,nonatomic) UILabel *contentLabel;
@property (strong,nonatomic) UIButton *helpBtn;//求助按钮
@property (strong,nonatomic) UILabel *replayLabel;//回复的label

@property (strong,nonatomic) UIView *lineView;

@property (strong,nonatomic) UIView *tagView;//标签view

@property (strong,nonatomic) UIView*OcrView;
@property (strong,nonatomic) UIButton*iconButton;//头像

@property (strong,nonatomic) NSMutableArray *photoArray;//存放图片的数组
@property (strong,nonatomic) NSMutableArray *photoUrlArray;//存放图片的url

@property (strong,nonatomic) topicModel*model;

//用来查看模块列表的block
@property (strong,nonatomic) TagBlock tagB;
//用来查看个人详情的block
@property (strong,nonatomic) personBlock personB;
//用来查看大表格
@property (strong,nonatomic) webBlock webB;


-(void)setPersonB:(personBlock)personB;

-(void)setTagB:(TagBlock)tagB;

-(void)setWebB:(webBlock)webB;

-(void)setModel:(topicModel *)model;


@end
