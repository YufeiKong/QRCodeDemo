//
//  QRCodeImage.h
//  QRCodeDemo
//
//  Created by Content on 2017/6/19.
//  Copyright © 2017年 flymanshow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCodeImage : UIImageView

@property(nonatomic,copy)NSString *strUrl;

//生成普通黑白二维码
+ (UIImage *)generateWithDefaultQRCodeData:(NSString *)data;
//生成一张带有logo的二维码
+ (UIImage *)generateWithLogoQRCodeData:(NSString *)data logoImageName:(NSString *)logoImageName logoScaleToSuperView:(CGFloat)logoScaleToSuperView;
//生成彩色二维码
+ (UIImage *)generateWithColorQRCodeData:(NSString *)data backgroundColor:(CIColor *)backgroundColor mainColor:(CIColor *)mainColor;
//生成条形码
+ (UIImage *)generateWithBarCodeData:(NSString *)data;
@end
