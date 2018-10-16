//
//  IFlyManager.h
//  MMIFlyManager_Example
//
//  Created by Mac on 2018/4/30.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class IFlySpeechError;

typedef NS_ENUM (NSUInteger, IFlyManagerLanguage) {
    IFlyManagerEnglish = 1,
    IFlyManagerChinese = 2
};

@protocol IFlyManagerDelegate <NSObject>

@required
/*!
 *  回调返回识别结果
 *
 *  @param resultArray 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，sc为识别结果的置信度
 *  @param isLast      -[out] 是否最后一个结果
 */
- (void)onResult:(NSArray *)resultArray isLast:(BOOL) isLast;

/*!
 *  识别结束回调
 *
 *  @param error 识别结束错误码
 */
- (void)onError: (IFlySpeechError *) error;

@optional
/*!
 *  音量变化回调<br>
 *  在录音过程中，回调音频的音量。
 *
 *  @param volume -[out] 音量，范围从0-30
 */
- (void)onVolumeChanged:(int)volume;
@end

@interface IFlyManager : NSObject

@property (nonatomic, weak) id <IFlyManagerDelegate> delegate;

+ (IFlyManager *)sharedInstance;
- (void)initIFly:(CGPoint)point language:(IFlyManagerLanguage)language;
- (void)initSpeechPlayer;
- (BOOL)isListening;
- (void)start;
- (void)cancel;
- (void)destory;
- (void)startSpeech:(NSString *)speech language:(NSString *)language;
@end
