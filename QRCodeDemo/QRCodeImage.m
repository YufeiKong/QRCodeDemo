//
//  QRCodeImage.m
//  QRCodeDemo
//
//  Created by Content on 2017/6/19.
//  Copyright © 2017年 flymanshow. All rights reserved.
//

#import "QRCodeImage.h"

@implementation QRCodeImage

- (id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        self.frame=frame;
        self.userInteractionEnabled = YES;
    }
    return self;
}
#pragma mark ---生成普通黑白二维码
+ (UIImage *)generateWithDefaultQRCodeData:(NSString *)data{
   
    //创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //恢复滤镜的默认属性
    [filter setDefaults];
    //将字符串转换成数据
    NSData *infoData = [data dataUsingEncoding:NSUTF8StringEncoding];
    //通过KVC设置滤镜inputMessage数据  inputMessage代表要生成的二维码中所包含的信息
    [filter setValue:infoData forKeyPath:@"inputMessage"];

    //获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    //图片默认是(27,27),小于展示图片的控件的大小。拉伸模糊，所以我们需要放大
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(30, 30)];
    //将CIImage类型转成UIImage类型
    UIImage *start_image = [UIImage imageWithCIImage:outputImage];
    
    //开启绘图, 获取图形上下文 (上下文的大小, 就是二维码的大小)
    UIGraphicsBeginImageContext(start_image.size);
    //把二维码图片画上去 (这里是以图形上下文, 左上角为(0,0)点
    [start_image drawInRect:CGRectMake(0, 0, start_image.size.width, start_image.size.height)];
    //获取当前画得的这张图片
    UIImage *final_image = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图形上下文
    UIGraphicsEndImageContext();
    return final_image;
    
}
//#pragma mark ---根据CIImage生成指定大小的高清UIImage
//+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size {
//    
//    CGRect extent = CGRectIntegral(image.extent);
//    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
//    //创建bitmap;
//    size_t width = CGRectGetWidth(extent) * scale;
//    size_t height = CGRectGetHeight(extent) * scale;
//    //创建一个DeviceGray颜色空间
//    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
//    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
//    //CGBitmapContextCreate(void * _Nullable data, size_t width, size_t height, size_t bitsPerComponent, size_t bytesPerRow, CGColorSpaceRef  _Nullable space, uint32_t bitmapInfo)
//    //width：图片宽度像素
//    //height：图片高度像素
//    //bitsPerComponent：每个颜色的比特值，例如在rgba-32模式下为8
//    //bitmapInfo：指定的位图应该包含一个alpha通道。
//    CIContext *context = [CIContext contextWithOptions:nil];
//    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
//    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
//    CGContextScaleCTM(bitmapRef, scale, scale);
//    CGContextDrawImage(bitmapRef, extent, bitmapImage);
//    //保存bitmap到图片
//    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
//    CGContextRelease(bitmapRef);
//    CGImageRelease(bitmapImage);
//
//    return [UIImage imageWithCGImage:scaledImage];
//}
#pragma mark ---生成一张带有logo的二维码
/**
 *  生成一张带有logo的二维码
 *
 *  @param data     传入你要生成二维码的数据
 *  @param logoImageName    logo的image名
 *  @param logoScaleToSuperView    logo相对于父视图的缩放比
 */
+ (UIImage *)generateWithLogoQRCodeData:(NSString *)data logoImageName:(NSString *)logoImageName logoScaleToSuperView:(CGFloat)logoScaleToSuperView {
    
    //创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //恢复滤镜的默认属性
    [filter setDefaults];
    NSString *string_data = data;
    //将字符串转换成 NSdata (虽然二维码本质上是字符串, 但是这里需要转换, 不转换就崩溃)
    NSData *qrImageData = [string_data dataUsingEncoding:NSUTF8StringEncoding];
    //设置过滤器的输入值, KVC赋值
    [filter setValue:qrImageData forKey:@"inputMessage"];
    //获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    //图片默认是(27,27),小于展示图片的控件的大小。拉伸模糊，所以我们需要放大
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(10, 10)];
    //将CIImage类型转成UIImage类型
    UIImage *start_image = [UIImage imageWithCIImage:outputImage];

    //开启绘图, 获取图形上下文 (上下文的大小, 就是二维码的大小)
    UIGraphicsBeginImageContext(start_image.size);
    //把二维码图片画上去 (这里是以图形上下文, 左上角为(0,0)点
    [start_image drawInRect:CGRectMake(0, 0, start_image.size.width, start_image.size.height)];
    //再把小图片画上去
    NSString *icon_imageName = logoImageName;
    UIImage  *icon_image = [UIImage imageNamed:icon_imageName];
    CGFloat  icon_imageW = start_image.size.width * logoScaleToSuperView;
    CGFloat  icon_imageH = start_image.size.height * logoScaleToSuperView;
    CGFloat  icon_imageX = (start_image.size.width - icon_imageW) * 0.5;
    CGFloat  icon_imageY = (start_image.size.height - icon_imageH) * 0.5;
    
    [icon_image drawInRect:CGRectMake(icon_imageX, icon_imageY, icon_imageW, icon_imageH)];
    //获取当前画得的这张图片
    UIImage *final_image = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图形上下文
    UIGraphicsEndImageContext();
    
    return final_image;
}
#pragma mark ---生成一张彩色的二维码
/**
 *  生成一张彩色的二维码
 *
 *  @param data    传入你要生成二维码的数据
 *  @param backgroundColor    背景色
 *  @param mainColor    主颜色
 */
+ (UIImage *)generateWithColorQRCodeData:(NSString *)data backgroundColor:(CIColor *)backgroundColor mainColor:(CIColor *)mainColor {
    
    //创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //恢复滤镜的默认属性
    [filter setDefaults];
    NSData *qrImageData = [data dataUsingEncoding:NSUTF8StringEncoding];
    //设置过滤器的输入值, KVC赋值
    [filter setValue:qrImageData forKey:@"inputMessage"];
    //获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    // 图片默认是(27,27),小于展示图片的控件的大小。拉伸模糊，所以我们需要放大
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(5, 5)];
    
#pragma mark ---绘制颜色
    //创建彩色过滤器
    CIFilter * color_filter = [CIFilter filterWithName:@"CIFalseColor"];
    //设置默认值
    [color_filter setDefaults];
    //KVC 给私有属性赋值
    [color_filter setValue:outputImage forKey:@"inputImage"];
    //需要使用CIColor
    [color_filter setValue:backgroundColor forKey:@"inputColor0"];
    [color_filter setValue:mainColor forKey:@"inputColor1"];
    
    //设置输出
    CIImage *colorImage = [color_filter outputImage];
    
    //将CIImage类型转成UIImage类型
    UIImage *start_image = [UIImage imageWithCIImage:colorImage];
    //开启绘图, 获取图形上下文 (上下文的大小, 就是二维码的大小)
    UIGraphicsBeginImageContext(start_image.size);
    //把二维码图片画上去 (这里是以图形上下文, 左上角为(0,0)点
    [start_image drawInRect:CGRectMake(0, 0, start_image.size.width, start_image.size.height)];
    //获取当前画得的这张图片
    UIImage *final_image = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图形上下文
    UIGraphicsEndImageContext();
    return final_image;
    
}
#pragma mark ---条形码
+ (UIImage *)generateWithBarCodeData:(NSString *)data{
    
    NSString *string_data = data;
    NSData *qrImageData = [string_data dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:false];

    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    //恢复默认属性
    [filter setDefaults];
    [filter setValue:qrImageData forKey:@"inputMessage"];
    // 设置生成的条形码的上，下，左，右的margins的值
    [filter setValue:[NSNumber numberWithInteger:0] forKey:@"inputQuietSpace"];
    //设置输出
    CIImage *colorImage = [filter outputImage];
    // 图片默认是(27,27),小于展示图片的控件的大小。拉伸模糊，所以我们需要放大
    colorImage = [colorImage imageByApplyingTransform:CGAffineTransformMakeScale(5, 5)];
    //将CIImage类型转成UIImage类型
    UIImage *start_image = [UIImage imageWithCIImage:colorImage];
    
    //开启绘图, 获取图形上下文 (上下文的大小, 就是二维码的大小)
    UIGraphicsBeginImageContext(start_image.size);
    //把二维码图片画上去 (这里是以图形上下文, 左上角为(0,0)点
    [start_image drawInRect:CGRectMake(0, 0, start_image.size.width, start_image.size.height)];
    //获取当前画得的这张图片
    UIImage *final_image = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图形上下文
    UIGraphicsEndImageContext();
    return final_image;
    
}
@end
