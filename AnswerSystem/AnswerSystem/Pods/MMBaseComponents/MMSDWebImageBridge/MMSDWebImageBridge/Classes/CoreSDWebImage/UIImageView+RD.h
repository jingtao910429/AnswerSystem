//
//  UIImageView+RD.h
//  rabbitDoctor
//
//  Created by Summer on 2018/3/13.
//  Copyright © 2018年 rabbitDoctor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/SDWebImageManager.h>

NS_ASSUME_NONNULL_BEGIN


typedef void(^RDWebImageCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL);

typedef void(^RDWebImageDownloaderProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);


@interface UIImageView (RD)

/**
 *  普通网络图片展示
 *
 *  @param urlStr  图片地址
 */
-(void)imageWithUrlString:(NSString *)urlStr;

//-(void)

/**
 *  普通网络图片展示
 *
 *  @param urlStr  图片地址
 *  @param phImage 占位图片
 */
-(void)imageWithUrlStr:(NSString *)urlStr phImage:(nullable UIImage *)phImage;


/**
 *  带有进度的网络图片展示
 *
 *  @param urlStr         图片地址
 *  @param phImage        占位图片
 *  @param progressBlock  进度
 *  @param completedBlock 完成
 */
-(void)imageWithUrlStr:(NSString *)urlStr phImage:(nullable UIImage *)phImage progressBlock:(nullable RDWebImageDownloaderProgressBlock)progressBlock completedBlock:(nullable RDWebImageCompletionBlock)completedBlock;

@end

NS_ASSUME_NONNULL_END
