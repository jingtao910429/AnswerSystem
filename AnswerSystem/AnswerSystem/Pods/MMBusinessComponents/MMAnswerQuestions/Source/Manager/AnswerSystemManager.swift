//
//  AnswerSystemManager.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/3/29.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import YYText
import MMBaseComponents
import MMToolHelper

let imageDefaultWidth = CGFloat(120.0)
let imageDefuatlHeight = CGFloat(120.0)

public enum AnswerSystemManagerType {
    //默认
    case normal
    //连线
    case match
    //选择
    case option
}

class AnswerSystemManager: NSObject {
    
    static let shared = AnswerSystemManager()
    
    //标识富文本是否只包含换行符
    var isOnlyNewLine = true
    
    func richText() -> NSMutableAttributedString {
        let text = NSMutableAttributedString()
        return text
    }
    
    //MARK: RichText
    func richText(richText: YYLabel, model: RichTextContentModel?, topicType: ExerciseStyle? = nil, answerSystemType: AnswerSystemManagerType = .normal, isAnswerParse: Bool = false) -> [[TextAttachmentContent]] {
        
        var options: [[TextAttachmentContent]] = []
        
        guard let model = model else {
            return options
        }
        
        isOnlyNewLine = true
        
        let contentLabel = richText
        contentLabel.objectId = model.objectId
        
        var startText = NSAttributedString()
        if let text = richText.attributedText {
            startText = text
        }
        
        let contentAttributeText = NSMutableAttributedString(attributedString: startText)
        
        //统计空格个数
        var emptyViewCount = 0
        for content in model.content {
            
            let type = content.type
            
            switch type {
            case 3...6:
                emptyViewCount += 1
            default:
                break
            }
            
        }
        
        var emptyViewIndex = 0
        for var content in model.content {
            
            let type = content.type
            
            switch type {
            case 1:
                let text = content.txt
                if text != "" && text != "\u{200b}" {
                    
                    if text != "\n" {
                        isOnlyNewLine = false
                    }
                    
                    let attributeText = NSMutableAttributedString(string: "\(text)")
                    
                    //Font_Size
                    var fontSize = 16
                    if content.fontSize != "", let font_size = content.fontSize.intValue() {
                        fontSize = font_size
                    }
                    
                    if isAnswerParse && text != "\n" {
                        fontSize = 14
                        content.isUnderline = 1
                        content.fontColor = "#ff6864"
                    }
                    
                    if content.isUnderline == 1 {
                        attributeText.addAttributeUnderlineStyle(CTUnderlineStyle.single, modifier: CTUnderlineStyleModifiers.patternSolid)
                    }
                    
                    //Bold - Italic
                    if content.isBold {
                        if content.isItalic {
                            attributeText.addAttributeFont(UIFont(name: "Arial-BoldItalicMT", size: CGFloat(fontSize)))
                        } else {
                            attributeText.addAttributeFont(UIFont.boldSystemFont(ofSize: CGFloat(fontSize)))
                        }
                    } else {
                        if content.isItalic {
                            attributeText.addAttributeFont(UIFont.italicSystemFont(ofSize: CGFloat(fontSize)))
                        } else {
                            attributeText.addAttributeFont(UIFont.systemFont(ofSize: CGFloat(fontSize)))
                        }
                    }
                    
                    //Font_Color
                    if content.fontColor != "" {
                        attributeText.addAttributeTextColor(UIColor(hex: content.fontColor))
                    } else {
                        attributeText.addAttributeTextColor(UIColor(hex: "#484848"))
                    }
                    
                    if content.bgColor != "", let bgColor = UIColor(hex: content.bgColor) {
                        attributeText.addAttributeBackGroundColor(bgColor)
                    }
                    
                    //0.正常文本 1.superscript上标文本 2.subscript下标文本
                    let range = NSRange(location: 0, length: text.len)
                    if content.scriptType != 0 {
                        var superScript = -Double(fontSize)
                        if content.scriptType == 1 {
                            superScript = Double(fontSize)
                        }
                        attributeText.yy_setSuperscript(NSNumber(value: superScript), range: range)
                        //attributeText.yy_setBaselineOffset(NSNumber(value: superScript), range: range)
                    }
                    
                    contentAttributeText.append(attributeText)
                    
                }
            case 2:
                
                isOnlyNewLine = false
                
                let imageStorage = UIImageView()
                
                /*
                if answerSystemType == .match || answerSystemType == .option {
                    imageStorage.addRichTextTapGesture(tapNumber: 2) { [weak self] (tap) in
                        guard let _ = self else {
                            return
                        }
                        NotificationCenter.default.post(name: MMAnswerSystemPhotoBrowserNotification, object: content.feImg)
                    }
                } else {
                    imageStorage.addRichTextTapGesture(action: { [weak self] (tap) in
                        guard let _ = self else {
                            return
                        }
                        NotificationCenter.default.post(name: MMAnswerSystemPhotoBrowserNotification, object: content.feImg)
                    })
                }*/
                
                imageStorage.addRichTextTapGesture(tapNumber: 2) { [weak self] (tap) in
                    guard let _ = self else {
                        return
                    }
                    NotificationCenter.default.post(name: MMAnswerSystemPhotoBrowserNotification, object: content.feImg)
                }
                
                
                let imageSize: CGSize = AnswerSystemHelper.formateImage(url: content.feImg, formateWidth: content.width, answerSystemType: answerSystemType)
                
                let width = imageSize.width
                let height = imageSize.height
                
                if content.feImg != "" {
                    if let _ = URL(string: content.feImg) {
                        imageStorage.image(withUrlString: content.feImg)
                    }
                    if answerSystemType != .match && content.width != "" {
                        richText.layoutIfNeeded()
                    }
                }
                
                imageStorage.size = CGSize(width: width, height: height)
                imageStorage.frame = CGRect(x: 0, y: 0, width: width, height: height)
                
                let optionAttribute = NSMutableAttributedString.yy_attachmentString(withContent: imageStorage, contentMode: .left, attachmentSize: imageStorage.size, alignTo: UIFont.systemFont(ofSize: 16), alignment: .center)
                contentAttributeText.append(optionAttribute)
                
            case 3...6:
                
                isOnlyNewLine = false
                
                emptyViewIndex += 1
                
                let height = 35.0
                var width = 60.0
                
                if content.length != "" && topicType == .Fill {
                    let caculateWidth = CGFloat(content.length.doubleValue() ?? 0.0)
                    if caculateWidth >= 60.0 && caculateWidth < DeviceInfo.screenWidth() - 30 {
                        
                        width = Double(caculateWidth)
                    } else if caculateWidth > DeviceInfo.screenWidth() - 30 {
                        width = Double(DeviceInfo.screenWidth() - 30)
                    }
                }
                let view = ChooseEmptyView(frame: CGRect(x: 0, y: 0, width: width, height: height))
                view.loadData(style: topicType, chooseEmptyIndex: options.count, richTextContent: content)
                view.sizeToFit()
                
                let tattachment = YYTextAttachment(content: view)
                
                let textContent = TextAttachmentContent()
                textContent.range = NSRange(location: 0, length: 1)
                textContent.textContent = tattachment
                options.append([textContent])
                
                if topicType == .EggIntoBaskets
                    || topicType == .WriteUploadImage {
                    continue
                }
                
                let border = YYTextBorder()
                border.strokeColor = UIColor.clear
                border.strokeWidth = 1.0
                border.fillColor = RTBackGroundColor
                border.cornerRadius = 4
                border.insets = UIEdgeInsetsMake(0, 0, 0, 0)
                
                let optionAttribute = NSMutableAttributedString.yy_attachmentString(withContent: tattachment.content, contentMode: .left, attachmentSize: CGSize(width: width, height: height), alignTo: UIFont.systemFont(ofSize: 16), alignment: .center)
                
                optionAttribute.yy_setTextBackgroundBorder(border, range: NSRange(location: 0, length: optionAttribute.length))
                
                contentAttributeText.append(optionAttribute)
                
                if emptyViewIndex < emptyViewCount {
                    let spaceView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 35.0))
                    spaceView.sizeToFit()
                    
                    let spaceAttribute = NSMutableAttributedString.yy_attachmentString(withContent: spaceView, contentMode: .left, attachmentSize: spaceView.size, alignTo: UIFont.systemFont(ofSize: 16), alignment: .center)
                    contentAttributeText.append(spaceAttribute)
                }
            
            case 8:
                //音频 + 提示
                
                isOnlyNewLine = false
                
                var audioWidth = CGFloat(50)
                var audioHeight = CGFloat(40)
                
                let audioView = RichTextAudioView(frame: CGRect(x: 0, y: 0, width: audioWidth, height: audioHeight))
                audioView.loadData(content: content)
                
                if content.feImg != "" {
                    
                    if let image = UIImage(imageUrl: content.feImg) {
                        
                        let imageWidth = CGFloat(image.size.width)
                        let imageHeight = CGFloat(image.size.height)
                        
                        let scale = imageHeight / imageWidth
                        
                        if content.width != "" && content.height != "" {
                            audioWidth = CGFloat(content.width.doubleValue() ?? 0.0 + 10.0)
                            audioHeight = CGFloat(content.height.doubleValue() ?? 0.0 + 10.0)
                        }
                        
                        audioHeight = audioWidth * CGFloat(scale)
                    }
                    
                }
                
                audioView.frame = CGRect(x: 0, y: 0, width: audioWidth, height: audioHeight)
                
                let audioAttribute = NSMutableAttributedString.yy_attachmentString(withContent: audioView, contentMode: .left, attachmentSize: audioView.size, alignTo: UIFont.systemFont(ofSize: 16), alignment: .center)
                contentAttributeText.append(audioAttribute)
                
                if content.tips != "" {
                    
                    let text = content.tips
                    let attributeText = NSMutableAttributedString(string: "\(text)")
                    
                    //Font_Size
                    var fontSize = 16
                    if content.tipsFontSize != "", let font_size = content.tipsFontSize.intValue() {
                        fontSize = font_size
                        
                        if content.tipsIsItalic {
                            attributeText.addAttributeFont(UIFont.italicSystemFont(ofSize: CGFloat(fontSize)))
                        } else {
                            attributeText.addAttributeFont(UIFont.systemFont(ofSize: CGFloat(fontSize)))
                        }
                    }
                    
                    if content.tipsColor != "" {
                        attributeText.addAttributeTextColor(UIColor(hex: content.tipsColor))
                    } else {
                        attributeText.addAttributeTextColor(UIColor(hex: "#484848"))
                    }
                    
                    contentAttributeText.append(attributeText)
                }
                
            default:
                break
            }
        }
        
        contentLabel.attributedText = contentAttributeText
        contentLabel.defaultParagraphStyle()
        contentLabel.sizeToFit()
        
        return options
    }
    
    fileprivate func padding() -> NSMutableAttributedString {
        let padding = NSMutableAttributedString(string: "\n\n")
        padding.yy_font = UIFont.systemFont(ofSize: 30)
        return padding
    }
}

