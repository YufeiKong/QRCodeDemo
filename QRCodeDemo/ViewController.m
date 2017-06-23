//
//  ViewController.m
//  QRCodeDemo
//
//  Created by Content on 2017/6/19.
//  Copyright © 2017年 flymanshow. All rights reserved.
//

#import "ViewController.h"
#import "GenerateQRCodeVC.h"
#import "ScanningQRCodeVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    UIButton *QRCodeBtn = [[UIButton alloc]initWithFrame:CGRectMake((UIScreenWidth-100)/2, 150, 100, 30)];
    [self.view addSubview:QRCodeBtn];
    [QRCodeBtn setTitle:@"生成二维码" forState:UIControlStateNormal];
    [QRCodeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [QRCodeBtn addTarget:self action:@selector(generateQRCode) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *QRCodeBtn2 = [[UIButton alloc]initWithFrame:CGRectMake((UIScreenWidth-100)/2, 250, 100, 30)];
    [self.view addSubview:QRCodeBtn2];
    [QRCodeBtn2 setTitle:@"扫描二维码" forState:UIControlStateNormal];
    [QRCodeBtn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [QRCodeBtn2 addTarget:self action:@selector(clickQRCode) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark ---生成二维码
-(void)generateQRCode{
    
    GenerateQRCodeVC *vc = [[GenerateQRCodeVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark ---扫描二维码
-(void)clickQRCode{

    ScanningQRCodeVC *vc = [[ScanningQRCodeVC alloc]init];
    [self.navigationController pushViewController:vc animated:NO];

}
@end
