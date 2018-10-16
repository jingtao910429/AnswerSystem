//
//  UIImageView+RD.m
//  rabbitDoctor
//
//  Created by Summer on 2018/3/13.
//  Copyright © 2018年 rabbitDoctor. All rights reserved.
//

#import "UIImageView+RD.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UIImageView (RD)

-(void)imageWithUrlString:(NSString *)urlStr{
    if(urlStr==nil) return;
    
    NSURL *url=[NSURL URLWithString:urlStr];
    
    if (url) {
        [self setImageWith:url placeholderImage:nil];
    }
}

/**
 *  imageView展示网络图片
 *
 *  @param urlStr  图片地址
 *  @param phImage 占位图片
 */
-(void)imageWithUrlStr:(NSString *)urlStr phImage:(nullable UIImage *)phImage{
    
    if(urlStr==nil) return;
    
    NSURL *url=[NSURL URLWithString:urlStr];
    
    [self setImageWith:url placeholderImage:phImage];
}



/**
 *  带有进度的网络图片展示
 *
 *  @param urlStr         图片地址
 *  @param phImage        占位图片
 *  @param progressBlock  进度
 *  @param completedBlock 完成
 */
-(void)imageWithUrlStr:(NSString *)urlStr phImage:(nullable UIImage *)phImage progressBlock:(nullable RDWebImageDownloaderProgressBlock)progressBlock completedBlock:(nullable RDWebImageCompletionBlock)completedBlock{
    
    if(urlStr==nil) return;
    
    NSURL *url=[NSURL URLWithString:urlStr];
    
    [self imageWithUrl:url phImage:phImage progressBlock:progressBlock completedBlock:completedBlock];
}

-(void)setImageWith:(NSURL *)imageUrl{
    if (imageUrl) {
        [self setImageWith:imageUrl placeholderImage:nil];
    }
}

-(void)setImageWith:(NSURL *)imageUrl placeholderImage:(nullable UIImage *)image{
    if (imageUrl) {
        [self imageWithUrl:imageUrl phImage:image progressBlock:nil completedBlock:nil];
    }
}

-(void)imageWithUrl:(NSURL *)url phImage:(nullable UIImage *)phImage progressBlock:(RDWebImageDownloaderProgressBlock)progressBlock completedBlock:(RDWebImageCompletionBlock)completedBlock{
    if (url) {
        SDWebImageOptions options = SDWebImageLowPriority | SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates;
        
        [self sd_setImageWithURL:url placeholderImage:phImage options:options progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            if (progressBlock) {
                progressBlock(receivedSize, expectedSize);
            }
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (completedBlock) {
                completedBlock(image, error, cacheType, imageURL);
            }
        }];
    }
}

@end
