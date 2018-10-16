//
//  AppendCharcterProduceSentenceView.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/9.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import YYText
import MMBaseComponents
import MMToolHelper

class AppendCharcterProduceSentenceView: QuestionBaseView {
    
    fileprivate var sentenceView: YYLabel!
    fileprivate var grayBackView: UIView!
    fileprivate var sentenceResultContainerView: YYLabel!
    fileprivate var sentenceResultView: SentenceShowResultView!
    fileprivate var changeTextContent = TextAttachmentContent()
    
    fileprivate var chooseOptions: [ChooseOptionView] = []
    
    fileprivate var sentensOptions: [TextAttachmentContent] = []
    
    fileprivate var style: ExerciseStyle = .AppendCharcterProduceSentence
    
    fileprivate var formateAnswers: [String] = []
    
    fileprivate var sentenceTopic: TopicModel? {
        didSet {
            if let sentenceTopic = sentenceTopic {
                self.topic = sentenceTopic
                self.makeConstraints()
                self.formateAnswers = sentenceTopic.answers
                let contentText = NSMutableAttributedString()
                chooseOptions.removeAll()
                for (_, option) in sentenceTopic.subOptions.enumerated() {
                    if let _ = option.option?.richtext?.content.first {
                        let optionView = ChooseOptionView()
                        optionView.chooseOptionLongPressMoveBlock = { [weak self] (optionView) in
                            guard let `self` = self else {
                                return
                            }
                            if self.isUserInteracted {
                                self.longPressMoveAction(optionView: optionView)
                            } else {
                                AnswerSystemHelper.modifyStatusNotificationPost()
                            }
                        }
                        
                        optionView.selectOptionAction = { [weak self] (button, owner) in
                            guard let `self` = self else {
                                return
                            }
                            if self.isUserInteracted {
                                self.selectOptionAction(button: button, owner: owner)
                            } else {
                                AnswerSystemHelper.modifyStatusNotificationPost()
                            }
                        }
                        optionView.sizeToFit()
                        chooseOptions.append(optionView)
                        optionView.loadData(style: style, subTopicOptionModel: option, buttonWidth: self.questionScrollView.width - baseSpace)
                        
                        let optionAttribute = NSMutableAttributedString.yy_attachmentString(withContent: optionView, contentMode: .center, attachmentSize: CGSize(width: optionView.size.width + 10, height: optionView.size.height + 5), alignTo: RTNormalFont, alignment: .center)
                        contentText.append(optionAttribute)
                    }
                }
                
                sentenceView.attributedText = contentText
                
                remakeContainerConstraints()
                
            }
        }
    }
    
    override var answers: [UserAnswerItemModel]? {
        didSet {
            //答案填充
            if let answers = answers {
                sentensOptions.removeAll()
                for (_, answer) in answers.enumerated() {
                    for (_, optionView) in chooseOptions.enumerated() {
                        //查找答案
                        if optionView.subTopicOptionModel?.index == "\(answer.answer)" {
                            
                            let content: TextAttachmentContent?
                            if sentensOptions.count >= 1 {
                                content = sentensOptions.last
                            } else {
                                content = nil
                            }
                            fillOption(index: 0, topicOptionsModel: optionView.topicOptionsModel, content: content, isAddLength: true)
                            optionView.isGray = true
                            
                            break
                        }
                    }
                }
            }
        }
    }
    
    override func fetchAnswers() -> [RichParameterType] {
        var userAnswers: [RichParameterType] = []
        for (index, option) in sentensOptions.enumerated() {
            if let closeView = option.textContent.content as? ChooseOptionCloseView {
                var parameters: RichParameterType = [:]
                if sentensOptions.count != chooseOptions.count {
                    parameters["is_right"] = false
                } else {
                    if self.formateAnswers.count > index {
                        let answer = self.formateAnswers[index]
                        if answer == closeView.answer() {
                            parameters["is_right"] = true
                        } else {
                            parameters["is_right"] = false
                        }
                    } else {
                        parameters["is_right"] = false
                    }
                }
                parameters["scores"] = 0
                parameters["answer"] = closeView.answer()
                parameters["index"] = closeView.answer()
                userAnswers.append(parameters)
            }
        }
        judeEditStatus(userAnswers: userAnswers)
        return userAnswers
    }
    
    override func updateAnswerParseConstraints() {
        super.updateAnswerParseConstraints()
        remakeContainerConstraints()
    }
    
    func controlShow(answer: String, isHidden: Bool) {
        for chooseOption in chooseOptions {
            if let chooseIndex = chooseOption.subTopicOptionModel?.index, chooseIndex == answer {
                chooseOption.isGray = isHidden
                break
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        sentenceResultContainerView = YYLabel(frame: CGRect(x: 0, y: 0, width: self.width, height: 60))
        sentenceResultContainerView.numberOfLines = 0
        sentenceResultContainerView.backgroundColor = RTOptionBackGroundColor
        sentenceResultContainerView.layer.cornerRadius = 5
        sentenceResultContainerView.layer.masksToBounds = true
        questionScrollView.addSubview(sentenceResultContainerView)

        sentenceResultView = SentenceShowResultView()
        sentenceResultView.backgroundColor = RTSeperateColor
        questionScrollView.addSubview(sentenceResultView)
        
        sentenceView = YYLabel(frame: CGRect(x: 0, y: 0, width: self.questionScrollView.frame.width, height: 40))
        sentenceView.numberOfLines = 0
        questionScrollView.addSubview(sentenceView)
        
        grayBackView = UIView()
        grayBackView.backgroundColor = RTBackGroundColor
        self.questionScrollView.addSubview(grayBackView)
        self.questionScrollView.sendSubview(toBack: grayBackView)
        
        makeSelfConstraints()
    }
    
    func makeSelfConstraints() {
        
        sentenceResultContainerView.snp.makeConstraints { (make) in
            make.top.equalTo(self.baseRichTextView.snp.bottom).offset(10)
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.height.equalTo(200)
        }

        sentenceResultView.snp.makeConstraints { (make) in
            make.top.equalTo(sentenceResultContainerView.snp.bottom).offset(20)
            make.left.right.equalTo(questionScrollView)
            make.height.equalTo(0.5)
        }

        sentenceView.snp.makeConstraints { (make) in
            make.top.equalTo(self.sentenceResultContainerView.snp.bottom).offset(10)
            make.left.right.centerX.equalTo(sentenceResultContainerView)
            make.height.greaterThanOrEqualTo(40)
        }
        
        answerParseContainerView?.snp.makeConstraints({ (make) in
            make.top.equalTo(sentenceView.snp.bottom).offset(5)
            make.centerX.equalTo(sentenceResultContainerView)
            make.left.right.equalTo(self)
            make.bottom.equalTo(questionScrollView).offset(AnswerParseBottomHeight)
        })
        
        grayBackView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.sentenceResultView.snp.bottom)
            make.left.right.equalTo(0)
            if let isHidden = answerParseContainerView?.isHidden, isHidden {
                make.bottom.equalTo(self)
            } else {
                make.bottom.equalTo(answerParseContainerView!.snp.top)
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func longPressMoveAction(optionView: ChooseOptionView) {
        
        let rect = self.sentenceResultContainerView.convert(optionView.dragButton.frame, from: optionView)
        let moveCenter = CGPoint(x: rect.origin.x + rect.width / 2.0, y: rect.origin.y + rect.height / 2.0)
        
        var content = RichTextManager.shared().searchFocus(with: moveCenter, label: self.sentenceResultContainerView)
        var locationRight = false
        if content == nil {
            let emptyMoveCenter = CGPoint(x: rect.origin.x + rect.width / 2.0, y: rect.origin.y + rect.height / 2.0 + 30)
            if self.sentenceResultContainerView.frame.contains(emptyMoveCenter) {
                //在当前区域内
                content = sentensOptions.count != 0 ? sentensOptions.last : nil
                locationRight = true
            }
        }
        if content != nil || locationRight {
            //存在区域
            optionView.isGray = true
            fillOption(index: 0, topicOptionsModel: optionView.topicOptionsModel, content: content, isAddLength: (locationRight ? true : false))
        }
        
    }
    
    func fillOption(index: Int, topicOptionsModel: TopicOptionsModel?, content: TextAttachmentContent?, isAddLength: Bool) {
        
        let textContent = AnswerSystemExerciseHelper.shared.produceChooseOptionClose(style: self.style, index: index, chooseOptionCloseDelegate: self, topicOptionsModel: topicOptionsModel, width: self.questionScrollView.width)
        
        sentensOptions.append(textContent)
        self.sentenceResultContainerView.mm_insertTextAttachment(textContent, original: content, isAddLength: isAddLength)
        
        //更新本地数据
        
        var newSentenceOptions: [TextAttachmentContent] = []
        if let attachments = RichTextManager.shared().allAttachments(self.sentenceResultContainerView) {
            for attachment in attachments {
                for option in sentensOptions {
                    if let optionCloseView = option.textContent.content as? ChooseOptionCloseView, let attachmentCloseView = attachment.content as? ChooseOptionCloseView, optionCloseView ==  attachmentCloseView {
                        newSentenceOptions.append(option)
                        break
                    }
                }
            }
        }
        if newSentenceOptions.count == sentensOptions.count {
            sentensOptions = newSentenceOptions
        }
        remakeContainerConstraints()
    }
    
    func loadData(style: ExerciseStyle, sentenceTopic: TopicModel?) {
        self.style = style
        self.sentenceTopic = sentenceTopic
    }
    
}

extension AppendCharcterProduceSentenceView: ChooseOptionCloseDelegate {
    
    func chooseOptionCloseClick(button: UIButton, owner: ChooseOptionCloseView) {
        
        if !isUserInteracted {
            AnswerSystemHelper.modifyStatusNotificationPost()
            return
        }
        
        //纠正当前选中index
        
        var optionIndex = 0
        for option in sentensOptions {
            if let closeView = option.textContent.content as? ChooseOptionCloseView, closeView == owner {
                break
            }
            optionIndex += 1
        }
        
        if self.sentensOptions.count <= optionIndex {
            return
        }
        
        //执行delete操作
        let deleteAttachment = self.sentensOptions[optionIndex]
        self.sentenceResultContainerView.mm_deleteTextAttachment(deleteAttachment)
        
        self.sentensOptions.remove(at: optionIndex)
        
        controlShow(answer: owner.answer(), isHidden: false)
        
        remakeContainerConstraints()
    }
}

extension AppendCharcterProduceSentenceView {
    
    func selectOptionAction(button: UIButton, owner: ChooseOptionView) {
        //选中视图点击
        
        button.isSelected = true
        for option in self.chooseOptions {
            if option == owner {
                option.refreshUI(style: self.style, isSelected: button.isSelected)
            } else {
                option.refreshUI(style: self.style, isSelected: false)
            }
        }
        let content: TextAttachmentContent?
        if sentensOptions.count >= 1 {
            content = sentensOptions.last
        } else {
            content = nil
        }
        owner.isGray = true
        fillOption(index: 0, topicOptionsModel: owner.topicOptionsModel, content: content, isAddLength: true)
    }
    
    func remakeContainerConstraints() {
        
        var tWidth = DeviceInfo.adaptScreenWidth() - baseSpace
        
        if DeviceInfo.isPad() {
            tWidth = (DeviceInfo.adaptScreenWidth() - iPadTabWidth) * (1 - GoldScale) - baseSpace
        }
        
        let bestSize = sentenceResultContainerView.sizeThatFits(CGSize(width: tWidth - 10, height: CGFloat.greatestFiniteMagnitude))
        let height = bestSize.height < 60 ? 60 : bestSize.height
        sentenceResultContainerView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.baseRichTextView.snp.bottom).offset(5)
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.height.equalTo(height)
        }
        
        let sentenceBestSize = sentenceView.sizeThatFits(CGSize(width: tWidth, height: CGFloat.greatestFiniteMagnitude))
        
        sentenceView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.sentenceResultContainerView.snp.bottom).offset(20)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(sentenceBestSize.height + 40)
            if let isHidden = answerParseContainerView?.isHidden, isHidden {
                make.bottom.equalTo(questionScrollView).offset(answerParseStatus ? -20 : -50)
            }
        }
        
        grayBackView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.sentenceResultView.snp.bottom)
            make.left.right.equalTo(0)
            if let isHidden = answerParseContainerView?.isHidden, isHidden {
                make.bottom.equalTo(self)
            } else {
                make.bottom.equalTo(answerParseContainerView!.snp.top)
            }
        }
        
    }
}
