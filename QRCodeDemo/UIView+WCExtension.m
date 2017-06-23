//
//  UIView+WCExtension.m
//  QRCodeDemo
//
//  Created by Content on 2017/6/23.
//  Copyright © 2017年 flymanshow. All rights reserved.
//

#import "UIView+WCExtension.h"

@implementation UIView (WCExtension)

-(CGFloat)wc_x{

    return self.frame.origin.x;

}
-(void)setWc_x:(CGFloat)wc_x{
    CGRect temp = self.frame;
    temp.origin.x = wc_x;
    self.frame = temp;

}
-(CGFloat)wc_y{

    return self.frame.origin.y;

}
-(void)setWc_y:(CGFloat)wc_y{

    CGRect temp = self.frame;
    temp.origin.y = wc_y;
    self.frame = temp;

}
-(CGFloat)wc_width{

    return self.frame.size.width;

}
-(void)setWc_width:(CGFloat)wc_width{

    CGRect temp = self.frame;
    temp.size.width = wc_width;
    self.frame = temp;

}
-(CGFloat)wc_height{
    return self.frame.size.height;

}
-(void)setWc_height:(CGFloat)wc_height{

    CGRect temp = self.frame;
    temp.size.height = wc_height;
    self.frame = temp;
}
-(CGFloat)wc_maxX{

   return self.frame.origin.x + self.frame.size.width;
    
}
-(void)setWc_maxX:(CGFloat)wc_maxX{

}
-(CGFloat)wc_maxY{

   return self.frame.origin.y + self.frame.size.height;

}
-(void)setWc_maxY:(CGFloat)wc_maxY{
}
@end
