//
//  UIButton+RD.m
//  rabbitDoctor
//
//  Created by Summer on 2018/3/13.
//  Copyright © 2018年 rabbitDoctor. All rights reserved.
//

#import "UIButton+RD.h"
#import <SDWebImage/UIButton+WebCache.h>

@implementation UIButton (RD)

/**
 *  imageView展示网络图片
 *
 *  @param urlStr  图片地址
 *  @param phImage 占位图片
 */
-(void)imageWithUrlStr:(NSString *)urlStr phImage:(UIImage *)phImage{
    
    if(urlStr==nil) return;
    
    NSURL *url=[NSURL URLWithString:urlStr];
    
    [self sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:phImage];
}




/**
 *  带有进度的网络图片展示
 *
 *  @param urlStr         图片地址
 *  @param phImage        占位图片
 *  @param completedBlock 完成
 */
-(void)imageWithUrlStr:(NSString *)urlStr phImage:(UIImage *)phImage state:(UIControlState)state completedBlock:(RDWebImageCompletionBlock)completedBlock{
    
    if(urlStr==nil) return;
    
    NSURL *url=[NSURL URLWithString:urlStr];
    
    SDWebImageOptions options = SDWebImageLowPriority | SDWebImageRetryFailed;
    
    [self sd_setImageWithURL:url forState:state placeholderImage:phImage options:options completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType, imageURL);
        }
    }];
}

- (void)backgroundImageWithURL:(nullable NSURL *)url
                      forState:(UIControlState)state{
    [self sd_setBackgroundImageWithURL:url forState:state];
}

@end
