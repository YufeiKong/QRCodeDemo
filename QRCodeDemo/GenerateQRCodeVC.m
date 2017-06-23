//
//  GenerateQRCodeVC.m
//  QRCodeDemo
//
//  Created by Content on 2017/6/19.
//  Copyright © 2017年 flymanshow. All rights reserved.
//

#import "GenerateQRCodeVC.h"
#import "QRCodeImage.h"
#import "ScanningSuccesslyVC.h"

@interface GenerateQRCodeVC ()

@property(nonatomic,copy) QRCodeImage *codeImage;//生成普通黑白二维码
@property(nonatomic,copy) QRCodeImage *logoCodeImage;//生成一张带有logo的二维码
@property(nonatomic,copy) QRCodeImage *ColorCodeImage;//生成彩色二维码
@property(nonatomic,copy) QRCodeImage *BarCodeImage;//生成条形码

@end

@implementation GenerateQRCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //生成普通黑白二维码
    _codeImage=[[QRCodeImage alloc] initWithFrame:CGRectMake((UIScreenWidth-150)/2, 100, 150, 150)];
    _codeImage.image = [QRCodeImage generateWithDefaultQRCodeData:@"https://www.baidu.com"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(longPressJump:)];
    [_codeImage addGestureRecognizer:tap];
    [self.view addSubview:_codeImage];
    
    //生成条形码
//    _BarCodeImage=[[QRCodeImage alloc] initWithFrame:CGRectMake((UIScreenWidth-150)/2, 100, 150, 150)];
//    _BarCodeImage.image = [QRCodeImage generateWithBarCodeData:@"1234567890"];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(longPressJump:)];
//    [_BarCodeImage addGestureRecognizer:tap];
//    [self.view addSubview:_BarCodeImage];
    
    //生成一张带有logo的二维码
    _logoCodeImage=[[QRCodeImage alloc] initWithFrame:CGRectMake((UIScreenWidth-150)/2, 300, 150, 150)];
     CGFloat scale = 0.2;
    _logoCodeImage.image = [QRCodeImage generateWithLogoQRCodeData:@"https://www.jianshu.com/sign_in" logoImageName:@"live_photo_11" logoScaleToSuperView:scale];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(longPressJump:)];
    [_logoCodeImage addGestureRecognizer:tap2];
    [self.view addSubview:_logoCodeImage];

    //生成彩色二维码
    _ColorCodeImage=[[QRCodeImage alloc] initWithFrame:CGRectMake((UIScreenWidth-150)/2, 500, 150, 150)];
    _ColorCodeImage.image = [QRCodeImage generateWithColorQRCodeData:@"http://www.pgyer.com/user/login" backgroundColor: [CIColor colorWithRed:1 green:0 blue:0] mainColor:[CIColor colorWithRed:0 green:1 blue:0]];
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(longPressJump:)];
    [_ColorCodeImage addGestureRecognizer:tap3];
    [self.view addSubview:_ColorCodeImage];
    
}
-(void)longPressJump:(UIGestureRecognizer*)gesture{

    UIImageView*tempImageView=(UIImageView*)gesture.view;
   
    if(tempImageView.image){
        
    //初始化扫描仪，设置设别类型和识别质量
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode  context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    //扫描获取的特征组
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:tempImageView.image.CGImage]];
        
    if (features.count>0) {
    
    //获取扫描结果
    CIQRCodeFeature *feature = [features objectAtIndex:0];
    NSString *scannedResult = feature.messageString;
    
    ScanningSuccesslyVC *vc = [[ScanningSuccesslyVC alloc]init];
    vc.strUrl = scannedResult;
    [self.navigationController pushViewController:vc animated:YES];
        
    }else {
    
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:@"您还没有生成二维码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
        
    }
  }
}
@end
