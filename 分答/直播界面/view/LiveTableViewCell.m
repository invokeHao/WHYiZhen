//
//  LiveTableViewCell.m
//  Yizhenapp
//
//  Created by augbase on 16/9/5.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "LiveTableViewCell.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import <AVFoundation/AVFoundation.h>
#import "UUAVAudioPlayer.h"
#import "redCircleView.h"

@interface LiveTableViewCell()<UUAVAudioPlayerDelegate>
{
    AVAudioPlayer *player;
    NSString *voiceURL;
    NSData *songData;
    
    UUAVAudioPlayer *audio;
    
    UIView *headImageBackView;
    BOOL contentVoiceIsPlaying;
    
}
@end
@implementation LiveTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self creatUI];
    }
    return self;
}

-(void)creatUI
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(UUAVAudioPlayerDidFinishPlay) name:@"VoicePlayHasInterrupt" object:nil];
    
    //红外线感应监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sensorStateChange:)
                                                 name:UIDeviceProximityStateDidChangeNotification
                                               object:nil];

    contentVoiceIsPlaying=NO;
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.textColor = darkTitleColor;
    _timeLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:13.0];
    [self.contentView addSubview:_timeLabel];
    
//    _timeLabel.hidden=YES;
    _nameLabel=[[UILabel alloc] init];
    _nameLabel.textColor=grayLabelColor;
    _nameLabel.font=YiZhenFont12;
    [self.contentView addSubview:_nameLabel];
    
    _iconView = [[UIImageView alloc] init];
    _iconView.layer.cornerRadius=16;
    _iconView.layer.masksToBounds=YES;
    [self.contentView addSubview:_iconView];
    
    _imageV=[[UIImageView alloc]init];
    _imageV.contentMode=UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_imageV];
    
    _textView = [UIButton buttonWithType:UIButtonTypeCustom];
    _textView.layer.cornerRadius=7.5;
    _textView.layer.masksToBounds=YES;
    _textView.titleLabel.numberOfLines = 0;
    _textView.titleLabel.font = YiZhenFont14;
    _textView.contentEdgeInsets = UIEdgeInsetsMake(textPadding, textPadding, textPadding, textPadding);
    [self.contentView addSubview:_textView];
    
    //语音view
    _voiceView=[[UIImageView alloc]init];
    UIImage*textBg=[[UIImage imageNamed:@"live_bg_blue"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    _voiceView.image=textBg;
    _voiceView.userInteractionEnabled=YES;
    [self.contentView addSubview:_voiceView];
    
    _voiceButton=[voiceBtn buttonWithType:UIButtonTypeCustom];
    _voiceButton.layer.cornerRadius=20;
    _voiceButton.layer.masksToBounds=YES;
    [_voiceButton addTarget:self action:@selector(pressToPlayVoice:) forControlEvents:UIControlEventTouchUpInside];
    [_voiceView addSubview:_voiceButton];
    
    replyLabel=[[UILabel alloc]init];
    replyLabel.textColor=[UIColor blackColor];
    replyLabel.numberOfLines=0;
    replyLabel.font=YiZhenFont14;
    [_voiceView addSubview:replyLabel];

    //小红点
    redView=[[redCircleView alloc]init];
    redView.cornerRadiu=4;
    redView.hidden=YES;
    [_voiceView addSubview:redView];
    
    [redView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@8);
        make.top.equalTo(@0);
        make.size.mas_equalTo(CGSizeMake(8, 8));
    }];

    //直播详情view
    _liveIntroView=[[UIView alloc]init];
    _liveIntroView.backgroundColor=grayBackgroundLightColor;
    [self.contentView addSubview:_liveIntroView];
    
    //标题
    titlelabel=[[UILabel alloc]init];
    titlelabel.font=YiZhenFont16;
    titlelabel.textColor=[UIColor blackColor];
    titlelabel.numberOfLines=0;
    titlelabel.textAlignment=NSTextAlignmentCenter;
    [_liveIntroView addSubview:titlelabel];
    //内容
    LcontentLable=[[UILabel alloc]init];
    LcontentLable.font=YiZhenFont13;
    LcontentLable.textColor=grayLabelColor;
    LcontentLable.numberOfLines=0;
    
    [_liveIntroView addSubview:LcontentLable];

    
    iconBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    iconBtn.layer.cornerRadius=30;
    iconBtn.layer.masksToBounds=YES;
    [_liveIntroView addSubview:iconBtn];
    
    doctorLabel=[[UILabel alloc]init];
    doctorLabel.font=YiZhenFont;
    doctorLabel.textColor=[UIColor blackColor];
    doctorLabel.numberOfLines=2;
    [_liveIntroView addSubview:doctorLabel];
    
    //占位图
    zhanWeiView=[[UIView alloc]init];
    zhanWeiView.backgroundColor=[UIColor whiteColor];
    [self.contentView addSubview:zhanWeiView];
    //占位的Icon
    zhanWeiIcon=[[UIImageView alloc]init];
    [zhanWeiIcon setContentMode:UIViewContentModeScaleAspectFit];
    [zhanWeiIcon setImage:[UIImage imageNamed:@"live_dt_star"]];
    [zhanWeiView addSubview:zhanWeiIcon];
    //占位的label
    UILabel * label=[[UILabel alloc]init];
    label.font=YiZhenFont13;
    label.textColor=darkTitleColor;
    label.textAlignment=NSTextAlignmentCenter;
    label.text=@"直播暂未开始";
    [zhanWeiView addSubview:label];
    //占位直播时间
    zhanWeiLabel=[[UILabel alloc]init];
    zhanWeiLabel.font=YiZhenFont13;
    zhanWeiLabel.textColor=darkTitleColor;
    zhanWeiLabel.textAlignment=NSTextAlignmentCenter;
    [zhanWeiView addSubview:zhanWeiLabel];
    
    [zhanWeiIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@48);
        make.centerX.mas_equalTo(zhanWeiView);
        make.size.mas_equalTo(CGSizeMake(105, 105));
    }];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(zhanWeiIcon.mas_bottom).with.offset(10);
        make.centerX.mas_equalTo(zhanWeiView);
        make.height.equalTo(@20);
    }];
    
    [zhanWeiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(label.mas_bottom).with.offset(1);
        make.centerX.mas_equalTo(zhanWeiView);
        make.height.equalTo(@20);
    }];
    
}

- (void)setLiveCellFrame:(liveCellFrameModel *)cellFrameModel
{
    _liveCellFrame = cellFrameModel;
    LiveModel *messageModel = cellFrameModel.messageModel;
    
    _timeLabel.frame = cellFrameModel.timeFrame;
    _timeLabel.text = [messageModel create_time];
    _timeLabel.hidden=YES;
    
    if (_liveCellFrame.messageModel.showTime) {
        _timeLabel.hidden=NO;
    }

    _nameLabel.frame=cellFrameModel.nameFrame;
    _nameLabel.text=messageModel.creatorName;
    
    _iconView.frame = cellFrameModel.iconFrame;
    
    [_iconView sd_setImageWithURL:[NSURL URLWithString:messageModel.creatorAvatar] placeholderImage:[UIImage imageNamed:@"default_avatar3"]];
    //文本消息
    if (messageModel.type==0) {
        _iconView.hidden=NO;
        _voiceView.hidden=YES;
        _imageV.hidden=YES;
        _textView.hidden=NO;
        _liveIntroView.hidden=YES;
        zhanWeiView.hidden=YES;
        UIImage *textBg=[[UIImage imageNamed:@"live_bg_gray"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        if (messageModel.sendByDoctor) {
           textBg=[[UIImage imageNamed:@"live_bg_blue"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        }
        [_textView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        [_textView setBackgroundImage:textBg forState:UIControlStateNormal];
        [_textView setTitle:messageModel.content forState:UIControlStateNormal];
        _textView.frame = cellFrameModel.textFrame;
    }
    //语音消息
    else if (messageModel.type==1) {
        _iconView.hidden=NO;
        _voiceView.hidden=NO;
        _textView.hidden=YES;
        _imageV.hidden=YES;
        _liveIntroView.hidden=YES;
        zhanWeiView.hidden=YES;
        messageID=messageModel.IDS;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                redView.hidden=NO;
                if (messageModel.hasRead) {
                    redView.hidden=YES;
                }
                //布局
                _voiceView.frame=cellFrameModel.textFrame;
                [_voiceButton setDuration:messageModel.duration];
                if (_isPlaying) {
                 [_voiceButton.playBtnV setImage:[UIImage imageNamed:@"broadcast_2"]];
                }
                else{
                 [_voiceButton.playBtnV setImage:[UIImage imageNamed:@"broadcast"]];
                }

                [_voiceButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(@0);
                    make.left.equalTo(@0);
                    make.right.equalTo(@0);
                    make.bottom.equalTo(@0);
                }];

                if (messageModel.replyCreatorId==0) {
                    replyLabel.hidden=YES;
                }
                if (messageModel.replyCreatorId>0) {
                    replyLabel.hidden=NO;
                    
                    replyLabel.text=[NSString stringWithFormat:@"%@：%@",messageModel.replyCreatorName,messageModel.replyContent];
                    [replyLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.equalTo(@15);
                        make.top.equalTo(@10);
                        make.right.equalTo(@-15);
                    }];
                    [_voiceButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(replyLabel.mas_bottom).with.offset(10);
                        make.left.equalTo(@0);
                        make.right.equalTo(@0);
                    }];
                }
            });
        });
    }
    //图片消息
    else if (messageModel.type==2)
    {
        _iconView.hidden=NO;
        _voiceView.hidden=YES;
        _textView.hidden=YES;
        _liveIntroView.hidden=YES;
        zhanWeiView.hidden=YES;
        _imageV.hidden=NO;
        //切掉图片的修饰后缀，拿到原图的url
        NSArray*strArr=[messageModel.content componentsSeparatedByString:@"@"];
        picUrl=strArr[0];
        
        [_imageV.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        _imageV.userInteractionEnabled=YES;
        UIImage*imageBg=[UIImage imageNamed:@"chatfrom_bg"];
        _imageV.image=imageBg;
        _imageV.layer.cornerRadius=5;
        _imageV.layer.masksToBounds=YES;
        _imageV.contentMode=UIViewContentModeScaleAspectFill;
        
        _backView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth/2, ViewWidth/2)];
        _backView.userInteractionEnabled=YES;
        _backView.contentMode=UIViewContentModeScaleAspectFill;
        [_backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTap:)]];
        [_backView sd_setImageWithURL:[NSURL URLWithString:messageModel.content] placeholderImage:[UIImage imageNamed:@"yulantu_3"]];
        _imageV.frame=cellFrameModel.textFrame;
        [_imageV addSubview:_backView];
    }
    //直播简介
    else if (messageModel.type==3)
    {
        _voiceView.hidden=YES;
        _textView.hidden=YES;
        _imageV.hidden=YES;
        _liveIntroView.hidden=NO;
        zhanWeiView.hidden=YES;
        _iconView.hidden=YES;
        
        //控件布局
        [iconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@20);
            make.centerX.mas_equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(60,60));
        }];
        
        [doctorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(iconBtn.mas_bottom).with.offset(8);
            make.centerX.mas_equalTo(self.contentView);
            make.height.equalTo(@22);
        }];
        
        [titlelabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(doctorLabel.mas_bottom).with.offset(16);
            make.centerX.mas_equalTo(self.contentView);
            make.left.equalTo(@50);
            make.right.equalTo(@-50);
        }];
        
        [LcontentLable mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@15);
            make.right.equalTo(@-15);
            make.top.mas_equalTo(titlelabel.mas_bottom).with.offset(17);
        }];
        
        _liveIntroView.frame=cellFrameModel.textFrame;
        titlelabel.text=messageModel.liveTitle;
        LcontentLable.text=messageModel.liveIntro;
        [iconBtn sd_setImageWithURL:[NSURL URLWithString:messageModel.creatorAvatar] forState:UIControlStateNormal];
        doctorLabel.text=messageModel.creatorName;
    }
    else if (messageModel.type==4)
    {
        _voiceView.hidden=YES;
        _textView.hidden=YES;
        _imageV.hidden=YES;
        _liveIntroView.hidden=YES;
        zhanWeiView.hidden=NO;
        _iconView.hidden=YES;
        
        zhanWeiView.frame=cellFrameModel.textFrame;
        zhanWeiLabel.text=messageModel.createTime;

    }
}

#pragma mark-图片的点击事件
- (void)photoTap:(UITapGestureRecognizer *)recognizer
{
    NSInteger count = 1;
    
    // 1.封装图片数据
    NSMutableArray *myphotos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        // 一个MJPhoto对应一张显示的图片
        MJPhoto *mjphoto = [[MJPhoto alloc] init];
        
        mjphoto.srcImageView = _backView; // 来源于哪个UIImageView
        mjphoto.url = [NSURL URLWithString:picUrl]; // 图片路径
        
        [myphotos addObject:mjphoto];
    }
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = 0; // 弹出相册时显示的第一张图片是？
    browser.photos = myphotos; // 设置所有的图片
    [browser show];
}

#pragma mark-点击播放语音
-(void)pressToPlayVoice:(UIButton*)button
{
    redView.hidden=YES;
    if (_liveCellFrame.messageModel.hasRead) {
        _voiceBlock(YES,messageID,NO);
    }
    else{
        _voiceBlock(YES,messageID,YES);
    }
    if (button.selected) {
        [audio stopSound];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VoicePlayHasInterrupt" object:nil];
        contentVoiceIsPlaying = YES;
        audio = [UUAVAudioPlayer sharedInstance];
        __weak id weakSelf=self;
        audio.delegate = weakSelf;
        LiveModel *messageModel = _liveCellFrame.messageModel;
        [_voiceButton.playBtnV setImage:[UIImage imageNamed:@"loading_blue_bg"]];
        [self appendActivityView:_voiceButton.playBtnV AndColor:[UIColor whiteColor]];
        NSURLRequest * request=[NSURLRequest requestWithURL:[NSURL URLWithString:messageModel.content]];
        NSOperationQueue * queue=[NSOperationQueue mainQueue];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if (data) {
                [self removeActivityViewFromView:_voiceButton.playBtnV];
                songData=data;
                [audio playSongWithData:songData];
            }
            else{
                YiZhenLog(@"%@",connectionError);
            }
        }];
    }
    button.selected=!button.selected;
}

- (void)UUAVAudioPlayerBeiginLoadVoice{
    [self.voiceButton benginLoadVoice];
}

- (void)UUAVAudioPlayerBeiginPlay{
    [self.voiceButton didLoadVoice];
    //开启红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    _beginBlock(YES);
}

- (void)UUAVAudioPlayerDidFinishPlay{
    //关闭红外线感应
    _voiceButton.selected=NO;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    contentVoiceIsPlaying = NO;
    [self.voiceButton stopPlay];
    _isPlaying=NO;
    _endBlock(YES);
}

-(void)UUAVAudioPlayerStopPlay
{
    [self.voiceButton stopPlay];
    _endBlock(YES);
    _isPlaying=NO;
    //关闭红外
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}
//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    if ([[UIDevice currentDevice] proximityState] == YES){
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else{
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

- (void)appendActivityView:(UIView*)View AndColor:(UIColor *)color{
    //1.添加菊花
    if (!self.appendActivity) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.frame = View.bounds;
        CGAffineTransform transform = CGAffineTransformMakeScale(.5f, .5f);
        activityIndicator.transform = transform;
        activityIndicator.color = color;
        [activityIndicator startAnimating];
        [activityIndicator setHidesWhenStopped:YES];
        
        self.appendActivity = activityIndicator;
        //隐藏其它子视图
        for (UIView *view1 in View.subviews) {
            view1.hidden = YES;
        }
        [View addSubview:activityIndicator];
    }
    else{
        [self.appendActivity startAnimating];
    }
    [View bringSubviewToFront:self.appendActivity];
    
}

- (void)removeActivityViewFromView:(UIView*)view{
    
    for (UIView *view1 in view.subviews) {
        view1.hidden = NO;
    }
//    UIImageView * imageV=(UIImageView *)view;
//    [imageV setImage:[UIImage imageNamed:@"broadcast_2"]];
    //2.去掉菊花
    if (self.appendActivity) {
        self.appendActivity.hidden = YES;
        [self.appendActivity stopAnimating]; // 结束旋转
        [self.appendActivity removeFromSuperview];
    }
}




@end
