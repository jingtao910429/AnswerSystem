//
//  ChooseOptionView.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/9.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import YYText

enum ChooseOptionType {
    case image
    case text
}

typealias ChooseOptionLongPressMoveBlock = ((ChooseOptionView) -> Void)
typealias SelectOptionAction = ((UIButton, ChooseOptionView) -> Void)

public class ChooseOptionView: UIView {
    
    fileprivate var btnWidth = CGFloat(50)
    fileprivate var btnHeight = CGFloat(35)
    fileprivate var btnLRMargin = CGFloat(10)
    fileprivate var btnTBMargin = CGFloat(6)
    
    fileprivate var panPress: UIPanGestureRecognizer!
    fileprivate var startPoint: CGPoint = CGPoint.zero
    fileprivate var startInterfaceTuple: (UIColor, CGColor)?
    
    fileprivate var style: ExerciseStyle = .None
    fileprivate var optionRichText: YYLabel!
    fileprivate var dragRichText: YYLabel!
    
    var optionButton: UIButton!
    var optionImageView: UIImageView!
    var dragButton: UIButton = UIButton()
    var dragImageView: UIImageView!
    
    var isAnswerParse = false {
        didSet {
            makeConstraints(margin: isAnswerParse ? 2 : btnLRMargin, padding: isAnswerParse ? 2 : btnTBMargin)
        }
    }
    
    var richTextContent: RichTextContent? {
        didSet {
            if let _ = richTextContent {
                
            }
        }
    }
    
    var topicOptionsModel: TopicOptionsModel? {
        didSet {
            if let model = topicOptionsModel {
                //连词成句。如果当前topicOptionsModel的index为空，表示index标识不在该结构下，取值需要修改
                if model.index == "" {
                    topicOptionsModel?.index = subTopicOptionModel?.index ?? ""
                }
            }
        }
    }
    
    var subTopicOptionModel: TopicOptionSubOptionModel? {
        didSet {
            if let _ = subTopicOptionModel {
                
            }
        }
    }
    
    var isGray: Bool = false {
        didSet {
            if isGray {
                
                //变灰禁止拖动
                optionButton.isUserInteractionEnabled = false
                dragButton.isUserInteractionEnabled = false
                dragButton.isSelected = true
                
                dragButton.removeGestureRecognizer(panPress)
                if self.style != .EggIntoBaskets {
                    
                    addGrayAttribute(richText: optionRichText, color: UIColor(hex: "#A7A7A7")!)
                    addGrayAttribute(richText: dragRichText, color: UIColor(hex: "#A7A7A7")!)
                    
                    optionButton.backgroundColor = UIColor(hexString: "#DFDFDF")
                    dragButton.backgroundColor = UIColor(hexString: "#DFDFDF")
                }
                
            } else {
                
                optionButton.isUserInteractionEnabled = true
                dragButton.isUserInteractionEnabled = true
                dragButton.isSelected = false
                
                dragButton.addGestureRecognizer(panPress)
                
                if self.style != .EggIntoBaskets {
                    
                    addGrayAttribute(richText: optionRichText, color: RTTextColor)
                    addGrayAttribute(richText: dragRichText, color: RTTextColor)
                    
                    optionButton.backgroundColor = UIColor.white
                    dragButton.backgroundColor = UIColor.white
                }
            }
        }
    }
    
    var chooseOptionLongPressMoveBlock: ChooseOptionLongPressMoveBlock?
    var selectOptionAction: SelectOptionAction?
    
    func addGrayAttribute(richText: YYLabel, color: UIColor) {
        
        let attributeText = NSMutableAttributedString(attributedString: richText.attributedText!)
        attributeText.addAttributeTextColor(color)
        richText.attributedText = attributeText
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        optionButton = UIButton()
        optionButton.setTitleColor(RTTextColor, for: .normal)
        optionButton.titleLabel?.numberOfLines = 0
        optionButton.isSelected = false
        addSubview(optionButton)
        
        optionRichText = YYLabel()
        optionRichText.preferredMaxLayoutWidth = 100
        optionRichText.numberOfLines = 0
        optionButton.addSubview(optionRichText)
        
        optionImageView = UIImageView()
        optionImageView.image = #imageLiteral(resourceName: "course_check")
        optionImageView.isHidden = true
        optionButton.addSubview(optionImageView)
        
        dragButton = UIButton()
        dragButton.setTitleColor(RTTextColor, for: .normal)
        dragButton.titleLabel?.numberOfLines = 0
        dragButton.isSelected = false
        dragButton.addTarget(self, action: #selector(selectButtonAction), for: .touchUpInside)
        addSubview(dragButton)
        
        dragRichText = YYLabel()
        dragRichText.preferredMaxLayoutWidth = 100
        dragRichText.isUserInteractionEnabled = true
        dragRichText.numberOfLines = 0
        dragRichText.addRichTextTapGesture(target: self, action: #selector(selectButtonAction))
        dragButton.addSubview(dragRichText)
        
        dragImageView = UIImageView()
        dragImageView.image = #imageLiteral(resourceName: "course_check")
        dragImageView.isHidden = true
        dragButton.addSubview(dragImageView)
        
        panPress = UIPanGestureRecognizer(target: self, action: #selector(panPress(_:)))
        dragButton.addGestureRecognizer(panPress)
        
        makeConstraints(margin: btnLRMargin, padding: btnTBMargin)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeConstraints(margin: CGFloat, padding: CGFloat) {
        
        optionRichText.snp.remakeConstraints { (make) in
            make.top.equalTo(padding)
            make.bottom.equalTo(-padding)
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            
        }
        
        optionImageView.snp.remakeConstraints { (make) in
            make.bottom.equalTo(0)
            make.right.equalTo(0)
            make.height.width.equalTo(20)
        }
        
        dragRichText.snp.remakeConstraints { (make) in
            make.top.equalTo(padding)
            make.bottom.equalTo(-padding)
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
        }
        
        dragImageView.snp.remakeConstraints { (make) in
            make.bottom.equalTo(0)
            make.right.equalTo(0)
            make.height.width.equalTo(20)
        }
        
    }
    
    @objc func selectButtonAction() {
        self.selectOptionAction?(dragButton, self)
    }
    
    //长按拖动
    @objc func panPress(_ panPress: UIPanGestureRecognizer) {
        
        if let view = panPress.view {
            if panPress.state == .began {
                startPoint = panPress.location(in: view)
                startInterfaceTuple = (view.backgroundColor, view.layer.borderColor) as? (UIColor, CGColor)
                UIView.animate(withDuration: 0.5, animations: {
                    view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    view.alpha = 0.7
                    view.backgroundColor = UIColor(hexString: "#edffff")
                    view.layer.borderColor = RTThemeColor.cgColor
                })
            } else if panPress.state == .changed {
                
                let newPoint = panPress.location(in: view)
                let deltaX = newPoint.x - startPoint.x
                let deltaY = newPoint.y - startPoint.y
                view.center = CGPoint(x: view.center.x + deltaX, y: view.center.y + deltaY)
                
            } else if panPress.state == .ended {
                UIView.animate(withDuration: 0.5, animations: {
                    view.transform = CGAffineTransform.identity
                    view.alpha = 1.0
                    view.backgroundColor = self.startInterfaceTuple?.0 ?? UIColor.white
                    view.layer.borderColor = self.startInterfaceTuple?.1 ?? RTOptionBorderColor.cgColor
                })
                self.chooseOptionLongPressMoveBlock?(self)
                
                view.center = optionButton.center
            }
        }
        
    }
    
    func stopLongAction() {
        dragButton.removeGestureRecognizer(panPress)
    }
    
    func refreshUI(style: ExerciseStyle, isSelected: Bool) {
        optionButton.isSelected = isSelected
        dragButton.isSelected = isSelected
        switch style {
        case .ChooseShowCode, .ChooseShowCodeOnePosition:
            setButtonLayer(button: optionButton, isSelected: isSelected)
            setButtonLayer(button: dragButton, isSelected: isSelected)
            break
        default:
            break
        }
    }
    
    func loadData(style: ExerciseStyle, subTopicOptionModel: TopicOptionSubOptionModel, buttonWidth: CGFloat? = CGFloat(0)) {
        self.subTopicOptionModel = subTopicOptionModel
        loadData(style: style, topicOptionsModel: subTopicOptionModel.option, buttonWidth: buttonWidth)
    }

    func loadData(style: ExerciseStyle, topicOptionsModel: TopicOptionsModel?, buttonWidth: CGFloat? = CGFloat(0)) {
        self.style = style
        self.topicOptionsModel = topicOptionsModel
        self.richTextContent = topicOptionsModel?.richtext?.content.first
        
        var title = richTextContent?.txt ?? ""
        
        if let topicOptionsModel = topicOptionsModel {
            
            switch style {
            case .ChooseFillShowCode, .ChooseFillShowCodeOnePosition, .ChooseShowCode, .ChooseShowCodeOnePosition:
                title = "\(topicOptionsModel.index)"
            default:
                break
            }
        }
        
        if style == .EggIntoBaskets {
            optionRichText.isHidden = true
            dragRichText.isHidden = true
            eggInnerLoadData(button: optionButton, title: title)
            eggInnerLoadData(button: dragButton, title: title)
        } else {
            optionRichText.isHidden = false
            dragRichText.isHidden = false
            innerLoadData(button: optionButton, title: title, buttonWidth: buttonWidth)
            innerLoadData(button: dragButton, title: title, buttonWidth: buttonWidth)
        }
        
    }
    
    fileprivate func eggInnerLoadData(button: UIButton, title: String) {
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(RTTextColor, for: .normal)
        button.titleLabel?.font = RTNormalFont
        button.setBackgroundImage(bundleImage(name: "exercise_egg"), for: .normal)
        button.setBackgroundImage(bundleImage(name: "exercise_egg_sel"), for: .selected)
        
        let eggImage = bundleImage(name: "exercise_egg")!
        
        btnWidth = eggImage.size.width < 45 ? eggImage.size.width : 45
        btnHeight = eggImage.size.height / eggImage.size.width * btnWidth
        
        self.width = btnWidth
        self.height = btnHeight
        button.snp.remakeConstraints { (make) in
            make.edges.equalTo(0)
            make.width.equalTo(btnWidth)
            make.height.equalTo(btnHeight)
        }
        self.sizeToFit()
    }
    
    fileprivate func innerLoadData(button: UIButton, title: String, buttonWidth: CGFloat? = CGFloat(0)) {
        
        var isShowCode = false
        switch style {
        case .ChooseFillShowCode, .ChooseFillShowCodeOnePosition, .ChooseShowCode, .ChooseShowCodeOnePosition:
            isShowCode = true
            break
        default:
            break
        }
        
        var richText: YYLabel = optionRichText
        
        let attributeText = NSMutableAttributedString(string: "\(title)  ")
        attributeText.addAttributeFont(RTBoldNormalFont)
        attributeText.addAttributeTextColor(UIColor(hex: "#415373"))
        
        if button == optionButton {
            richText = optionRichText
            if isShowCode {
                richText.attributedText = attributeText
            }
            let _ = AnswerSystemManager.shared.richText(richText: optionRichText, model: topicOptionsModel?.richtext, answerSystemType: .option, isAnswerParse: isAnswerParse)
        } else {
            richText = dragRichText
            if isShowCode {
                richText.attributedText = attributeText
            }
            let _ = AnswerSystemManager.shared.richText(richText: dragRichText, model: topicOptionsModel?.richtext, answerSystemType: .option, isAnswerParse: isAnswerParse)
        }
        
        setButtonLayer(button: button, isSelected: false)
        
        let bestSize = richText.sizeThatFits(CGSize(width: Int.max, height: Int.max))
        
        btnWidth = isAnswerParse ? bestSize.width + 2 * 5 : bestSize.width + 2 * btnLRMargin
        btnHeight = isAnswerParse ? bestSize.height + 2 * 2 : bestSize.height + 2 * btnTBMargin
        
        if isShowCode {
            btnWidth = (buttonWidth ?? 0) + 2 * btnLRMargin
        }
        
        if let buttonWidth = buttonWidth, btnWidth > buttonWidth {
            
            btnWidth = buttonWidth
            
            let heightBestSize = richText.sizeThatFits(CGSize(width: Int(btnWidth - 2 * btnLRMargin), height: Int.max))
            btnHeight = heightBestSize.height + 2 * btnTBMargin
            
            //默认值
            if btnHeight < 40 && btnHeight > 30 {
                btnHeight = 50
            } else if btnHeight < 30 {
                btnHeight = 35
                if self.style == .ChooseShowCode
                    || self.style == .ChooseShowCodeOnePosition {
                    btnHeight = 40
                }
            } else {
                btnHeight += 10
            }

        } else {
            
            var minBtnWidth = CGFloat(65)
            if isAnswerParse {
                minBtnWidth = CGFloat(35)
            }
            
            if btnWidth < minBtnWidth {
                btnWidth = minBtnWidth
            }
            
            let maxHeight = isAnswerParse ? 25 : 35
            if btnHeight < CGFloat(maxHeight) {
                btnHeight = CGFloat(maxHeight)
            }
            
        }
        
        self.width = btnWidth
        self.height = btnHeight
        
        richText.textAlignment = isShowCode ? .left : .center
        button.snp.remakeConstraints { (make) in
            make.edges.equalTo(0)
            make.width.equalTo(self.width)
            make.height.equalTo(self.height)
        }
    }
    
    fileprivate func resetRichTextMargin(margin: CGFloat, richText: YYLabel) {
        richText.snp.remakeConstraints { (make) in
            make.top.equalTo(btnTBMargin)
            make.left.equalTo(margin)
            make.right.equalTo(-margin)
            make.bottom.equalTo(-btnTBMargin)
        }
    }
    
    fileprivate func setButtonLayer(button: UIButton, isSelected: Bool) {
        
        button.backgroundColor = UIColor.white
        if !isAnswerParse {
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 0.5
        } else {
            button.layer.cornerRadius = 0
            button.layer.borderWidth = 0
        }
        
        if isSelected {
            button.layer.borderColor = RTThemeColor.cgColor
            button.backgroundColor = UIColor(hexString: "#EDFFFF")
            optionImageView.isHidden = false
            dragImageView.isHidden = false
        } else {
            button.layer.borderColor = RTOptionBorderColor.cgColor
            button.backgroundColor = UIColor.white
            optionImageView.isHidden = true
            dragImageView.isHidden = true
        }
        
        button.layer.masksToBounds = true
    }
    
}
