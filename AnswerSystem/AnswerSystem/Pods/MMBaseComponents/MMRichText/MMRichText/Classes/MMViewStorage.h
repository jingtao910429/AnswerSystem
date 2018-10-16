//
//  MMDrawViewStorage.h
//  MMAttributedLabelDemo
//
//  Created by tanyang on 15/4/9.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "MMDrawStorage.h"

@interface MMViewStorage : MMDrawStorage<MMViewStorageProtocol>

@property (nonatomic, strong)   UIView *view;       // 添加view

@end
