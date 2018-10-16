//
//  MMDrawImageStorage.h
//  MMAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "MMDrawStorage.h"

typedef enum : NSUInteger {
    MMImageAlignmentCenter,  // 图片居中
    MMImageAlignmentLeft,    // 图片左对齐
    MMImageAlignmentRight,   // 图片右对齐
    MMImageAlignmentFill     // 图片拉伸填充
} MMImageAlignment;

@interface MMImageStorage : MMDrawStorage<MMViewStorageProtocol>

@property (nonatomic, strong) UIImage   *image;

@property (nonatomic, strong) NSString  *imageName;

@property (nonatomic, strong) NSURL     *imageURL;

@property (nonatomic, strong) NSString  *placeholdImageName;

@property (nonatomic, assign) MMImageAlignment imageAlignment; // default center

@property (nonatomic, assign) BOOL cacheImageOnMemory; // default NO ,if YES can improve performance，but increase memory
@end
