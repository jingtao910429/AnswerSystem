//
//  PinYinParser.h
//  MMBaseComponents
//
//  Created by Mac on 2018/3/29.
//

#import <Foundation/Foundation.h>

@interface PinYinParser : NSObject

@property (nonatomic, copy) NSDictionary *pinYinDictionary;

//全局解析，保持一份翻译
+ (PinYinParser *)parserManager;

@end
