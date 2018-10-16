//
//  PayManager.h
//  MMPayExample
//
//  Created by Mac on 2017/12/6.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>                                 //用户绑定的银行卡信息

typedef NS_ENUM(NSInteger, MMPayResultType)
{
    MMPayResultType_ParsingFailure              = -1,//json解析失败
    MMPayResultType_WXAppNotInstalled           = -2,//没有安装微信客户端
    MMPayResultType_ApplyPayDeviceNotAllowed    = -3,//设备不支持ApplyPay
    MMPayResultType_ApplyPayNetworkNotAllowed   = -4 //网络不支持ApplyPay
};

//支付回调
typedef NS_ENUM(NSInteger, MMPayCallBackType)
{
    MMPayCallBackType_Success                   = 1,
    MMPayCallBackType_Cancel                    = 2,
    MMPayCallBackType_Failure                   = 3
};

//支付回调
typedef void(^MMPayCompletionBlock)(MMPayCallBackType type, id result);

//ApplyPay回调
typedef void(^ApplyPayAuthorizationCompletionBlock)(BOOL isAuthorization);

//TAApplyPay代理
@protocol MMApplyPayDelegate <NSObject>

@required
- (void)applyPayAuthorization:(PKPayment *)payment result:(ApplyPayAuthorizationCompletionBlock)result;

- (void)applyPayDidFinish;

@end

@interface PayManager : NSObject

@property (nonatomic, copy) NSString *orderedInfo;

+ (instancetype)shareManager;

- (void)startAlipay:(NSString *)order scheme:(NSString *)scheme callback:(MMPayCompletionBlock)result;

- (MMPayResultType)startWXPay:(NSString *)order;
    
- (void)processOrderWithPaymentResult:(NSURL *)resultUrl standbyCallback:(MMPayCompletionBlock)result;

- (BOOL)handleOpenURL:(NSURL *)url callback:(MMPayCompletionBlock)result;

//- (MMPayResultType)startApplyPay:(NSString *)order controller:(UIViewController<MMApplyPayDelegate> *)controller;

@end
