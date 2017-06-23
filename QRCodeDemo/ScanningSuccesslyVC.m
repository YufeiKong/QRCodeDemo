//
//  ScanningSuccesslyVC.m
//  QRCodeDemo
//
//  Created by Content on 2017/6/19.
//  Copyright © 2017年 flymanshow. All rights reserved.
//

#import "ScanningSuccesslyVC.h"

@interface ScanningSuccesslyVC ()<UIWebViewDelegate>
@property(nonatomic,strong)UIWebView *webView;

@end

@implementation ScanningSuccesslyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeight)];
    [self.view addSubview:_webView];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.strUrl]]];
}

@end
