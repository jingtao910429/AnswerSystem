//
//  RichTextManager.h
//  Pods
//
//  Created by Mac on 2018/3/28.
//

#import <Foundation/Foundation.h>
#import "TextAttachmentContent.h"

@interface RichTextManager : NSObject

+ (RichTextManager *)sharedManager;

- (NSArray<YYTextAttachment *> *)allAttachments:(YYLabel *)label;
- (TextAttachmentContent *)fetchCurrentTextAttachment:(id)content label:(YYLabel *)label;
- (TextAttachmentContent *)searchRelateRange:(NSRange)range label:(YYLabel *)label;
- (TextAttachmentContent *)searchFocusWithPoint:(CGPoint)focus label:(YYLabel *)label;
- (TextAttachmentContent *)searchFocusWithPoint:(CGPoint)focus label:(YYLabel *)label offset:(CGFloat)offset;
- (void)selectAttachment:(NSArray<TextAttachmentContent *>*)attachments label:(YYLabel *)label isDelete:(BOOL)isDelete;
@end


