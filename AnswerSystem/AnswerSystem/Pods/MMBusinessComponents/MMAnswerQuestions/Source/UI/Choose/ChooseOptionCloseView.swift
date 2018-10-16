//
//  ChooseOptionCloseView.swift
//  MMBaseComponents
//
//  Created by Mac on 2018/4/25.
//

import UIKit
import YYText

enum ChooseOptionCloseType {
    case image
    case text
}

@objc protocol ChooseOptionCloseDelegate {
    @objc func chooseOptionCloseClick(button: UIButton, owner: ChooseOptionCloseView)
}

public class ChooseOptionCloseView: UIView {
    
    fileprivate var maxWidth = CGFloat(60)
    fileprivate var btnWidth = CGFloat(60)
    fileprivate var btnHeight = CGFloat(40)
    
    fileprivate var chooseBackView: UIView!
    fileprivate var optionRichText: YYLabel!
    fileprivate var optionButton: UIButton!
    
    weak var chooseOptionCloseDelegate: ChooseOptionCloseDelegate?
    
    //标准答案，默认标准答案和emptyView绑定，如果单选，emptyView为空，此时标准答案绑定在选项上
    var formateRichTextContent: RichTextContent? {
        didSet {
            if let _ = richTextContent {
                
            }
        }
    }
    
    //用户显示及答案
    var richTextContent: RichTextContent? {
        didSet {
            if let _ = richTextContent {
                
            }
        }
    }
    
    var topicOptionsModel: TopicOptionsModel? {
        didSet {
            if let _ = topicOptionsModel {
                
            }
        }
    }
    
    var isUserInteracted = true {
        didSet {
            optionButton.isUserInteractionEnabled = isUserInteracted
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true
        
        chooseBackView = UIView(frame: frame)
        chooseBackView.isUserInteractionEnabled = true
        addSubview(chooseBackView)
        
        optionButton = UIButton(frame: frame)
        optionButton.backgroundColor = UIColor.white
        optionButton.layer.cornerRadius = 5
        optionButton.layer.borderWidth = 0.5
        optionButton.layer.borderColor = RTOptionBorderColor.cgColor
        optionButton.layer.masksToBounds = true
        optionButton.addTarget(self, action: #selector(optionButtonClick), for: .touchUpInside)
        addSubview(optionButton)
        
        optionRichText = YYLabel()
        optionRichText.preferredMaxLayoutWidth = 200
        optionRichText.numberOfLines = 0
        optionRichText.isUserInteractionEnabled = true
        optionRichText.addRichTextTapGesture(target: self, action: #selector(optionButtonClick))
        optionButton.addSubview(optionRichText)
        
        makeConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeConstraints() {
        
        chooseBackView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        optionButton.snp.makeConstraints { (make) in
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.top.equalTo(5)
            make.bottom.equalTo(-5)
        }
        
        optionRichText.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.bottom.equalTo(-5)
        }
    }
    
    func answerParameters() -> RichParameterType {
        var parameters: RichParameterType = [:]
        parameters["scores"] = 0
        parameters["answer"] = answer()
        parameters["index"] = "\(inputBoxIdx())"
        return parameters
    }
    
    func loadData(style: ExerciseStyle, topicOptionsModel: TopicOptionsModel?, width: CGFloat) {
        
        self.maxWidth = width
        self.topicOptionsModel = topicOptionsModel
        self.richTextContent = topicOptionsModel?.richtext?.content.first
        
        var title = richTextContent?.txt ?? ""
        
        optionRichText.isHidden = true
        if let topicOptionsModel = topicOptionsModel, let richTextContent = richTextContent {
            
            switch style {
            case .ChooseFillShowCode, .ChooseFillShowCodeOnePosition, .ChooseShowCode, .ChooseShowCodeOnePosition:
                title = "\(topicOptionsModel.index)"
            case .AppendCharcterProduceSentence, .AppendCharcterProduceSentenceConditonOne:
                optionRichText.isHidden = false
                break
            default:
                title = "\(richTextContent.txt)"
            }
        }
        if style == .EggIntoBaskets {
            eggInnerLoadButton(button: optionButton, title: title)
        } else if (style == .AppendCharcterProduceSentence || style == .AppendCharcterProduceSentenceConditonOne) {
            appendSentenceLoadButton(button: optionButton)
        } else {
            innerLoadButton(button: optionButton, url: self.richTextContent?.feImg ?? "", title: title)
        }
    }
    
    fileprivate func eggInnerLoadButton(button: UIButton, title: String) {
        
        button.backgroundColor = UIColor.clear
        button.layer.borderColor = UIColor.clear.cgColor
        button.setTitle(title, for: .normal)
        button.setTitleColor(RTTextColor, for: .normal)
        button.titleLabel?.font = RTNormalFont
        
        let eggImage = bundleImage(name: "exercise_egg")!
        button.setBackgroundImage(eggImage, for: .normal)
        button.setBackgroundImage(bundleImage(name: "exercise_egg_sel"), for: .selected)
        
        btnWidth = eggImage.size.width < 45 ? eggImage.size.width : 45
        btnHeight = eggImage.size.height / eggImage.size.width * btnWidth
        
        self.frame = CGRect(x: 0, y: 0, width: btnWidth, height: btnHeight)
        optionButton.snp.remakeConstraints { (make) in
            make.edges.equalTo(0)
            make.width.equalTo(btnWidth)
            make.height.equalTo(btnHeight)
        }
    }
    
    fileprivate func innerLoadButton(button: UIButton, url: String, title: String) {
        let optionType = title == "" ? ChooseOptionCloseType.image : ChooseOptionCloseType.text
        switch optionType {
        case .image:
            if let image = bundleImage(name: "img_icon") {
                button.image(withUrlStr: url, phImage: image)
            }
        default:
            button.setTitle(title, for: .normal)
            button.setTitleColor(RTTextColor, for: .normal)
            button.titleLabel?.font = RTNormalFont
            button.backgroundColor = UIColor.white
            
            let attributes = [NSAttributedStringKey.font: RTNormalFont]
            
            btnWidth = title.boundingRect(with: CGSize(width: Int.max, height: 40), options:.usesLineFragmentOrigin, attributes: attributes, context:nil).size.width + 30
            btnHeight = 40
        }
        self.width = btnWidth
        self.height = btnHeight
        self.sizeToFit()
    }
    
    fileprivate func appendSentenceLoadButton(button: UIButton) {
        
        let richText: YYLabel = optionRichText
        let _ = AnswerSystemManager.shared.richText(richText: optionRichText, model: topicOptionsModel?.richtext)
        
        let bestSize = richText.sizeThatFits(CGSize(width: self.maxWidth == 0 ? Int.max : Int(self.maxWidth - 30), height: Int.max))
        btnWidth = bestSize.width + 24
        btnHeight = bestSize.height + 20
        
        if btnWidth < 60 {
            btnWidth = 60
        }
        
        if btnHeight < 40 {
            btnHeight = 40
        }
        
        self.width = btnWidth
        self.height = btnHeight
        
        optionRichText.textAlignment = .center
        button.snp.remakeConstraints { (make) in
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.top.equalTo(5)
            make.bottom.equalTo(-5)
            if btnWidth > self.maxWidth {
                make.width.equalTo(self.maxWidth - 10).priority(999)
                make.height.equalTo(btnHeight + 20).priority(999)
            } else {
                make.width.equalTo(btnWidth).priority(999)
                make.height.equalTo(btnHeight).priority(999)
            }
        }
    }
    
}

extension ChooseOptionCloseView {
    
    @objc func optionButtonClick() {
        self.chooseOptionCloseDelegate?.chooseOptionCloseClick(button: optionButton, owner: self)
    }
}

extension ChooseOptionCloseView {
    
    fileprivate func inputBoxIdx() -> Int {
        return self.formateRichTextContent?.inputBoxIdx ?? 0
    }
    
    func answer() -> String {
        return self.topicOptionsModel?.index ?? ""
    }
    
    
}

