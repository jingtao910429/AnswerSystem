//
//  JudeTopicView.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/11.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import YYText

let kJudeTopicBtnWidth = CGFloat(100)
let kJudeTopicBtnHeight = CGFloat(40)

class JudeTopicView: UIView {
    
    fileprivate var judeItemView: JudeItemView!
    fileprivate var titleLabel: UILabel!
    fileprivate var richTextView: YYLabel!
    
    var caculateHeight = CGFloat(45) {
        didSet {
            if caculateHeight < CGFloat(45) {
                caculateHeight = CGFloat(45)
            }
        }
    }
    
    var chooseOptionModel: ChooseOptionModel? {
        didSet {
            if let chooseOptionModel = chooseOptionModel {
                if chooseOptionModel.index != "" {
                    let attributeText = NSMutableAttributedString(string: "\(chooseOptionModel.index)  ")
                    attributeText.addAttributeFont(RTBoldNormalFont)
                    attributeText.addAttributeTextColor(UIColor(hex: "#415373"))
                    richTextView.attributedText = attributeText
                    //titleLabel.text = chooseOptionModel.index
                }
                if let richText = chooseOptionModel.option?.richtext {
                    let _ = AnswerSystemManager.shared.richText(richText: richTextView, model: richText)
                    
                    let estemateWidth = CGFloat(self.width - kJudeTopicBtnWidth - 20)
                    let bestSize = self.richTextView.sizeThatFits(CGSize(width: estemateWidth, height: CGFloat.greatestFiniteMagnitude))
                    self.caculateHeight = bestSize.height
                    self.richTextView.snp.remakeConstraints({ (make) in
                        make.top.equalTo(titleLabel)
                        make.left.equalTo(titleLabel.snp.right)
                        make.right.equalTo(judeItemView.snp.left).offset(0)
                        make.height.equalTo(bestSize.height).priority(999)
                        make.bottom.equalTo(0)
                    })
                }
            }
        }
    }
    
    var userAnswer: UserAnswerItemModel? {
        didSet {
            if let userAnswer = userAnswer {
                judeItemView.loadData(isRight: userAnswer.optionAnswer)
            }
        }
    }
    
    var isUserInteracted = true {
        didSet {
            judeItemView.isUserInteracted = isUserInteracted
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.textColor = RTTextColor
        titleLabel.font = RTNormalFont
        addSubview(titleLabel)
        
        judeItemView = JudeItemView()
        addSubview(judeItemView)
        
        richTextView = YYLabel(frame: CGRect(x: 0, y: 0, width: CGFloat(frame.size.width - 40 - kJudeTopicBtnWidth), height: 0))
        richTextView.numberOfLines = 0
        addSubview(richTextView)
        
        makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeConstraints() {
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.width.equalTo(10)
        }
        
        richTextView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel)
            make.left.equalTo(titleLabel.snp.right)
            make.right.equalTo(judeItemView.snp.left).offset(0)
            make.bottom.equalTo(0)
        }
        
        judeItemView.snp.makeConstraints { (make) in
            make.top.equalTo(richTextView)
            make.right.equalTo(0)
            make.width.equalTo(kJudeTopicBtnWidth)
            make.height.equalTo(kJudeTopicBtnHeight).priority(999)
        }
    }
    
    func answerParameters() -> RichParameterType? {
        var parameters : RichParameterType = [:]
        let answer = judeItemView.selectResult()
        if answer == -1 {
            //没有选择
            return nil
        }
        if answer == 1 {
            parameters["answer"] = 1
        } else if answer == 0 {
            parameters["answer"] = 0
        } else {
            parameters["answer"] = ""
        }
        
        parameters["option"] = chooseOptionModel?.index ?? ""
        parameters["index"] = chooseOptionModel?.index ?? ""
        parameters["scores"] = 0
        parameters["is_right"] = false
        if let answer = chooseOptionModel?.answer {
            if judeItemView.selectResult() == answer.intValue() {
                parameters["is_right"] = true
            }
        }
        return parameters
    }
}
