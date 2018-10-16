//
//  UIButton+RD.h
//  rabbitDoctor
//
//  Created by Summer on 2018/3/13.
//  Copyright © 2018年 rabbitDoctor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+RD.h"

NS_ASSUME_NONNULL_BEGIN
@interface UIButton (RD)

/**
 *  普通网络图片展示
 *
 *  @param urlStr  图片地址
 *  @param phImage 占位图片
 */
-(void)imageWithUrlStr:(NSString *)urlStr phImage:(UIImage *)phImage;


/**
 *  带有进度的网络图片展示
 *
 *  @param urlStr         图片地址
 *  @param phImage        占位图片
 *  @param completedBlock 完成
 */
-(void)imageWithUrlStr:(NSString *)urlStr phImage:(UIImage *)phImage state:(UIControlState)state completedBlock:(RDWebImageCompletionBlock)completedBlock;

/**
 背景图

 @param url 图片地址
 @param state 状态
 */
- (void)backgroundImageWithURL:(nullable NSURL *)url
                      forState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END
