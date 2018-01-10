//
//  pointButton.m
//  Yizhenapp
//
//  Created by augbase on 16/5/6.
//  Copyright © 2016年 wang. All rights reserved.
//

#import "pointButton.h"
#define kButtonImageRatio 0.2

@implementation pointButton

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat x = self.bounds.size.width*kButtonImageRatio+22+10;
    CGFloat y = 13;
    CGFloat width = 100;
    CGFloat height = 18;
    
    return CGRectMake(x, y, width, height);
 
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat x = self.bounds.size.width*kButtonImageRatio;
    CGFloat y = 12;
    CGFloat width = 22;
    CGFloat height = 22;
    return CGRectMake(x, y, width, height);
}
- (void)setHighlighted:(BOOL)highlighted{}


@end
