//
//  MMDrawStorage.m
//  MMAttributedLabelDemo
//
//  Created by tanyang on 15/4/8.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "MMDrawStorage.h"
#import <CoreText/CoreText.h>

NSString *const kMMTextRunAttributedName = @"MMTextRunAttributedName";

@interface MMDrawStorage () {
    CGFloat         _fontAscent;
    CGFloat         _fontDescent;
    NSRange         _fixRange;
}
@end

@implementation MMDrawStorage

#pragma mark - protocol

- (void)currentReplacedStringNum:(NSInteger)replacedStringNum
{
    _fixRange = [self fixRange:_range replaceStringNum:replacedStringNum];
}

- (void)setTextfontAscent:(CGFloat)ascent descent:(CGFloat)descent;
{
    _fontAscent = ascent;
    _fontDescent = -descent;
}

- (void)addTextStorageWithAttributedString:(NSMutableAttributedString *)attributedString
{
    NSRange range = _fixRange;
    if (range.location == NSNotFound) {
        return;
    }else {
        // 用空白替换
        [attributedString replaceCharactersInRange:range withString:[self spaceReplaceString]];
        // 修正range
        range = NSMakeRange(range.location, 1);
        _realRange = range;
    }
    
    // 设置合适的对齐
    [self setAppropriateAlignment];
    
    // 添加文本属性和runDelegate
    [self addRunDelegateWithAttributedString:attributedString range:range];
}

- (NSAttributedString *)appendTextStorageAttributedString
{
    // 创建空字符属性文本
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:[self spaceReplaceString]];
    // 修正range
    _range = NSMakeRange(0, 1);
    
    // 设置合适的对齐
    [self setAppropriateAlignment];
    
    // 添加文本属性和runDelegate
    [self addRunDelegateWithAttributedString:attributedString range:_range];
    return attributedString;
}

- (void)drawStorageWithRect:(CGRect)rect
{
    
}

#pragma mark - public

- (CGFloat)getDrawRunAscentHeight
{
    CGFloat ascent = 0;
    CGFloat height = self.size.height+_margin.bottom+_margin.top;
    switch (_drawAlignment)
    {
        case MMDrawAlignmentTop:
            ascent = height - _fontDescent;
            break;
        case MMDrawAlignmentCenter:
        {
            CGFloat baseLine = (_fontAscent + _fontDescent) / 2 - _fontDescent;
            ascent = height / 2 + baseLine;
            break;
        }
        case MMDrawAlignmentBottom:
            ascent = _fontAscent;
            break;
        default:
            break;
    }
    return ascent;
}

- (CGFloat)getDrawRunWidth
{
    return self.size.width+_margin.left+_margin.right;
}

- (CGFloat)getDrawRunDescentHeight
{
    CGFloat descent = 0;
    CGFloat height = self.size.height+_margin.bottom+_margin.top;
    switch (_drawAlignment)
    {
        case MMDrawAlignmentTop:
            descent = _fontDescent;
            break;
        case MMDrawAlignmentCenter:
        {
            CGFloat baseLine = (_fontAscent + _fontDescent) / 2 - _fontDescent;
            descent = height / 2 - baseLine;
            break;
        }
        case MMDrawAlignmentBottom:
            descent = height - _fontAscent;
            break;
        default:
            break;
    }
    
    return descent;
}

- (void)DrawRunDealloc
{
    
}

#pragma mark - private

- (NSString *)spaceReplaceString
{
    // 替换字符
    unichar objectReplacementChar           = 0xFFFC;
    NSString *objectReplacementString       = [NSString stringWithCharacters:&objectReplacementChar length:1];
    return objectReplacementString;
}

- (void)setAppropriateAlignment
{
    // 判断size 大小 小于 _fontAscent 把对齐设为中心 更美观
    if (_size.height <= _fontAscent + _fontDescent) {
        _drawAlignment = MMDrawAlignmentCenter;
    }
}

- (NSRange)fixRange:(NSRange)range replaceStringNum:(NSInteger)replaceStringNum
{
    NSRange fixRange = range;
    if (range.length <= 1 || replaceStringNum < 0)
        return fixRange;
    
    NSInteger location = range.location - replaceStringNum;
    NSInteger length = range.length - replaceStringNum;
    
    if (location < 0 && length > 0) {
        fixRange = NSMakeRange(range.location, length);
    }else if (location < 0 && length <= 0){
        fixRange = NSMakeRange(NSNotFound, 0);
    }else {
        fixRange = NSMakeRange(range.location - replaceStringNum, range.length);
    }
    return fixRange;
}

// 添加文本属性和runDelegate
- (void)addRunDelegateWithAttributedString:(NSMutableAttributedString *)attributedString range:(NSRange)range
{
    // 添加文本属性和runDelegate
    [attributedString addAttribute:kMMTextRunAttributedName value:self range:range];
    
    //为图片设置CTRunDelegate,delegate决定留给显示内容的空间大小
    CTRunDelegateCallbacks runCallbacks;
    runCallbacks.version = kCTRunDelegateVersion1;
    runCallbacks.dealloc = MMTextRunDelegateDeallocCallback;
    runCallbacks.getAscent = MMTextRunDelegateGetAscentCallback;
    runCallbacks.getDescent = MMTextRunDelegateGetDescentCallback;
    runCallbacks.getWidth = MMTextRunDelegateGetWidthCallback;
    
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&runCallbacks, (__bridge void *)(self));
    [attributedString addAttribute:(__bridge_transfer NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:range];
    CFRelease(runDelegate);
}

//CTRun的回调，销毁内存的回调
void MMTextRunDelegateDeallocCallback( void* refCon ){
    //MMDrawRun *textRun = (__bridge MMDrawRun *)refCon;
    //[textRun DrawRunDealloc];
}

//CTRun的回调，获取高度
CGFloat MMTextRunDelegateGetAscentCallback( void *refCon ){
    
    MMDrawStorage *drawStorage = (__bridge MMDrawStorage *)refCon;
    return [drawStorage getDrawRunAscentHeight];
}

CGFloat MMTextRunDelegateGetDescentCallback(void *refCon){
    MMDrawStorage *drawStorage = (__bridge MMDrawStorage *)refCon;
    return [drawStorage getDrawRunDescentHeight];
}

//CTRun的回调，获取宽度
CGFloat MMTextRunDelegateGetWidthCallback(void *refCon){
    
    MMDrawStorage *drawStorage = (__bridge MMDrawStorage *)refCon;
    return [drawStorage getDrawRunWidth];
}

@end
