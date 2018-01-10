//
//  ShootCaseViewController.h
//  ResultContained
//
//  Created by wang on 16/5/2.
//  Copyright (c) 2016年 wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyInfoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) IBOutlet UITableView *myInfoTable;

@end
