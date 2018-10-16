//
//  RichTextManager.m
//  Pods
//
//  Created by Mac on 2018/3/28.
//

#import "RichTextManager.h"
#import "YYLabel+ChangeLabel.h"

/*
 获取当前所属TextAttachment
 */
TextAttachmentContent* FetchCurrentTextAttachment(id content, YYLabel *label) {
    TextAttachmentContent *textContent = nil;
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX) text:label.attributedText];
    NSArray *attachments = layout.attachments;
    for (int i = 0; i < attachments.count; i++) {
        YYTextAttachment *attachment = attachments[i];
        if ([content isKindOfClass:[TextAttachmentContent class]]) {
            TextAttachmentContent *attachmentContent = (TextAttachmentContent *)content;
            if (attachmentContent.textContent.content == attachment.content) {
                attachmentContent.range = [layout.attachmentRanges[i] rangeValue];
                return attachmentContent;
            }
        } else if ([content isKindOfClass:[YYTextAttachment class]]) {
            YYTextAttachment *text = (YYTextAttachment *)content;
            if (text.content == content) {
                TextAttachmentContent * cusContent = [[TextAttachmentContent alloc] init];
                cusContent.textContent = attachment;
                cusContent.range = [layout.attachmentRanges[i] rangeValue];
                return cusContent;
            }
        } else {
            if (content == attachment.content) {
                TextAttachmentContent * cusContent = [[TextAttachmentContent alloc] init];
                cusContent.textContent = attachment;
                cusContent.range = [layout.attachmentRanges[i] rangeValue];
                return cusContent;
            }
        }
        
    }
    return textContent;
}

TextAttachmentContent* FetchCurrentTextAttachmentRange(NSRange range, YYLabel *label) {
    
    NSRange currentRange = NSMakeRange(0, 0);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX) text:label.attributedText];
    NSArray *attachments = layout.attachments;
    for (int i = 0; i < attachments.count; i++) {
        YYTextAttachment *attachment = attachments[i];
        currentRange = [layout.attachmentRanges[i] rangeValue];
        if (currentRange.location == range.location && currentRange.length == range.length) {
            TextAttachmentContent *textContent = [[TextAttachmentContent alloc] init];
            textContent.textContent = attachment;
            textContent.range = currentRange;
            return textContent;
        }
        
    }
    return nil;
}

@implementation RichTextManager

+ (RichTextManager *)sharedManager {
    static RichTextManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RichTextManager alloc] init];
    });
    return sharedInstance;
}

- (NSArray<YYTextAttachment *> *)allAttachments:(YYLabel *)label {
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX) text:label.attributedText];
    NSArray *attachments = layout.attachments;
    return attachments;
}

- (TextAttachmentContent *)fetchCurrentTextAttachment:(id)content label:(YYLabel *)label {
    return FetchCurrentTextAttachment(content, label);
}


- (TextAttachmentContent *)searchRelateRange:(NSRange)range label:(YYLabel *)label {
    return FetchCurrentTextAttachmentRange(range, label);
}

- (TextAttachmentContent *)searchFocusWithPoint:(CGPoint)focus label:(YYLabel *)label offset:(CGFloat)offset {
    
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX) text:label.attributedText];
    
    NSArray *attachments = layout.attachments;
    for (int i = 0; i < attachments.count; i++) {
        YYTextAttachment *attachment = attachments[i];
        
        CGRect rect = [label convertRect:((UIView *)attachment.content).frame fromView:label];
        NSRange range = [layout.attachmentRanges[i] rangeValue];
        
        CGRect changeRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width + offset, rect.size.height);
        if (CGRectContainsPoint(rect, focus) || CGRectContainsPoint(changeRect, focus)) {
            TextAttachmentContent *textContent = [[TextAttachmentContent alloc] init];
            textContent.textContent = attachment;
            textContent.range = range;
            return textContent;
        }
    }
    return nil;
}

- (TextAttachmentContent *)searchFocusWithPoint:(CGPoint)focus label:(YYLabel *)label {
    
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX) text:label.attributedText];
    
    NSArray *attachments = layout.attachments;
    for (int i = 0; i < attachments.count; i++) {
        YYTextAttachment *attachment = attachments[i];
        //self.baseRichTextView.convert(optionView.drugButton.frame, from: optionView)
        CGRect rect = [label convertRect:((UIView *)attachment.content).frame fromView:label];
        
        NSRange range = [layout.attachmentRanges[i] rangeValue];
        
        //这种计算方式针对sizetofit不太准确
        //YYTextRange *textRange = [YYTextRange rangeWithRange:range];
        //CGRect rect = [label.textLayout rectForRange:textRange];
        
        //CGRect changeRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width + 50, rect.size.height);
        // || CGRectContainsPoint(changeRect, focus)
        if (CGRectContainsPoint(rect, focus)) {
            TextAttachmentContent *textContent = [[TextAttachmentContent alloc] init];
            textContent.textContent = attachment;
            textContent.range = range;
            return textContent;
        }
    }
    return nil;
}

- (void)selectAttachment:(NSArray<TextAttachmentContent *>*)attachments label:(YYLabel *)label isDelete:(BOOL)isDelete {
    
    if ([attachments count] == 0 || [label.attributedText.string isEqualToString:@""]) {
        return;
    }
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithAttributedString:label.attributedText];

    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX) text:content];
    NSArray *layoutAttachments = layout.attachments;
    NSArray *ranges = layout.attachmentRanges;
    
    YYTextBorder *border = [YYTextBorder new];
    if (isDelete && [attachments count] == 1) {
        border.fillColor = [UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1.0];
    } else {
        border.fillColor = [UIColor colorWithRed:237.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1.0];
    }
    border.cornerRadius = 4;
    border.insets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    NSMutableAttributedString *optionText = [[NSMutableAttributedString alloc] init];
    
    NSRange totalRange = NSMakeRange(0, 0);
    
    for (int i = 0; i < layoutAttachments.count; i++) {
        
        NSRange currentRange = [ranges[i] rangeValue];
        YYTextAttachment *attachment = layoutAttachments[i];
        
        for (int j = 0; j < attachments.count; j++) {
            TextAttachmentContent *findAttachment = attachments[j];
            if (attachment.content == findAttachment.textContent.content) {
                if (totalRange.length == 0 || totalRange.location > currentRange.location) {
                    //查询最小location
                    totalRange = currentRange;
                }
                
                CGSize contentSize = [label textAttachmentSize:findAttachment.textContent.content];
                NSMutableAttributedString *attachText = [label attchmentText:findAttachment contentSize:contentSize];
                [optionText appendAttributedString:attachText];
                
            }
        }
        
    }
    
    if (![optionText.string isEqualToString:@""]) {
        [optionText yy_setTextBackgroundBorder:border range:NSMakeRange(0, optionText.length)];
    }
    
    [content replaceCharactersInRange:NSMakeRange(totalRange.location, attachments.count) withAttributedString:optionText];
    
    label.attributedText = content;
    [label defaultParagraphStyle];
}

#pragma mark - private methods

- (BOOL)existAttachment:(NSRange)currentRange attachments:(NSArray<TextAttachmentContent *> *)attachments {
    for (int i = 0; i < attachments.count; i++) {
        TextAttachmentContent *textContent = attachments[i];
        NSRange range = textContent.range;
        if (currentRange.location == range.location && currentRange.length == range.length) {
            return YES;
        }
    }
    return NO;
}

- (NSAttributedString *)padding {
    NSMutableAttributedString *pad = [[NSMutableAttributedString alloc] initWithString:@"\n\n"];
    pad.yy_font = [UIFont systemFontOfSize:30];
    return pad;
}

@end
