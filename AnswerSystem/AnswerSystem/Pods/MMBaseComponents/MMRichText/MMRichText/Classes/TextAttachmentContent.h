//
//  TextAttachmentContent.h
//  MMBaseComponents
//
//  Created by Mac on 2018/3/29.
//

#import <Foundation/Foundation.h>
#import <YYText/YYText.h>

@interface TextAttachmentContent : NSObject
@property (nonatomic, strong) YYTextAttachment *textContent;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, assign) NSInteger index;
@end
