//
//  ScanningQRCodeVC.m
//  QRCodeDemo
//
//  Created by Content on 2017/6/19.
//  Copyright © 2017年 flymanshow. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "ScanningQRCodeVC.h"
#import "ScanningSuccesslyVC.h"

#define ScanLeft 30
#define ScanTop 100
#define ScanWidth UIScreenWidth-30*2
#define ScanRect CGRectMake(ScanLeft, ScanTop, ScanWidth, ScanWidth)

@interface ScanningQRCodeVC ()<UIAlertViewDelegate,AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSTimer *timer;
    CAShapeLayer *cropLayer;
}
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) UIView *scanWindow;
@property (nonatomic, strong) UIImageView *scanNetImageView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * layer;
@end

@implementation ScanningQRCodeVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (_layer) {
        
        [_layer removeFromSuperlayer];
    }
    //扫描动画
    [self startAnimation];
    //开始扫描
    [self beginScanning];
    
}
-(void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    //顶部导航
    [self setupNavView];
    //背景蒙版
    [self setCropRect:ScanRect];
    //扫描区域
    [self setupScanView];
    //提示文本与闪光灯
    [self setUpBottomView];
    //进入后台 恢复动画
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startAnimation) name:@"EnterForeground" object:nil];
    
}
#pragma mark ---导航栏
-(void)setupNavView{
    
    //返回
    UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, 30, 25, 25);
    [backBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_titlebar_back_nor"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(disMiss) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = left;
    //相册
    UIButton * albumBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    albumBtn.frame = CGRectMake(0, 0, 50, 49);
    [albumBtn setTitle:@"相册" forState:UIControlStateNormal];
    [albumBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [albumBtn addTarget:self action:@selector(gotoMyAlbum) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithCustomView:albumBtn];
    self.navigationItem.rightBarButtonItem = right;
    
}
#pragma mark ---背景蒙版
- (void)setCropRect:(CGRect)cropRect{
    
    cropLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, cropRect);
    CGPathAddRect(path, nil, self.view.bounds);
    
    [cropLayer setFillRule:kCAFillRuleEvenOdd];
    [cropLayer setPath:path];
    [cropLayer setFillColor:[UIColor blackColor].CGColor];//填充色
    [cropLayer setOpacity:0.7];
    [cropLayer setNeedsDisplay];
    [self.view.layer addSublayer:cropLayer];
}
#pragma mark ---提示与闪光灯
-(void)setUpBottomView{
    
    //操作提示
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _scanWindow.wc_maxY+30, UIScreenWidth, 30)];
    tipLabel.text = @"将取景框对准二维码，即可自动扫描";
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.numberOfLines = 2;
    tipLabel.font=[UIFont systemFontOfSize:12];
    tipLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tipLabel];
    //闪光灯
    UIButton *flashBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    flashBtn.frame = CGRectMake((UIScreenWidth-35)/2,tipLabel.wc_maxY, 35, 50);
    [flashBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_down"] forState:UIControlStateNormal];
    [flashBtn addTarget:self action:@selector(openFlash:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flashBtn];
    
}
#pragma mark ---二维码扫描区域
- (void)setupScanView
{
    //二维码区域
    _scanWindow = [[UIView alloc] initWithFrame:ScanRect];
    [self.view addSubview:_scanWindow];
    //二维码滚动图片
    _scanNetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan_net"]];
    CGFloat buttonWH = 18;
    //左上
    UIButton *topLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWH, buttonWH)];
    [topLeft setImage:[UIImage imageNamed:@"scan_1"] forState:UIControlStateNormal];
    [_scanWindow addSubview:topLeft];
    //右上
    UIButton *topRight = [[UIButton alloc] initWithFrame:CGRectMake(ScanWidth - buttonWH, 0, buttonWH, buttonWH)];
    [topRight setImage:[UIImage imageNamed:@"scan_2"] forState:UIControlStateNormal];
    [_scanWindow addSubview:topRight];
    //左下
    UIButton *bottomLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, ScanWidth - buttonWH, buttonWH, buttonWH)];
    [bottomLeft setImage:[UIImage imageNamed:@"scan_3"] forState:UIControlStateNormal];
    [_scanWindow addSubview:bottomLeft];
    //右下
    UIButton *bottomRight = [[UIButton alloc] initWithFrame:CGRectMake(topRight.wc_x, bottomLeft.wc_y, buttonWH, buttonWH)];
    [bottomRight setImage:[UIImage imageNamed:@"scan_4"] forState:UIControlStateNormal];
    [_scanWindow addSubview:bottomRight];
}
#pragma mark ----------开始扫描
- (void)beginScanning
{
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //输出类。这个支持二维码、条形码等图像数据的识别
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //会话对象。此类作为硬件设备输入输出信息的桥梁，承担实时获取设备数据的责任
    _session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    [_session addInput:input];
    [_session addOutput:output];
    //开始捕获
    [_session startRunning];
    
    //设置有效扫描区域
    CGFloat top = ScanTop/UIScreenHeight;
    CGFloat left = ScanLeft/UIScreenWidth;
    CGFloat width = ScanWidth/UIScreenWidth;
    CGFloat height = ScanWidth/UIScreenHeight;
    [output setRectOfInterest:CGRectMake(top,left , width, height)];
    
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    //创建AVCaptureVideoPreviewLayer对象来实时获取摄像头图像
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _layer = layer;
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    
}
#pragma mark ---当扫描到数据时就会执行该方法
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects.count>0) {
  
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        ScanningSuccesslyVC *vc = [[ScanningSuccesslyVC alloc]init];
        vc.strUrl = metadataObject.stringValue;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"扫描不到二维码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
    }
    
    [_session stopRunning];
    [_layer removeFromSuperlayer];
    
}
#pragma mark ---进入我的相册
-(void)gotoMyAlbum{
  
    
    [_session stopRunning];
    [_layer removeFromSuperlayer];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        
        //初始化相册拾取器
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        //设置代理
        controller.delegate = self;
        //设置资源：
        /**
         UIImagePickerControllerSourceTypePhotoLibrary,相册
         UIImagePickerControllerSourceTypeCamera,相机
         UIImagePickerControllerSourceTypeSavedPhotosAlbum,照片库
         */
        controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        //给一个转场动画
        controller.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:controller animated:NO completion:NULL];
        
    }else{
        
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备不支持访问相册，请在设置->隐私->照片中进行设置！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}
#pragma mark ---相册代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //获取选择的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //初始化一个监测器
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    //监测到的结果数组
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        
    if (features.count >0) {
        
    CIQRCodeFeature *feature = [features objectAtIndex:0];
    NSString *scannedResult = feature.messageString;
    ScanningSuccesslyVC *vc = [[ScanningSuccesslyVC alloc]init];
    vc.strUrl = scannedResult;
    [self.navigationController pushViewController:vc animated:YES];
        
    }else{
            
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片没有包含一个二维码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
            
        }
    }];
}
#pragma mark ----闪光灯
-(void)openFlash:(UIButton*)button{
    button.selected = !button.selected;
    
    if (button.selected) {
        [self turnTorchOn:YES];
    }
    else{
        [self turnTorchOn:NO];
    }
}
#pragma mark ---开关闪光灯
- (void)turnTorchOn:(BOOL)on
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    
    if (captureDeviceClass != nil) {
        
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasTorch] && [device hasFlash]){
        
        [device lockForConfiguration:nil];
        
        if(on){
            
        [device setTorchMode:AVCaptureTorchModeOn];
        [device setFlashMode:AVCaptureFlashModeOn];
            
        }else{
            
        [device setTorchMode:AVCaptureTorchModeOff];
        [device setFlashMode:AVCaptureFlashModeOff];
        }
        [device unlockForConfiguration];
    }
  }
}
#pragma mark ---开始扫描动画
- (void)startAnimation
{
    CAAnimation *anim = [_scanNetImageView.layer animationForKey:@"translationAnimation"];
    if(anim){
        //将动画的时间偏移量作为暂停时的时间点
        CFTimeInterval pauseTime = _scanNetImageView.layer.timeOffset;
        //根据媒体时间计算出准确的启动动画时间，对之前暂停动画的时间进行修正
        CFTimeInterval beginTime = CACurrentMediaTime() - pauseTime;
        //要把偏移时间清零
        [_scanNetImageView.layer setTimeOffset:0.0];
        //设置图层的开始动画时间
        [_scanNetImageView.layer setBeginTime:beginTime];
        [_scanNetImageView.layer setSpeed:1.0];
        
    }else{
    
        CGFloat scanNetImageViewH = ScanWidth;
        _scanNetImageView.frame = CGRectMake(0, -scanNetImageViewH, ScanWidth, ScanWidth);
        CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
        scanNetAnimation.keyPath = @"transform.translation.y";
        scanNetAnimation.byValue = @(ScanWidth);
        scanNetAnimation.duration = 1.0;
        scanNetAnimation.repeatCount = MAXFLOAT;
        [_scanNetImageView.layer addAnimation:scanNetAnimation forKey:@"translationAnimation"];
        [_scanWindow addSubview:_scanNetImageView];
    }
}
#pragma mark ---返回上一级
-(void)disMiss{
    
    [self.navigationController popViewControllerAnimated:NO];
}
@end
