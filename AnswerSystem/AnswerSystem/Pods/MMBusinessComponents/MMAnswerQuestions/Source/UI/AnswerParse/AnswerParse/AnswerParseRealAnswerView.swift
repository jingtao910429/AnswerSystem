//
//  AnswerParseRealAnswerView.swift
//  MMBusinessComponents
//
//  Created by Mac on 2018/8/24.
//

import UIKit
import YYText
import MMToolHelper

class AnswerParseRealAnswerView: UIView {
    
    fileprivate var helper: AnswerSystemLineHelper = AnswerSystemLineHelper()
    
    fileprivate var nameLabel: UILabel!
    fileprivate var answerParseView: YYLabel!
    
    fileprivate var topic: TopicModel?
    fileprivate var isExistAnswer = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        nameLabel = UILabel()
        nameLabel.text = "正确答案："
        nameLabel.font = RTBoldNormalFont
        nameLabel.textColor = RTTextColor
        addSubview(nameLabel)
        
        answerParseView = YYLabel(frame: frame)
        answerParseView.numberOfLines = 0
        addSubview(answerParseView)
        
        makeConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeConstraints() {
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(5)
            make.height.equalTo(23).priority(999)
        }
        
        answerParseView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.bottom.equalTo(-10)
        }
    }
    
}

extension AnswerParseRealAnswerView {
    func loadData(topic: TopicModel?) -> Bool {
        self.topic = topic
        
        guard let topic = self.topic, let topicType = ExerciseStyle(rawValue: topic.type) else {
            return isExistAnswer
        }
        
        let cusWidth = self.width - 20
        
        let contentText = NSMutableAttributedString()
        
        switch topicType {
        case .AppendCharcterProduceSentence,
             .AppendCharcterProduceSentenceConditonOne:
            //排序题
            
            for answer in topic.answers {
                for (_, option) in topic.subOptions.enumerated() {
                    
                    if option.index == answer {
                        
                        isExistAnswer = true
                        
                        let optionView = ChooseOptionView()
                        optionView.sizeToFit()
                        optionView.isAnswerParse = true
                        optionView.isUserInteractionEnabled = false
                        optionView.loadData(style: topicType, subTopicOptionModel: option, buttonWidth: cusWidth)
                        
                        let optionAttribute = NSMutableAttributedString.yy_attachmentString(withContent: optionView, contentMode: .center, attachmentSize: CGSize(width: optionView.size.width, height: optionView.size.height), alignTo: RTSmallFont, alignment: .center)
                        contentText.append(optionAttribute)
                    }
                }
            }
            
        case .Fill,
             .ChooseShowCode,
             .ChooseNoShowCode,
             .ChooseShowCodeOnePosition,
             .ChooseNoShowCodeOnePosition,
             .ChooseFillShowCode,
             .ChooseFillNoShowCode,
             .ChooseFillShowCodeOnePosition,
             .ChooseFillNoShowCodeOnePosition,
             .EggIntoBaskets:
            //填空题、选择题
            
            if let options = self.topic?.content?.richtext?.content {
                var index = 1
                for subOption in options {
                    if subOption.type >= 3 && subOption.type <= 6 {
                        contentText.yy_appendString("空\(index):  ")
                        if subOption.answers.count == 0 {
                            //不存在答案
                            let attributeSpace = NSMutableAttributedString(string: "暂无")
                            contentText.append(attributeSpace)
                        } else {
                            
                            for answer in subOption.answers {
                                //存在答案
                                if answer == "" {
                                    let attributeSpace = NSMutableAttributedString(string: "暂无")
                                    contentText.append(attributeSpace)
                                } else {
                                    isExistAnswer = true
                                    if topicType == .ChooseFillNoShowCode
                                        || topicType == .ChooseFillNoShowCodeOnePosition
                                        || topicType == .ChooseNoShowCode
                                        || topicType == .ChooseNoShowCodeOnePosition
                                        || topicType == .EggIntoBaskets {
                                        //不显示编号
                                        let chooseAnswers = answer.components(separatedBy: "")
                                        if let chooseOptions = self.topic?.options {
                                            for itemAnswer in chooseAnswers {
                                                for itemOption in chooseOptions {
                                                    if itemAnswer == itemOption.index, let txt = itemOption.richtext?.content.first?.txt {
                                                        
                                                        let attribute = NSMutableAttributedString(string: "\(txt)")
                                                        attribute.addAttributeTextColor(RTOrangeRed)
                                                        attribute.addAttributeUnderlineStyle(CTUnderlineStyle.single, modifier: CTUnderlineStyleModifiers.patternSolid)
                                                        contentText.append(attribute)
                                                        
                                                        let attributeSpace = NSMutableAttributedString(string: "  ")
                                                        contentText.append(attributeSpace)
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        let attribute = NSMutableAttributedString(string: answer)
                                        attribute.addAttributeTextColor(RTOrangeRed)
                                        attribute.addAttributeUnderlineStyle(CTUnderlineStyle.single, modifier: CTUnderlineStyleModifiers.patternSolid)
                                        contentText.append(attribute)
                                    }
                                    
                                }
                            }
                            
                        }
                        index += 1
                        let attributeSpace = NSMutableAttributedString(string: "    ")
                        contentText.append(attributeSpace)
                        
                    }
                }
            }
        case .MatchLineTwoOption, .MatchLineThreeOption:
            //连线题
            isExistAnswer = true
            if let matchAnswers = self.topic?.matchAnswers {
                let subContentText = NSMutableAttributedString()
                for (index, match) in matchAnswers.enumerated() {
                    subContentText.yy_appendString("组\(index + 1):")
                    
                    if let left = match.left {
                        productMatchOption(topicType: topicType, model: left, content: subContentText, isAppendLine: true)
                    }
                    if let middle = match.middle {
                        productMatchOption(topicType: topicType, model: middle, content: subContentText, isAppendLine: true)
                    }
                    if let right = match.right {
                        productMatchOption(topicType: topicType, model: right, content: subContentText)
                    }
                    
                    subContentText.yy_appendString("\n\n")
                }
                contentText.append(subContentText)
            }
        case .Jude:
            //判断题
            if let judeAnswers = self.topic?.chooseAnswers {
                
                for (index, jude) in judeAnswers.enumerated() {
                    
                    contentText.yy_appendString("\(index + 1):  ")
                    
                    let resultButton = UIButton(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
                    if jude.answer == "1" {
                        resultButton.setImage(bundleImage(name: "exercise_icon_right_sel"), for: .normal)
                    } else if jude.answer == "0" {
                        resultButton.setImage(bundleImage(name: "exercise_icon_wrong_sel"), for: .normal)
                    }
                    
                    if jude.answer != "" {
                        isExistAnswer = true
                        let optionAttribute = NSMutableAttributedString.yy_attachmentString(withContent: resultButton, contentMode: .center, attachmentSize: resultButton.size, alignTo: RTNormalFont, alignment: .center)
                        
                        contentText.append(optionAttribute)
                    } else {
                        contentText.yy_appendString("暂无")
                    }
                    
                    contentText.yy_appendString("  ")
                }
            }
        case .WriteUploadImage:
            if let contents = self.topic?.content?.richtext?.content {
                for content in contents {
                    if content.type == 4 {
                        if content.answerType == "1" {
                            //图片
                            for answer in content.answers {
                                if answer != "" {
                                    isExistAnswer = true
                                    if answer.hasPrefix("http") {
                                        let size = AnswerSystemHelper.formateImage(url: answer, formateWidth: "", answerSystemType: .normal)
                                        let imageStorage = UIImageView()
                                        imageStorage.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                                        
                                        let optionAttribute = NSMutableAttributedString.yy_attachmentString(withContent: imageStorage, contentMode: .left, attachmentSize: imageStorage.size, alignTo: UIFont.systemFont(ofSize: 16), alignment: .center)
                                        contentText.append(optionAttribute)
                                    } else {
                                        contentText.yy_appendString("\(answer)  ")
                                    }
                                }
                            }
                        } else {
                            //文字
                            for answer in content.answers {
                                if answer != "" {
                                    isExistAnswer = true
                                    contentText.yy_appendString("\(answer)  ")
                                }
                            }
                        }
                        
                        break
                    }
                }
                
            }
        default:
            break
        }
        
        contentText.addAttributes([NSAttributedStringKey.font : RTSmallFont], range: NSRange(location: 0, length: contentText.length))
        if isExistAnswer {
            answerParseView.attributedText = contentText
        }
        
        let bestSize = answerParseView.sizeThatFits(CGSize(width: cusWidth, height: CGFloat.greatestFiniteMagnitude))
        answerParseView.snp.remakeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.height.equalTo(bestSize.height).priority(999)
            make.bottom.equalTo(-2)
        }
        
        return isExistAnswer
    }
}

extension AnswerParseRealAnswerView {
    func productMatchOption(topicType: ExerciseStyle, model: RichTextModel, content: NSMutableAttributedString, isAppendLine: Bool = false) {
        let richText = YYLabel()
        richText.numberOfLines = 0
        let _ = AnswerSystemManager.shared.richText(richText: richText, model: model.richtext, answerSystemType: .match, isAnswerParse: true)
        
        let size = CGSize(width: JionLineTextBtnWidth + 20, height: JionLineTextBtnHeight)
        let fitSize = richText.sizeThatFits(size)
        
        let lWidth = fitSize.width
        let lHeight = fitSize.height < size.height ? size.height : fitSize.height
        richText.frame = CGRect(x: 0, y: 0, width: lWidth, height: lHeight)
        
        let optionAttribute = NSMutableAttributedString.yy_attachmentString(withContent: richText, contentMode: .center, attachmentSize: richText.size, alignTo: RTSmallFont, alignment: .center)
        content.append(optionAttribute)
        
        if isAppendLine {
            let line = productLine(topicType: topicType)
            let optionAttribute = NSMutableAttributedString.yy_attachmentString(withContent: line, contentMode: .center, attachmentSize: line.size, alignTo: RTSmallFont, alignment: .center)
            content.append(optionAttribute)
        }
    }
    
    func productLine(topicType: ExerciseStyle) -> UIView {
        var tWidth = CGFloat(60)
        if topicType == .MatchLineTwoOption {
            tWidth = (self.width - 20) / 5.0
        } else {
            tWidth = (self.width - 20) / 6.0
        }
        if DeviceInfo.isPad() {
            tWidth = CGFloat(70)
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tWidth, height: 20))
        let subView = UIView()
        subView.backgroundColor = RTTextColor
        view.addSubview(subView)
        subView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.centerX.centerY.equalTo(view)
            make.height.equalTo(1)
        }
        return view
    }
}
