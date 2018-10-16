//
//  EggIntoBasketView.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/9.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import YYText
import MMBaseComponents

class EggIntoBasketView: QuestionBaseView {
    
    fileprivate var optionContentLabel: YYLabel!
    
    fileprivate var basketBackView: UIView!
    fileprivate var basketBackImageView: UIImageView!
    fileprivate var selectContentLabel: YYLabel!
    
    fileprivate var chooseOptions: [ChooseOptionView] = []
    
    fileprivate var eggOptions: [TextAttachmentContent] = []
    
    fileprivate var style: ExerciseStyle = .EggIntoBaskets
    
    fileprivate var formateAnswers: [String] = []
    
    fileprivate var eggTopic: TopicModel? {
        didSet {
            if let eggTopic = eggTopic {
                self.topic = eggTopic
                self.makeConstraints()
                self.formateAnswers = eggTopic.answers
                if let option = options.first?.first,  let emptyView = option.textContent.content as? ChooseEmptyView {
                    self.formateAnswers = emptyView.richTextContent?.answers ?? []
                }
                let contentText = NSMutableAttributedString()
                for (_, option) in eggTopic.options.enumerated() {
                    if let _ = option.richtext?.content.first {
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
                        
                        chooseOptions.append(optionView)
                        optionView.loadData(style: style, topicOptionsModel: option)
                        
                        let optionAttribute = NSMutableAttributedString.yy_attachmentString(withContent: optionView, contentMode: .left, attachmentSize: CGSize(width: optionView.size.width + 5, height: optionView.size.height + 5), alignTo: RTNormalFont, alignment: .center)
                        contentText.append(optionAttribute)
                    }
                }
                
                optionContentLabel.attributedText = contentText
                
                optionContentConstraints()
            }
        }
    }
    
    override var answers: [UserAnswerItemModel]? {
        didSet {
            //答案填充
            if let answers = answers {
                for (_, optionView) in chooseOptions.enumerated() {
                    for (_, answer) in answers.enumerated() {
                        //查找答案
                        if optionView.topicOptionsModel?.index == "\(answer.answer)" {
                            
                            let content: TextAttachmentContent?
                            if eggOptions.count >= 1 {
                                content = eggOptions.last
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
        
        for (index, option) in eggOptions.enumerated() {
            if let closeView = option.textContent.content as? ChooseOptionCloseView {
                
                if self.formateAnswers.count > index {
                    let answer = self.formateAnswers[index]
                    var parameters: RichParameterType = [:]
                    if answer == closeView.answer() {
                        parameters["is_right"] = true
                    } else {
                        parameters["is_right"] = false
                    }
                    parameters["scores"] = 0
                    parameters["answer"] = closeView.answer()
                    parameters["index"] = closeView.answer()
                    userAnswers.append(parameters)
                }
                
            }
        }
        judeEditStatus(userAnswers: userAnswers)
        return userAnswers
    }
    
    func controlShow(answer: String, isGray: Bool) {
        for chooseOption in chooseOptions {
            if let chooseIndex = chooseOption.topicOptionsModel?.index, chooseIndex == answer {
                chooseOption.isGray = isGray
                break
            }
        }
    }
    
    override func updateAnswerParseConstraints() {
        super.updateAnswerParseConstraints()
        optionContentConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        basketBackView = UIView(frame: frame)
        questionScrollView.addSubview(basketBackView)
        
        basketBackImageView = UIImageView(frame: frame)
        basketBackImageView.image = bundleImage(name: "exercise_img_caoping")
        basketBackView.addSubview(basketBackImageView)
        
        selectContentLabel = YYLabel(frame: CGRect(x: 0, y: 0, width: questionScrollView.width - baseSpace, height: 100))
        selectContentLabel.numberOfLines = 0
        basketBackView.addSubview(selectContentLabel)
        
        optionContentLabel = YYLabel(frame: CGRect(x: 0, y: 0, width: questionScrollView.width - baseSpace, height: 100))
        optionContentLabel.numberOfLines = 0
        optionContentLabel.isUserInteractionEnabled = true
        questionScrollView.addSubview(optionContentLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func makeConstraints() {
        
        optionContentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.baseRichTextView.snp.top).offset(10)
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.centerX.equalTo(questionScrollView)
            make.height.equalTo(100)
        }
        
        let image = bundleImage(name: "exercise_img_caoping")!
        let caculateHeight = image.size.height / image.size.width * self.width
        
        basketBackView.snp.makeConstraints { (make) in
            make.top.equalTo(optionContentLabel.snp.bottom).offset(30)
            make.left.equalTo(8)
            make.right.equalTo(-8)
        }
        
        selectContentLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(0)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(caculateHeight)
        }
        
        basketBackImageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(15)
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.height.equalTo(caculateHeight)
        }
        
        answerParseContainerView?.snp.makeConstraints({ (make) in
            make.top.equalTo(basketBackView.snp.bottom).offset(15).priority(999)
            make.centerX.equalTo(questionScrollView)
            make.left.right.equalTo(self)
            make.bottom.equalTo(questionScrollView).offset(AnswerParseBottomHeight)
        })
    }
    
    func longPressMoveAction(optionView: ChooseOptionView) {
        
        let rect = self.selectContentLabel.convert(optionView.dragButton.frame, from: optionView)
        let moveCenter = CGPoint(x: rect.origin.x + rect.width / 2.0, y: rect.origin.y + rect.height / 2.0)
        
        var content = RichTextManager.shared().searchFocus(with: moveCenter, label: self.selectContentLabel)
        var locationRight = false
        if content == nil {
            let emptyMoveCenter = CGPoint(x: rect.origin.x + rect.width / 2.0, y: rect.origin.y + rect.height / 2.0 + 30)
            if self.selectContentLabel.frame.contains(emptyMoveCenter) {
                //在当前区域内
                content = eggOptions.count != 0 ? eggOptions.last : nil
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
        
        let textContent = AnswerSystemExerciseHelper.shared.produceChooseOptionClose(style: self.style, index: index, chooseOptionCloseDelegate: self, topicOptionsModel: topicOptionsModel)
        
        eggOptions.append(textContent)
        self.selectContentLabel.mm_insertTextAttachment(textContent, original: content, isAddLength: isAddLength)
        self.selectContentLabel.paragraphStyle(40, lineSpace: -10)
        
        //更新本地数据
        
        var newSentenceOptions: [TextAttachmentContent] = []
        if let attachments = RichTextManager.shared().allAttachments(self.selectContentLabel) {
            for attachment in attachments {
                for option in eggOptions {
                    if let optionCloseView = option.textContent.content as? ChooseOptionCloseView, let attachmentCloseView = attachment.content as? ChooseOptionCloseView, optionCloseView ==  attachmentCloseView {
                        newSentenceOptions.append(option)
                        break
                    }
                }
            }
        }
        if newSentenceOptions.count == eggOptions.count {
            eggOptions = newSentenceOptions
        }
        remakeContainerConstraints()
    }
    
    func loadData(eggTopic: TopicModel?) {
        self.eggTopic = eggTopic
    }
    
    
}

extension EggIntoBasketView: ChooseOptionCloseDelegate {
    
    func chooseOptionCloseClick(button: UIButton, owner: ChooseOptionCloseView) {
        
        if !self.isUserInteracted {
            AnswerSystemHelper.modifyStatusNotificationPost()
            return
        }
        
        //纠正当前选中index
        
        var optionIndex = 0
        for option in eggOptions {
            if let closeView = option.textContent.content as? ChooseOptionCloseView, closeView == owner {
                break
            }
            optionIndex += 1
        }
        
        //执行delete操作
        let deleteAttachment = self.eggOptions[optionIndex]
        self.selectContentLabel.mm_deleteTextAttachment(deleteAttachment)
        self.selectContentLabel.paragraphStyle(40, lineSpace: -10)
        
        self.eggOptions.remove(at: optionIndex)
        
        controlShow(answer: owner.answer(), isGray: false)
        
        remakeContainerConstraints()
    }
}

extension EggIntoBasketView {
    
    func optionContentConstraints() {
        
        let bestSize = optionContentLabel.sizeThatFits(CGSize(width: optionContentLabel.width, height: CGFloat.greatestFiniteMagnitude))
        optionContentLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self.baseRichTextView.snp.bottom)
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.centerX.equalTo(questionScrollView)
            make.height.equalTo(bestSize.height)
            if let isHidden = self.answerParseContainerView?.isHidden, isHidden {
                make.bottom.equalTo(questionScrollView).offset(-50)
            }
        }
    }
    
    func selectOptionAction(button: UIButton, owner: ChooseOptionView) {
        //选中视图点击
        
        button.isSelected = true
        for option in self.chooseOptions {
            if option == owner {
                option.refreshUI(style: self.style, isSelected: button.isSelected)
                break
            }
//            else {
//                option.refreshUI(style: self.style, isSelected: false)
//            }
        }
        let content: TextAttachmentContent?
        if eggOptions.count >= 1 {
            content = eggOptions.last
        } else {
            content = nil
        }
        owner.isGray = true
        fillOption(index: 0, topicOptionsModel: owner.topicOptionsModel, content: content, isAddLength: true)
    }
    
    func remakeContainerConstraints() {
        let bestSize = selectContentLabel.sizeThatFits(CGSize(width: questionScrollView.frame.width - baseSpace, height: CGFloat.greatestFiniteMagnitude))
        let height = bestSize.height < 120 ? 120 : bestSize.height
        selectContentLabel.snp.remakeConstraints { (make) in
            make.top.bottom.equalTo(0)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(height)
        }
    }
}


