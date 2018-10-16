#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "PayManager.h"
#import "AlipaySDK.h"
#import "APayAuthInfo.h"
#import "WechatAuthSDK.h"
#import "WXApi.h"
#import "WXApiObject.h"

FOUNDATION_EXPORT double MMBusinessComponentsVersionNumber;
FOUNDATION_EXPORT const unsigned char MMBusinessComponentsVersionString[];

