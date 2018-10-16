//
//  IFlyManager.m
//  MMIFlyManager_Example
//
//  Created by Mac on 2018/4/30.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <iflyMSC/iflyMSC.h>
#import "IFlyManager.h"
#import "IATConfig.h"

@interface IFlyManager () <IFlySpeechRecognizerDelegate>

@property (nonatomic, strong) AVSpeechSynthesizer *player;
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;
@property (nonatomic, strong) AVSpeechUtterance *utterance;

@end

@implementation IFlyManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initSpeechPlayer];
    }
    return self;
}

+ (IFlyManager *)sharedInstance {
    static IFlyManager  * instance = nil;
    static dispatch_once_t predict;
    dispatch_once(&predict, ^{
        instance = [[IFlyManager alloc] init];
        [instance initSpeechPlayer];
    });
    return instance;
}

- (void)initIFly:(CGPoint)point language:(IFlyManagerLanguage)language {
    
    //UI显示剧中
    
    _iFlySpeechRecognizer.delegate = self;
    [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    //设置听写模式
    [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    IATConfig *instance = [IATConfig sharedInstance];
    if (language == IFlyManagerEnglish) {
        instance.language = [IATConfig english];
    } else if (language == IFlyManagerChinese) {
        instance.language = [IATConfig chinese];
    }
    //设置最长录音时间
    [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
    //设置后端点
    [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
    //设置前端点
    [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
    //网络等待时间
    [_iFlySpeechRecognizer setParameter:@"5000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
    //设置采样率，推荐使用16K
    [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
    if ([instance.language isEqualToString:[IATConfig chinese]]) {
        //设置语言
        [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        //设置方言
        [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
    }else if ([instance.language isEqualToString:[IATConfig english]]) {
        //设置语言
        [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
    }
    //设置是否返回标点符号
    [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
    //设置音频来源为麦克风
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    //设置听写结果格式为json
    [_iFlySpeechRecognizer setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
    //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
    [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
}

- (void)initSpeechPlayer {
    _player = [[AVSpeechSynthesizer alloc] init];
    _iFlySpeechRecognizer= [[IFlySpeechRecognizer alloc] init];
}

- (void)startSpeech:(NSString *)speech language:(NSString *)language {
    if ([speech isEqualToString:@""]) {
        return;
    }
    _utterance = [[AVSpeechUtterance alloc]initWithString:speech];//设置语音内容
    _utterance.voice  = [AVSpeechSynthesisVoice voiceWithLanguage:language];//设置语言(英式英语)
    _utterance.rate   = 0.4;  //设置语速
    _utterance.volume = 1.0;  //设置音量（0.0~1.0）默认为1.0
    _utterance.pitchMultiplier    = 1.0;  //设置语调 (0.5-2.0)
    _utterance.postUtteranceDelay = 0; //目的是让语音合成器播放下一语句前有短暂的暂停
    [_player speakUtterance:_utterance];
}

- (BOOL)isListening {
    return self.iFlySpeechRecognizer.isListening;
}

- (void)start {
    if (self.iFlySpeechRecognizer.isListening) {
        return;
    }
    __weak IFlyManager *weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.iFlySpeechRecognizer startListening];
    });
}

- (void)cancel {
    __weak IFlyManager *weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.iFlySpeechRecognizer stopListening];
    });
}

#pragma mark - IFlySpeechRecognizerDelegate

- (void)onResults:(NSArray *)results isLast:(BOOL)isLast {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(onResult:isLast:)]) {
        [self.delegate onResult:results isLast:isLast];
    }
}

- (void)onError:(IFlySpeechError *)errorCode {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(onError:)]) {
        [self.delegate onError:errorCode];
    }
}

- (void)onVolumeChanged:(int)volume {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(onVolumeChanged:)]) {
        [self.delegate onVolumeChanged:volume];
    }
}

- (void)dealloc {
    self.iFlySpeechRecognizer.delegate = nil;
    [self.iFlySpeechRecognizer destroy];
    self.iFlySpeechRecognizer = nil;
}

@end
