//
//  YYLabel+ChangeLabel.m
//  MMBaseComponents
//
//  Created by Mac on 2018/3/29.
//

#import "YYLabel+ChangeLabel.h"
#import "UIView+YYAdd.h"
#import "CALayer+YYAdd.h"
#import "RichTextManager.h"

@implementation YYLabel (ChangeLabel)

- (void)mm_deleteTextAttachment:(TextAttachmentContent *)attachment {
    
    TextAttachmentContent *deletePositionAttachment = [[RichTextManager sharedManager] fetchCurrentTextAttachment:attachment label:self];
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [content deleteCharactersInRange:deletePositionAttachment.range];
    
    self.attributedText = content;
    
    [self defaultParagraphStyle];
}

- (void)mm_replaceTextAttachment:(TextAttachmentContent *)attachment original:(id)originalAttachment {
    
    TextAttachmentContent *insertPositionAttachment = [[RichTextManager sharedManager] fetchCurrentTextAttachment:originalAttachment label:self];
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    CGSize contentSize = [self textAttachmentSize:attachment.textContent.content];
    
    NSMutableAttributedString *attachText = [self attchmentText:attachment contentSize:contentSize];
    
    [content replaceCharactersInRange:insertPositionAttachment.range withAttributedString:attachText];
    
    self.attributedText = content;
    
    [self defaultParagraphStyle];
}

- (void)mm_replaceTextAttachment:(TextAttachmentContent *)attachment original:(id)originalAttachment border:(YYTextBorder *)border {
    
    TextAttachmentContent *insertPositionAttachment = [[RichTextManager sharedManager] fetchCurrentTextAttachment:originalAttachment label:self];
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    CGSize contentSize = [self textAttachmentSize:attachment.textContent.content];
    
    NSMutableAttributedString *attachText = [self attchmentText:attachment contentSize:contentSize];
    
    [attachText yy_setTextBackgroundBorder:border range:NSMakeRange(0, attachText.length)];
    
    [content replaceCharactersInRange:insertPositionAttachment.range withAttributedString:attachText];
    
    self.attributedText = content;
    
    [self defaultParagraphStyle];
}

- (void)mm_insertTextAttachment:(TextAttachmentContent *)attachment original:(id)originalAttachment {
    
    //查找插入位置，插入位置跟originalAttachment位置相关
    TextAttachmentContent *insertPositionAttachment = [[RichTextManager sharedManager] fetchCurrentTextAttachment:originalAttachment label:self];
    
    CGSize contentSize = [self textAttachmentSize:attachment.textContent.content];
    
    //Attribute化插入元素
    NSMutableAttributedString *attachText = [self attchmentText:attachment contentSize:contentSize];
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    if (insertPositionAttachment == nil) {
        //插入位置为空，直接进行添加
        
        [attachText appendAttributedString:content];
        self.attributedText = attachText;

    } else {

        [content insertAttributedString:attachText atIndex:insertPositionAttachment.range.location];
        self.attributedText = content;
        
    }
    [self defaultParagraphStyle];
}

- (void)mm_insertTextAttachment:(TextAttachmentContent *)attachment original:(id)originalAttachment isAddLength:(BOOL)isAddLength {
    
    BOOL discardSupplyView = NO;
    
    //查找插入位置，插入位置跟originalAttachment位置相关
    TextAttachmentContent *insertPositionAttachment = [[RichTextManager sharedManager] fetchCurrentTextAttachment:originalAttachment label:self];
    
    CGSize contentSize = [self textAttachmentSize:attachment.textContent.content];
    
    //Attribute化插入元素
    NSMutableAttributedString *attachText = [self attchmentText:attachment contentSize:contentSize];
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    if (insertPositionAttachment == nil || discardSupplyView) {
        //插入位置为空，直接进行添加
        //抛弃填充视图
        self.attributedText = attachText;
        
    } else {
        
        [content insertAttributedString:attachText atIndex:insertPositionAttachment.range.location + (isAddLength ? insertPositionAttachment.range.length : 0)];
        self.attributedText = content;
        
    }
    [self defaultParagraphStyle];
}

#pragma mark - private methods

- (CGSize)textAttachmentSize:(id)attachment {
    
    CGSize contentSize = CGSizeMake(0, 0);
    if ([attachment isKindOfClass:[UIImage class]]) {
        UIImage *contentImage = (UIImage *)attachment;
        contentSize = contentImage.size;
    } else if ([attachment isKindOfClass:[UIView class]]) {
        UIView *contentView = (UIView *)attachment;
        contentSize = contentView.size;
    } else if ([attachment isKindOfClass:[CALayer class]]) {
        CALayer *layer = (CALayer *)attachment;
        contentSize = layer.frameSize;
    }
    return contentSize;
    
}

- (NSMutableAttributedString *)attchmentText:(TextAttachmentContent *)attachment contentSize:(CGSize)contentSize {
    NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:attachment.textContent.content contentMode:UIViewContentModeLeft attachmentSize:contentSize alignToFont:[UIFont systemFontOfSize:16.0] alignment:YYTextVerticalAlignmentCenter];
    return attachText;
}

- (void)defaultParagraphStyle {
    [self paragraphStyle:40 lineSpace:4];
}

- (void)paragraphStyle:(CGFloat)minimumLineHeight lineSpace:(CGFloat)lineSpace {
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paragraphStyle.lineSpacing = lineSpace;
    //不需要最小行高
    //paragraphStyle.minimumLineHeight = minimumLineHeight;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    [content yy_setParagraphStyle:paragraphStyle range:NSMakeRange(0, content.length)];
    self.attributedText = content;
}

@end
