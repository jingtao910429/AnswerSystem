//
//  JudeView.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/9.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import YYText
import MMBaseComponents

class JudeView: QuestionBaseView {
    
    fileprivate var judeLabel: YYLabel!
    
    fileprivate var judeAnswers: [JudeTopicView] = []
    
    fileprivate var judeTopic: TopicModel? {
        didSet {
            if let judeTopic = judeTopic {
                self.topic = judeTopic
                self.makeConstraints()
                let contentText = NSMutableAttributedString()
                judeAnswers.removeAll()
                if judeTopic.chooseAnswers.count > 0 {
                    for judeOption in judeTopic.chooseAnswers {
                        let judeView: JudeTopicView = JudeTopicView(frame: CGRect(x: 0, y: 0, width: frame.width - 20, height: 0))
                        judeView.isUserInteracted = isUserInteracted
                        judeAnswers.append(judeView)
                        judeView.chooseOptionModel = judeOption
                        judeView.size = CGSize(width: frame.width - 20, height: CGFloat(judeView.caculateHeight))
                        judeView.sizeToFit()
                        
                        let optionAttribute = NSMutableAttributedString.yy_attachmentString(withContent: judeView, contentMode: .center, attachmentSize: judeView.size, alignTo: RTNormalFont, alignment: .center)
                        
                        optionAttribute.append(NSAttributedString(string: "\n\n"))
                        contentText.append(optionAttribute)
                    }
                    
                    judeLabel.attributedText = contentText
                    
                    judeConstraints()
                    
                }
            }
        }
    }
    
    override var answers: [UserAnswerItemModel]? {
        didSet {
            //答案填充
            if let answers = answers {
                for (_, jude) in judeAnswers.enumerated() {
                    for (_, answer) in answers.enumerated() {
                        if jude.chooseOptionModel?.index == answer.index {
                            jude.userAnswer = answer
                            break
                        }
                    }
                }
            }
        }
    }
    
    public override func fetchAnswers() -> [RichParameterType] {
        var userAnswers: [RichParameterType] = []
        for (_, judeOption) in self.judeAnswers.enumerated() {
            if let judeOptions = judeOption.answerParameters() {
                userAnswers.append(judeOptions)
            }
        }
        judeEditStatus(userAnswers: userAnswers)
        return userAnswers
    }
    
    override func updateAnswerParseConstraints() {
        super.updateAnswerParseConstraints()
        judeConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        judeLabel = YYLabel(frame: frame)
        judeLabel.numberOfLines = 0
        questionScrollView.addSubview(judeLabel)
        
        makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func makeConstraints() {
        
        judeLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self.baseRichTextView.snp.bottom)
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.centerX.equalTo(questionScrollView)
            make.height.equalTo(0)
        }
        
        answerParseContainerView?.snp.makeConstraints({ (make) in
            make.top.equalTo(judeLabel.snp.bottom).offset(5).priority(999)
            make.centerX.equalTo(questionScrollView)
            make.left.right.equalTo(self)
            make.bottom.equalTo(questionScrollView).offset(AnswerParseBottomHeight)
        })
    }
    
    func loadData(judeTopic: TopicModel?) {
        self.judeTopic = judeTopic
    }
    
}

extension JudeView {
    func judeConstraints() {
        let bestSize = judeLabel.sizeThatFits(CGSize(width: questionScrollView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        judeLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self.baseRichTextView.snp.bottom)
            make.centerX.equalTo(questionScrollView)
            make.height.equalTo(bestSize.height)
            if let isHidden = answerParseContainerView?.isHidden, isHidden {
                make.bottom.equalTo(questionScrollView).offset(answerParseStatus ? -20 : -50)
            }
        }
    }
}
