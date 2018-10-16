//
//  AnswerSystemHelper.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/3/30.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import YYText
import ObjectMapper
import MMToolHelper

func bundleImage(name: String) -> UIImage?  {
    return AnswerSystemHelper.shared.imageSource(name: name)
}

open class AnswerSystemHelper: NSObject {
    
    static public let shared = AnswerSystemHelper()
    
    static public let kRichTextNotificationUploadSuccessComplete = "RichTextNotificationUploadSuccessComplete"
    
    public func imageSource(name: String) -> UIImage? {
        let srcName = "MMAnswerQuestions.bundle/\(name)"
        let frameworkSrcName = "Frameworks/MMBusinessComponents.framework/MMAnswerQuestions.bundle/\(name)"
        var image = UIImage(named: srcName)
        if image == nil {
            image = UIImage(named: frameworkSrcName)
        }
        return image
    }
    
    public func bundlePath(name: String) -> String {
        return "\(Bundle(for: AnswerSystemHelper.self).bundlePath)/MMAnswerQuestions.bundle/\(name)"
    }
    
    public func substrings(string: String) -> [String] {
        var strings: [String] = []
        if string == "" {
            return strings
        }
        var content = NSString(string: string)
        while(content.length != 1) {
            let sub = content.substring(to: 1)
            if content.length != 1 {
                content = content.substring(from: 1) as NSString
            }
            strings.append(sub)
        }
        strings.append(content as String)
        return strings
    }
    
    static public func modifyStatusNotificationPost() {
        NotificationCenter.default.post(name: MMAnswerSystemExerciseObjectModifyStatusUpdate, object: nil, userInfo: nil)
    }
    
    static public func formateImage(url: String, formateWidth: String, answerSystemType: AnswerSystemManagerType) -> CGSize {
        
        var imageSize: CGSize = CGSize.zero
        if answerSystemType == .normal {
            imageSize = CGSize(width: imageDefaultWidth, height: imageDefuatlHeight)
        } else if answerSystemType == .match {
            imageSize = CGSize(width: JionLineTextBtnMaxWidth, height: JionLineTextBtnMaxHeight)
        }
        
        var width = imageSize.width
        var height = imageSize.height
        
        if url != "" {
            
            var imageWidth = CGFloat(width)
            var imageHeight = CGFloat(height)
            
            if let image = UIImage(imageUrl: url) {
                
                imageWidth = CGFloat(image.size.width)
                imageHeight = CGFloat(image.size.height)
                
            }
            
            let scale = imageHeight / imageWidth
            
            if answerSystemType == .match {
                width = JionLineTextBtnWidth
            } else {
                let maxWidth = DeviceInfo.isPad() ? (DeviceInfo.adaptScreenWidth() - iPadTabWidth) * (1 - GoldScale) - 40 : DeviceInfo.adaptScreenWidth() - 40
                if formateWidth != "" {
                    width = CGFloat(formateWidth.doubleValue() ?? 0.0)
                    if width > maxWidth {
                        width = maxWidth
                    }
                } else {
                    //默认图片大小
                    if imageWidth > maxWidth {
                        width = maxWidth
                    } else {
                        width = CGFloat(imageWidth)
                    }
                }
            }
            
            height = width * CGFloat(scale)
        }
        
        return CGSize(width: width, height: height)
    }
    
}

open class RichTextBlockTap: UITapGestureRecognizer {
    private var tapAction: ((UITapGestureRecognizer) -> Void)?
    
    public override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
    
    public convenience init (
        tapCount: Int = 1,
        fingerCount: Int = 1,
        action: ((UITapGestureRecognizer) -> Void)?) {
        self.init()
        self.numberOfTapsRequired = tapCount
        
        #if os(iOS)
            
            self.numberOfTouchesRequired = fingerCount
            
        #endif
        
        self.tapAction = action
        self.addTarget(self, action: #selector(RichTextBlockTap.didTap(_:)))
    }
    
    @objc open func didTap (_ tap: UITapGestureRecognizer) {
        tapAction? (tap)
    }
}

//NSRange -> Range
extension String {
    func transNSRange(_ range: Range<String.Index>) -> NSRange {
        guard let from = range.lowerBound.samePosition(in: utf16), let to = range.upperBound.samePosition(in: utf16) else {
            return NSMakeRange(0, 0)
        }
        let ttrange = NSMakeRange(utf16.distance(from: utf16.startIndex, to: from), utf16.distance(from: from, to: to))
        print(ttrange)
        return NSMakeRange(utf16.distance(from: utf16.startIndex, to: from), utf16.distance(from: from, to: to))
    }
    
    func transRange(_ range: NSRange) -> Range<String.Index>? {
        guard let from16 = utf16.index(utf16.startIndex, offsetBy: range.location, limitedBy: utf16.endIndex) else { return nil }
        guard let to16 = utf16.index(from16, offsetBy: range.length, limitedBy: utf16.endIndex) else { return nil }
        guard let from = String.Index(from16, within: self) else { return nil }
        guard let to = String.Index(to16, within: self) else { return nil }
        return from ..< to
    }
    
    public func intValue() -> Int? {
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return nil
        }
    }
    
    public func boolValue() -> Bool? {
        if let num = NumberFormatter().number(from: self) {
            return num.boolValue
        } else {
            return nil
        }
    }
    
    public func doubleValue() -> Double? {
        if let num = NumberFormatter().number(from: self) {
            return num.doubleValue
        } else {
            return nil
        }
    }
    
    public var len: Int {
        return self.characters.count
    }
}

extension UIColor {
    
    public convenience init?(hex: String, alpha: CGFloat = 1.0) {
        var formatted = hex.replacingOccurrences(of: "0x", with: "")
        formatted = formatted.replacingOccurrences(of: "#", with: "")
        if let hex = Int(formatted, radix: 16) {
            let red = CGFloat(CGFloat((hex & 0xFF0000) >> 16)/255.0)
            let green = CGFloat(CGFloat((hex & 0x00FF00) >> 8)/255.0)
            let blue = CGFloat(CGFloat((hex & 0x0000FF) >> 0)/255.0)
            self.init(red: red, green: green, blue: blue, alpha: alpha)        } else {
            return nil
        }
    }
}

extension UIImage {
    
    public convenience init?(imageUrl: String) {
        guard let url = URL(string: imageUrl) else {
            self.init(data: Data())
            return
        }
        guard let data = try? Data(contentsOf: url) else {
            print("EZSE: No image in URL \(imageUrl)")
            self.init(data: Data())
            return
        }
        self.init(data: data)
    }
    
}

extension UIView {
    
    public func richTextShadow(_ color: UIColor = UIColor.black,
                shadowOpacity: Float = 0.2,
                shadowRadius: CGFloat = 2,
                shadowOffset: CGSize = CGSize(width: 0, height: 1)) {
        self.layer.shadowColor = color.cgColor // 阴影的颜色
        self.layer.shadowOpacity = shadowOpacity // 阴影透明
        self.layer.shadowRadius = shadowRadius //// 阴影扩散的范围控制
        self.layer.shadowOffset = shadowOffset // 阴影的范围
        self.layer.shouldRasterize = false
    }
    
    public func richTextCornerRadius(cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
    
    public func richTextClearCornerRadius() {
        self.layer.cornerRadius = 0
        self.layer.masksToBounds = true
    }
    
    public func richTextCornerRadiusShadow(cornerRadius: CGFloat) -> UIView {
        
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        
        let ownerView = UIView()
        ownerView.addSubview(self)
        self.snp.remakeConstraints { (make) in
            make.edges.equalTo(ownerView)
        }
        ownerView.richTextShadow()
        return ownerView
    }
    
    public func addRichTextTapGesture(tapNumber: Int = 1, target: AnyObject, action: Selector) {
        let tap = UITapGestureRecognizer(target: target, action: action)
        tap.numberOfTapsRequired = tapNumber
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
    public func addRichTextTapGesture(tapNumber: Int = 1, action: ((UITapGestureRecognizer) -> Void)?) {
        let tap = RichTextBlockTap(tapCount: tapNumber, fingerCount: 1, action: action)
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
    public var richTextX: CGFloat {
        get {
            return self.frame.origin.x
        } set(value) {
            self.frame = CGRect(x: value, y: self.y, width: self.richTextW, height: self.richTextH)
        }
    }
    
    public var richTextY: CGFloat {
        get {
            return self.frame.origin.y
        } set(value) {
            self.frame = CGRect(x: self.x, y: value, width: self.richTextW, height: self.richTextH)
        }
    }
    
    public var richTextW: CGFloat {
        get {
            return self.frame.size.width
        } set(value) {
            self.frame = CGRect(x: self.x, y: self.y, width: value, height: self.richTextH)
        }
    }
    
    public var richTextH: CGFloat {
        get {
            return self.frame.size.height
        } set(value) {
            self.frame = CGRect(x: self.x, y: self.y, width: self.richTextW, height: value)
        }
    }
    
    public var bottom: CGFloat {
        get {
            return self.richTextY + self.richTextH
        } set(value) {
            self.richTextY = value - self.richTextH
        }
    }
    
    public func clearConstraints() {
        self.snp.removeConstraints()
        self.translatesAutoresizingMaskIntoConstraints = true
    }
    
}

//YYLabel - Associate_Object
extension YYLabel {
    
    private struct AssociatedKeys {
        static var YYAssociateObjectID = "YYLabel.Object_ID"
    }
    
    var objectId: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.YYAssociateObjectID) as? String
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.YYAssociateObjectID,
                    newValue as String?,
                    .OBJC_ASSOCIATION_COPY_NONATOMIC
                )
            }
        }
    }
}


extension Array{
    mutating func randamArray() -> Array {
        var list = self
        for index in 0..<list.count{
            let newIndex = Int(arc4random_uniform(UInt32(list.count-index))) + index
            if index != newIndex {
                list.swapAt(index, newIndex)
            }
        }
        self = list
        return list
    }
}
