//
//  ServiceAndPrivateWebViewController.m
//  Yizhenapp
//
//  Created by 李胜书 on 15/10/28.
//  Copyright © 2015年 李胜书. All rights reserved.
//

#import "ServiceAndPrivateWebViewController.h"

@interface ServiceAndPrivateWebViewController ()<UIWebViewDelegate>

@end

@implementation ServiceAndPrivateWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _webView = [[UIWebView alloc] init];
    _webView.backgroundColor=[UIColor whiteColor];
    _webView.scrollView.backgroundColor=[UIColor whiteColor];
    _webView.delegate=self;
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:_url]];
    [_webView loadRequest:request];
    [self.view addSubview: _webView];
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.bottom.equalTo(@0);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
    }];
    
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, 0.5)];
    lineView.backgroundColor=lightGrayBackColor;
    [self.view addSubview:lineView];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = _WebTitle;
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [[SetupView ShareInstance]showHUD:self Title:@"加载中"];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[SetupView ShareInstance]hideHUD];
}

@end
