//
//  PinYinParser.m
//  MMBaseComponents
//
//  Created by Mac on 2018/3/29.
//

#import "PinYinParser.h"

@implementation PinYinParser

+ (PinYinParser *)parserManager {
    static PinYinParser *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PinYinParser alloc] init];
        sharedInstance.pinYinDictionary = [sharedInstance getCharcterPinyin];
    });
    return sharedInstance;
}

- (NSDictionary *)getCharcterPinyin {
    NSError *fileError = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Frameworks/MMBaseComponents.framework/RichText.bundle/pinYin" ofType:@"plist"];
    NSDictionary *json = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if (fileError != nil) {
        return nil;
    }
    
    return json;
}
@end
