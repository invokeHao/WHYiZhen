//
//  dashLineView.m
//  Yizhenapp
//
//  Created by 王浩 on 16/11/9.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "dashLineView.h"

@implementation dashLineView

//虚线view
- (void)drawRect:(CGRect)rect {
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, grayBackColor.CGColor);
    CGFloat lengths[] = {2,4};
    CGContextSetLineDash(context, 0, lengths,2);
    CGContextMoveToPoint(context, 0, rect.origin.y);
    CGContextAddLineToPoint(context, rect.size.width,rect.origin.y);
    CGContextStrokePath(context);
}


@end
