//
//  DeviceInfo.m
//  MMBaseTool
//
//  Created by Mac on 2018/4/9.
//  Copyright © 2018 RanDian. All rights reserved.
//

#import "DeviceInfo.h"

@implementation DeviceInfo

+ (CGFloat)screenHeight {
    return [[UIScreen mainScreen] bounds].size.height;
}

+ (CGFloat)screenWidth {
    return [[UIScreen mainScreen] bounds].size.width;
}

+ (CGFloat)adaptWidth {
    return MIN(DeviceInfo.screenHeight, DeviceInfo.screenWidth);
}

+ (CGFloat)adaptHeight {
    return MAX(DeviceInfo.screenHeight, DeviceInfo.screenWidth);
}

+ (CGFloat)adaptScreenWidth {
    if ([DeviceInfo isPad]) {
        if ([DeviceInfo isPadLanscape]) {
            return [DeviceInfo adaptHeight];
        } else {
            return [DeviceInfo adaptWidth];
        }
    }
    return [DeviceInfo screenWidth];
}

+ (BOOL)isPhone {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
}

+ (BOOL)isPad {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+ (BOOL)isPhoneX {
    return ((DeviceInfo.isPhone && DeviceInfo.screenHeight == 812.0) || DeviceInfo.screenWidth == 812.0);
}

+ (BOOL)isPadLanscape {
    return ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft
            || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight);
}

+ (BOOL)isPhonePlus {
    return ((DeviceInfo.isPhone && DeviceInfo.screenHeight == 736.0) || DeviceInfo.screenWidth == 736.0);
}

+ (CGFloat)navigationHeight {
    return DeviceInfo.isPhoneX ? 88 : 64;
}

+ (CGFloat)bottomHeight {
    return DeviceInfo.isPhoneX ? 34 : 0;
}

@end
