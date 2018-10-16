//
//  YYLabel+ChangeLabel.h
//  MMBaseComponents
//
//  Created by Mac on 2018/3/29.
//

#import <YYText/YYText.h>
#import "TextAttachmentContent.h"

@interface YYLabel (ChangeLabel)

//设置对齐方式
- (void)defaultParagraphStyle;
- (void)paragraphStyle:(CGFloat)minimumLineHeight lineSpace:(CGFloat)lineSpace;
- (CGSize)textAttachmentSize:(id)attachment;
- (NSMutableAttributedString *)attchmentText:(TextAttachmentContent *)attachment contentSize:(CGSize)contentSize;

//删除某个组件
- (void)mm_deleteTextAttachment:(TextAttachmentContent *)attachment;
//替换方法可能为YYTextAttachment或者content实体类型
//该替换方法不改变原有所在的YYTextAttachment容器
- (void)mm_replaceTextAttachment:(TextAttachmentContent *)attachment original:(id)originalAttachment;
- (void)mm_replaceTextAttachment:(TextAttachmentContent *)attachment original:(id)originalAttachment border:(YYTextBorder *)border;
//插入方法同替换方法
- (void)mm_insertTextAttachment:(TextAttachmentContent *)attachment original:(id)originalAttachment;
- (void)mm_insertTextAttachment:(TextAttachmentContent *)attachment original:(id)originalAttachment isAddLength:(BOOL)isAddLength;
@end
