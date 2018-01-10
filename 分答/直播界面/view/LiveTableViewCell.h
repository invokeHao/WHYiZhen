//
//  LiveTableViewCell.h
//  Yizhenapp
//
//  Created by augbase on 16/9/5.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "liveCellFrameModel.h"
#import "voiceBtn.h"
#import "redCircleView.h"

typedef void (^voiceBtnBlock) (BOOL hasreaded, NSInteger messageID,BOOL needRefresh);
typedef void (^beginPlayBlock) (BOOL hasBegin);
typedef void (^endPlayBlock) (BOOL hasEnd);

@interface LiveTableViewCell : UITableViewCell
{
    NSString*picUrl;
    NSInteger messageID;
    
    UIButton *playBtn;//播放按钮
    UIImageView * playImageV;//播放语音动画view
    UILabel * lastTimeLabel;//持续时长label
    
    UILabel*titlelabel;//直播title
    UILabel*LcontentLable;//直播简介
    UILabel*doctorLabel;//医生名字
    UIButton*iconBtn; //医生头像
    
    UIView * zhanWeiView;//直播未开始前的占位图
    UIImageView * zhanWeiIcon;//
    UILabel * zhanWeiLabel;//显示时间的Label
    UILabel*replyLabel;
    redCircleView*redView;
}
@property (assign,nonatomic)BOOL isPlaying;//正在播放中
@property (assign,nonatomic)NSInteger IDS;//cell的表示ID

@property (strong,nonatomic)UILabel*timeLabel;
@property (strong,nonatomic)UILabel*nameLabel;//姓名
@property (strong,nonatomic)UIImageView *iconView;
@property (strong,nonatomic)UIButton *textView;
@property (strong,nonatomic)UIImageView*imageV;
@property (strong,nonatomic)UIImageView*backView;
@property (strong,nonatomic)UIImageView * voiceView;//语音view
@property (strong,nonatomic)voiceBtn*voiceButton;
@property (strong,nonatomic)UIView * liveIntroView;//直播简介view
@property (assign,nonatomic)BOOL showTime;

@property (strong,nonatomic)NSString * themeTitle;//直播主题

@property (strong,nonatomic)UIActivityIndicatorView * appendActivity;//菊花


@property (nonatomic, strong) liveCellFrameModel * liveCellFrame;

@property (nonatomic, strong) voiceBtnBlock voiceBlock;

@property (nonatomic, strong) beginPlayBlock beginBlock;

@property (nonatomic, strong) endPlayBlock endBlock;

-(void)setVoiceBlock:(voiceBtnBlock)voiceBlock;

-(void)setBeginBlock:(beginPlayBlock)beginBlock;

-(void)setEndBlock:(endPlayBlock)endBlock;

@end
