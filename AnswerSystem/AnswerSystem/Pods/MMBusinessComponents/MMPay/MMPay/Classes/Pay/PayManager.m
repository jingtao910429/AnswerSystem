//
//  PayManager.m
//  MMPayExample
//
//  Created by Mac on 2017/12/6.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "PayManager.h"
#import "AlipaySDK.h"
#import "WXApi.h"
#import <PassKit/PKPaymentAuthorizationViewController.h>    //Apple pay的展示控件
#import <AddressBook/AddressBook.h>                         //用户联系信息相关

@interface PayManager() <WXApiDelegate, PKPaymentAuthorizationViewControllerDelegate>

@property (nonatomic, strong) UIViewController<MMApplyPayDelegate> * controller;

@property (nonatomic, copy) MMPayCompletionBlock result;

@end

@implementation PayManager

+ (instancetype)shareManager {
    static PayManager *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)startAlipay:(NSString *)order scheme:(NSString *)scheme callback:(MMPayCompletionBlock)result {
    
//    NSMutableString *orderConvertString = [NSMutableString stringWithString:order];
//    orderConvertString = [orderConvertString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSDictionary * para = [self dictionaryWithJsonString:order];
    //字符串解析失败
    if (para == nil) {
        return;
    }
    
    NSString *sign = para[@"sign"];
    NSString *biz_content = para[@"biz_content"];
    if (sign == nil) {
        return;
    }
    
    self.orderedInfo = para[@"out_trade_no"];
    
    NSMutableDictionary *muiltDictionary = [[NSMutableDictionary alloc] initWithCapacity:20];
    muiltDictionary[@"app_id"] = para[@"app_id"];
    muiltDictionary[@"charset"] = para[@"charset"];
    muiltDictionary[@"method"] = para[@"method"];
    muiltDictionary[@"notify_url"] = para[@"notify_url"];
    muiltDictionary[@"sign_type"] = para[@"sign_type"];
    muiltDictionary[@"timestamp"] = para[@"timestamp"];
    muiltDictionary[@"version"] = para[@"version"];
    
    NSString *orderInfoEncoded = [self orderEncode:muiltDictionary];
    
    if (![orderInfoEncoded isEqualToString:@""]) {

        biz_content = [self encodeValue:biz_content];
        
        NSCharacterSet *charset = [[NSCharacterSet characterSetWithCharactersInString:@":,"]invertedSet];
        biz_content = [biz_content stringByAddingPercentEncodingWithAllowedCharacters:charset];
        
        sign = [self urlEncodeValue:sign];
        sign = [sign stringByReplacingOccurrencesOfString:@"=" withString:@"%3d"];

        // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
        NSString *orderString = [NSString stringWithFormat:@"%@&biz_content=%@&sign=%@",
                                 orderInfoEncoded, biz_content, sign];
        
        orderString = [orderString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:scheme callback:^(NSDictionary *resultDic) {
            MMPayCallBackType type = MMPayCallBackType_Success;
            NSString * code = resultDic[@"resultStatus"];
            if ([code isEqualToString:@"9000"] || [code isEqualToString:@"8000"] || [code isEqualToString:@"6004"]) {
                type = MMPayCallBackType_Success;
            } else if ([code isEqualToString:@"6001"]) {
                type = MMPayCallBackType_Cancel;
            } else {
                type = MMPayCallBackType_Failure;
            }
            result(type, resultDic);
        }];

    }
}

- (MMPayResultType)startWXPay:(NSString *)order {
    NSDictionary * para = [self dictionaryWithJsonString:order];
    //字符串解析失败
    if (para == nil) {
        return MMPayResultType_ParsingFailure;
    }
    
    NSDictionary * req = para;
    //向微信注册
    [WXApi registerApp:req[@"appid"]];
    
    self.orderedInfo = req[@"out_trade_no"];
    
    //没有装微信客户端
//    if ([WXApi isWXAppInstalled] == NO) {
//        return MMPayResultType_WXAppNotInstalled;
//    }
    
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = [NSString stringWithFormat:@"%@",req[@"partnerId"]];
    request.prepayId = req[@"prepayId"];
    request.package = @"Sign=WXPay";
    request.nonceStr = req[@"nonceStr"];
    request.timeStamp = [req[@"timestamp"] intValue];
    request.sign = req[@"sign"];
    [WXApi sendReq:request];
    return 0;
}
    
- (void)processOrderWithPaymentResult:(NSURL *)resultUrl standbyCallback:(MMPayCompletionBlock)result {
    [[AlipaySDK defaultService] processOrderWithPaymentResult:resultUrl standbyCallback:^(NSDictionary *resultDic) {
        MMPayCallBackType type = MMPayCallBackType_Success;
        NSString * code = resultDic[@"resultStatus"];
        if ([code isEqualToString:@"9000"] || [code isEqualToString:@"8000"] || [code isEqualToString:@"6004"]) {
            type = MMPayCallBackType_Success;
        } else if ([code isEqualToString:@"6001"]) {
            type = MMPayCallBackType_Cancel;
        } else {
            type = MMPayCallBackType_Failure;
        }
        result(type, resultDic);
    }];
}
    
- (BOOL)handleOpenURL:(NSURL *)url callback:(MMPayCompletionBlock)result {
    self.result = result;
    return [WXApi handleOpenURL:url delegate:self];
}
    
#pragma mark - WXApiDelegate

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[PayResp class]]) {
        MMPayCallBackType type = MMPayCallBackType_Success;
        PayResp *response = (PayResp *)resp;
        int errCode = response.errCode;
        if (errCode == WXSuccess) {
            type = MMPayCallBackType_Success;
        } else if (errCode == WXErrCodeUserCancel) {
            type = MMPayCallBackType_Cancel;
        } else {
            type = MMPayCallBackType_Failure;
        }
        self.result(type, resp);
    }
}

- (MMPayResultType)startApplyPay:(NSString *)order controller:(UIViewController<MMApplyPayDelegate> *)controller {
    if (![PKPaymentAuthorizationViewController class]) {
        return MMPayResultType_ApplyPayDeviceNotAllowed;
    }
    if (![PKPaymentAuthorizationViewController canMakePayments]) {
        return MMPayResultType_ApplyPayDeviceNotAllowed;
    }
    
    NSArray *supportedNetworks = @[];
    
    //检查用户是否可进行某种卡的支付，是否支持Amex、MasterCard、Visa与银联四种卡，根据自己项目的需要进行检测
    if (@available(iOS 9.2, *)) {
        supportedNetworks = @[PKPaymentNetworkChinaUnionPay];
        if (![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:supportedNetworks]) {
            return MMPayResultType_ApplyPayNetworkNotAllowed;
        }
    } else {
        return MMPayResultType_ApplyPayNetworkNotAllowed;
    }
    
    NSDictionary * para = [self dictionaryWithJsonString:order];
    //字符串解析失败
    if (para == nil) {
        return MMPayResultType_ParsingFailure;
    }
    self.controller = controller;
    
    PKPaymentRequest *payRequest = [[PKPaymentRequest alloc] init];
    payRequest.countryCode = para[@"countryCode"];
    payRequest.currencyCode = para[@"currencyCode"];
    payRequest.merchantIdentifier = para[@"merchantIdentifier"];
    payRequest.supportedNetworks = supportedNetworks;
    
    payRequest.merchantCapabilities = PKMerchantCapability3DS|PKMerchantCapabilityEMV;
    NSDecimalNumber *totalAmount = [NSDecimalNumber decimalNumberWithString:para[@"amount"]];
    PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:para[@"summary"] amount:totalAmount];

    NSMutableArray *summaryItems = [NSMutableArray arrayWithArray:@[total]];
    payRequest.paymentSummaryItems = summaryItems;

    PKPaymentAuthorizationViewController *view = [[PKPaymentAuthorizationViewController alloc]initWithPaymentRequest:payRequest];
    view.delegate = self;
    [self.controller presentViewController:view animated:YES completion:nil];
    return 0;
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion {
    
//    PKContact *billingContact = payment.billingContact; //账单信息
//    PKPaymentToken *payToken = payment.token;               //支付凭据，发给服务端进行验证支付是否真实有效
//    PKContact *shippingContact = payment.shippingContact;   //送货信息
//    PKContact *shippingMethod = payment.shippingMethod;     //送货方式

    if ([self.controller conformsToProtocol:@protocol(MMApplyPayDelegate)] && [self.controller respondsToSelector:@selector(applyPayAuthorization:result:)]) {
        [self.controller applyPayAuthorization:payment result:^(BOOL isAuthorization) {
            if (isAuthorization) {
                completion(PKPaymentAuthorizationStatusSuccess);
            } else {
                completion(PKPaymentAuthorizationStatusFailure);
            }
        }];
    } else {
        completion(PKPaymentAuthorizationStatusFailure);
    }
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:nil];
    if ([self.controller conformsToProtocol:@protocol(MMApplyPayDelegate)] && [self.controller respondsToSelector:@selector(applyPayDidFinish)]) {
        [self.controller applyPayDidFinish];
    }
}

- (id)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                             options:NSJSONReadingMutableContainers
                                               error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (NSString *)orderEncode:(NSDictionary *)orderDictionary {
    
    // NOTE: 排序，得出最终请求字串
    NSArray* sortedKeyArray = [[orderDictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableArray *tmpArray = [NSMutableArray new];
    for (NSString* key in sortedKeyArray) {
        NSString* orderItem = [self orderItemWithKey:key andValue:[orderDictionary objectForKey:key] encoded:YES];
        if (orderItem.length > 0) {
            [tmpArray addObject:orderItem];
        }
    }
    return [tmpArray componentsJoinedByString:@"&"];
}

- (NSString*)orderItemWithKey:(NSString*)key andValue:(NSString*)value encoded:(BOOL)bEncoded {
    if (key.length > 0 && value.length > 0) {
        if (bEncoded) {
            value = [self urlEncodeValue:value];
        }
        return [NSString stringWithFormat:@"%@=%@", key, value];
    }
    return nil;
}

- (NSString*)encodeValue:(NSString*)value
{
    NSString* encodedValue = value;
    if (value.length > 0) {
        
        encodedValue = [encodedValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return encodedValue;
}

- (NSString*)urlEncodeValue:(NSString*)value
{
    NSString* encodedValue = value;
    if (value.length > 0) {
        NSCharacterSet *charset = [[NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]"]invertedSet];
        encodedValue = [value stringByAddingPercentEncodingWithAllowedCharacters:charset];
    }
    return encodedValue;
}


@end
