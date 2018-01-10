//
//  linkButton.h
//  Yizhenapp
//
//  Created by augbase on 16/9/23.
//  Copyright © 2016年 Augbase. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface linkBtn : UIButton
//超链接button
@property (strong, nonatomic) NSString *linkUrl;

@property (strong, nonatomic) NSString *linkName;

-(void)setLinkName:(NSString *)linkName;

@end
