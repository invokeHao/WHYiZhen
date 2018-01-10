//
//  answerModel.m
//  Yizhenapp
//
//  Created by augbase on 16/8/31.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "answerModel.h"

@implementation answerModel

-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        self.doctorAvatar=[dic[@"doctorAvatar"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.doctorId=[dic[@"doctorId"] integerValue];
        self.doctorIntro=dic[@"doctorIntro"];
        self.doctorIntroLink=dic[@"doctorIntroLink"];
        self.doctorName=dic[@"doctorName"];
        self.hasAttend=[dic[@"hasAttend"] boolValue];
        self.hasClosed=[dic[@"hasClosed"] boolValue];
        self.IDS=[dic[@"id"] integerValue];
        self.intro=dic[@"intro"];
        self.startTime=dic[@"startTime"];
        self.startShowTime=dic[@"startShowTime"];
        self.tag=dic[@"tag"];
        self.title=dic[@"title"];
        self.attends=[dic[@"attends"] integerValue];
    }
    return self;
}

- (CGFloat)cellHeight
{
    if (!_cellHeight) {
        // 文字的最大尺寸
        CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 90- 15, MAXFLOAT);
        // 计算文字的高度
        NSString*titleStr=[NSString stringWithFormat:@"%@：%@",self.doctorName,self.title];
        
        CGFloat titleH = [titleStr boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : YiZhenFont } context:nil].size.height;
        if (titleH>46) {
            titleH=46;
        }
        NSLog(@"titleH==%f",titleH);
        CGFloat introH = [self.doctorIntro boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : YiZhenFont13 } context:nil].size.height;
        NSLog(@"introH＝=%f",introH);
        if (introH>60) {
            introH=60;
        }
        _cellHeight = 44+titleH+2+introH+37+10;
    }
    return _cellHeight;
}

- (NSInteger)compareTimeWithNow:(NSString*)time
{
    long liveTime = [time longLongValue] /1000;
    
    NSDate *nowDate=[NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[nowDate timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", a];
    long now=[timeString longLongValue] /1000;
    
    int days=(int)((liveTime-now)/3600/24+1);
    
    return days;
}

#pragma mark- 判断直播是否开始
-(BOOL)liveIsOpen
{
    NSDate *create = [NSDate dateWithTimeIntervalSince1970:[self.startTime longLongValue] /1000];
    
    NSDate *date=[NSDate date];
    
    NSInteger interval = [date timeIntervalSince1970];
    NSInteger intervalS=  [create timeIntervalSince1970];
    if (interval-intervalS>=0) {
        return YES;
    }
    else
    {
        return NO;
    }
}




@end
