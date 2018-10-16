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

#import "IATConfig.h"
#import "IFlyManager.h"
#import "IFlyAudioSession.h"
#import "IFlyDataUploader.h"
#import "IFlyDebugLog.h"
#import "IFlyISVDelegate.h"
#import "IFlyISVRecognizer.h"
#import "IFlyMSC.h"
#import "IFlyPcmRecorder.h"
#import "IFlyRecognizerView.h"
#import "IFlyRecognizerViewDelegate.h"
#import "IFlyResourceUtil.h"
#import "IFlySetting.h"
#import "IFlySpeechConstant.h"
#import "IFlySpeechError.h"
#import "IFlySpeechEvaluator.h"
#import "IFlySpeechEvaluatorDelegate.h"
#import "IFlySpeechEvent.h"
#import "IFlySpeechRecognizer.h"
#import "IFlySpeechRecognizerDelegate.h"
#import "IFlySpeechSynthesizer.h"
#import "IFlySpeechSynthesizerDelegate.h"
#import "IFlySpeechUtility.h"
#import "IFlyUserWords.h"
#import "IFlyVoiceWakeuper.h"
#import "IFlyVoiceWakeuperDelegate.h"
#import "MMDrawStorage.h"
#import "MMImageCache.h"
#import "MMImageStorage.h"
#import "MMLinkTextStorage.h"
#import "MMStorageComponent.h"
#import "MMTextStorage.h"
#import "MMTextStorageProtocol.h"
#import "MMViewStorage.h"
#import "NSMutableAttributedString+MM.h"
#import "PinYinParser.h"
#import "RichTextManager.h"
#import "TextAttachmentContent.h"
#import "YYLabel+ChangeLabel.h"
#import "UIButton+RD.h"
#import "UIImageView+RD.h"

FOUNDATION_EXPORT double MMBaseComponentsVersionNumber;
FOUNDATION_EXPORT const unsigned char MMBaseComponentsVersionString[];

