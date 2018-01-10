//
//  UIImage+Scale.m
//  Yizhenapp
//
//  Created by 王浩 on 16/11/2.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import "UIImage+Scale.h"

@implementation UIImage (Scale)

-(UIImage*)getSubImage:(CGRect)rect

{
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    
    
    UIGraphicsBeginImageContext(smallBounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawImage(context, smallBounds, subImageRef);
    
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    
    UIGraphicsEndImageContext();
    
    
    
    return smallImage;
    
}

@end
