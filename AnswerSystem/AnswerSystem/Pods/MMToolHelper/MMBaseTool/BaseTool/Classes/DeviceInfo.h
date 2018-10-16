//
//  DeviceInfo.h
//  MMBaseTool
//
//  Created by Mac on 2018/4/9.
//  Copyright © 2018 RanDian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DeviceInfo : NSObject
+ (CGFloat)screenHeight;
+ (CGFloat)screenWidth;
+ (CGFloat)adaptHeight;
+ (CGFloat)adaptWidth;
+ (BOOL)isPhone;
+ (BOOL)isPad;
+ (BOOL)isPhoneX;
+ (BOOL)isPhonePlus;
+ (BOOL)isPadLanscape;
+ (CGFloat)navigationHeight;
+ (CGFloat)bottomHeight;
+ (CGFloat)adaptScreenWidth;
@end
