//
//  ChooseView.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/9.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import YYText
import MMBaseComponents

class ChooseView: QuestionBaseView {
    
    fileprivate var chooseOptionLabel: YYLabel!
    fileprivate var grayBackView: UIView!
    fileprivate var chooseOptions: [ChooseOptionView] = []
    fileprivate var selectIndex = 0
    fileprivate var selectChooseEmptyContent: TextAttachmentContent?
    fileprivate var attachment: TextAttachmentContent?
    
    fileprivate var style: ExerciseStyle = .ChooseShowCode
    
    fileprivate var chooseTopic: TopicModel? {
        didSet {
            if let chooseTopic = chooseTopic {
                self.topic = chooseTopic
                self.makeConstraints()
                let contentText = NSMutableAttributedString()
                chooseOptions.removeAll()
                for (_, option) in chooseTopic.options.enumerated() {
                    if let _ = option.richtext?.content.first {
                        let optionView = ChooseOptionView()
                        chooseOptions.append(optionView)
                        
                        optionView.loadData(style: style, topicOptionsModel: option, buttonWidth: self.width - 24)
                        
                        switch style {
                        case .ChooseShowCode, .ChooseShowCodeOnePosition:
                            //单选
                            optionView.stopLongAction()
                        case .ChooseNoShowCodeOnePosition, .ChooseNoShowCode:
                            //不显示编号，拖动
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
                        default:
                            break
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
                        
                        let optionAttribute = NSMutableAttributedString.yy_attachmentString(withContent: optionView, contentMode: .center, attachmentSize: CGSize(width: optionView.size.width + 10, height: optionView.size.height + 10), alignTo: RTNormalFont, alignment: .center)
                        contentText.append(optionAttribute)
                    }
                }
                
                chooseOptionLabel.attributedText = contentText
                
                chooseOptionConstraints()
                
                emptyViewsLogic()
            }
        }
    }
    
    override var answers: [UserAnswerItemModel]? {
        didSet {
            //答案填充
            if let answers = answers {
                
                for (index, subOptions) in self.options.enumerated() {
                    if let option = subOptions.first, let chooseEmptyView = option.textContent.content as? ChooseEmptyView {
                        
                        chooseEmptyView.isUserInteracted = self.isUserInteracted
                        
                        var isFindAnswer = false
                        for (_, answer) in answers.enumerated() {
                            
                            if chooseEmptyView.richTextContent?.inputBoxIdx == answer.index.intValue() {
                                
                                let original = self.options[index].first
                                
                                for (_, optionView) in chooseOptions.enumerated() {
                                    //查找答案
                                    if optionView.topicOptionsModel?.index == answer.answer {
                                        
                                        if self.options.count > index {
                                            locatePackHandler(isRemove: false, content: original, index: index, topicOptionsModel: optionView.topicOptionsModel)
                                            //option默认选中
                                            optionView.refreshUI(style: self.style, isSelected: true)
                                        }
                                        isFindAnswer = true
                                        break
                                    }
                                }
                            }
                            if isFindAnswer {
                                break
                            }
                        }
                    }
                }
            }
        }
    }

    
    public override func fetchAnswers() -> [RichParameterType] {
        
        var userAnswers: [RichParameterType] = []
        for (_, subOptions) in self.options.enumerated() {
            if let option = subOptions.first {
                var parameters: RichParameterType = [:]
                
                if let chooseEmptyView = option.textContent.content as? ChooseEmptyView {
                    //如果视图为空
                    parameters = chooseEmptyView.answerParameters()
                    parameters["is_right"] = false
                    
                }
                if let chooseOptionView = option.textContent.content as? ChooseOptionCloseView {
                    //视图有值
                    parameters = chooseOptionView.answerParameters()
                    
                    if chooseOptionView.topicOptionsModel?.index == chooseOptionView.formateRichTextContent?.answers.first {
                        parameters["is_right"] = true
                    } else {
                        parameters["is_right"] = false
                    }
                }
                userAnswers.append(parameters)
            }
            
        }
        judeEditStatus(userAnswers: userAnswers)
        return userAnswers
    }
    
    override func updateAnswerParseConstraints() {
        super.updateAnswerParseConstraints()
        chooseOptionConstraints()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        chooseOptionLabel = YYLabel(frame: frame)
        chooseOptionLabel.numberOfLines = 0
        questionScrollView.addSubview(chooseOptionLabel)
        
        self.baseRichTextView.isUserInteractionEnabled = true
        
        grayBackView = UIView()
        grayBackView.backgroundColor = RTBackGroundColor
        self.questionScrollView.addSubview(grayBackView)
        self.questionScrollView.sendSubview(toBack: grayBackView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func makeConstraints() {
        
        chooseOptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.baseRichTextView.snp.bottom).offset(25)
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.centerX.equalTo(questionScrollView)
            make.height.equalTo(0)
        }
        
        grayBackView.snp.makeConstraints { (make) in
            make.top.equalTo(self.baseRichTextView.snp.bottom).offset(10)
            make.left.right.equalTo(0)
            if let isHidden = answerParseContainerView?.isHidden, isHidden {
                make.bottom.equalTo(self)
            } else {
                make.bottom.equalTo(answerParseContainerView!.snp.top)
            }
            make.centerX.equalTo(questionScrollView)
        }
        
        answerParseContainerView?.snp.makeConstraints({ (make) in
            make.top.equalTo(chooseOptionLabel.snp.bottom).offset(5).priority(999)
            make.centerX.equalTo(questionScrollView)
            make.left.right.equalTo(self)
            make.bottom.equalTo(questionScrollView).offset(AnswerParseBottomHeight)
        })
    }
    
    func loadData(style: ExerciseStyle, chooseTopic: TopicModel?) {
        self.style = style
        self.chooseTopic = chooseTopic
    }
    
}

extension ChooseView: ChooseEmptyViewDelegate {
    
    func focus(index: Int, emptyView: ChooseEmptyView) {
        //获取焦点,清除当前选中视图状态
        self.selectIndex = index
        
        for option in options[self.selectIndex] {
            if let tEmptyView = option.textContent.content as? ChooseEmptyView, tEmptyView == emptyView {
                self.selectChooseEmptyContent = option
                break
            }
        }
        
    }
    
}

extension ChooseView: ChooseOptionCloseDelegate {
    func chooseOptionCloseClick(button: UIButton, owner: ChooseOptionCloseView) {
        
        if !isUserInteracted {
            AnswerSystemHelper.modifyStatusNotificationPost()
            return
        }
        
        //纠正当前选中index

        for subOptions in self.options {
            for option in subOptions {
                if let closeView = option.textContent.content as? ChooseOptionCloseView, closeView == owner {
                    self.selectIndex = option.index
                    break
                }
            }
        }
        
        if options[self.selectIndex].count == 1 {
            
            locatePackHandler(isRemove: true, content: self.options[self.selectIndex].first, index: self.selectIndex, topicOptionsModel: owner.topicOptionsModel)
            
            switch style {
            case .ChooseShowCode, .ChooseShowCodeOnePosition:
                for option in self.chooseOptions {
                    option.refreshUI(style: self.style, isSelected: false)
                }
            default:
                break
            }
            
        } else {
            print("异常！")
        }
    }
}

extension ChooseView {
    
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
        
        if self.options.count <= self.selectIndex {
            return
        }
        
        locatePackHandler(isRemove: false, content: self.options[self.selectIndex].first, index: self.selectIndex, topicOptionsModel: owner.topicOptionsModel)
    }
    
    func longPressMoveAction(optionView: ChooseOptionView) {
        
        let rect = self.baseRichTextView.convert(optionView.dragButton.frame, from: optionView)
        let moveCenter = CGPoint(x: rect.origin.x + rect.width / 2.0, y: rect.origin.y + rect.height / 2.0)
        
        let content = RichTextManager.shared().searchFocus(with: moveCenter, label: self.baseRichTextView)
        if content != nil, let _ = content?.range {
            //存在区域
            
            let index = findLocation(content: content)
            if index >= self.options.count {
                return
            }
            self.selectIndex = index
            
            if self.style == .ChooseNoShowCodeOnePosition {
                for attachments in self.options {
                    for attachment in attachments {
                        if let toptionView = attachment.textContent.content as? ChooseOptionCloseView, toptionView.topicOptionsModel?.richtext?.objectId == optionView.topicOptionsModel?.richtext?.objectId {
                            //多选单个选项不可多选
                            return
                        }
                    }
                }
            }
            
            locatePackHandler(isRemove: false, content: content, index: index, topicOptionsModel: optionView.topicOptionsModel)
        }
        
    }
}

extension ChooseView {
    
    func chooseOptionConstraints() {
        let bestSize = chooseOptionLabel.sizeThatFits(CGSize(width: questionScrollView.frame.width - baseSpace, height: CGFloat.greatestFiniteMagnitude))
        chooseOptionLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self.baseRichTextView.snp.bottom).offset(25)
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.centerX.equalTo(questionScrollView)
            make.height.equalTo(bestSize.height)
            if let isHidden = answerParseContainerView?.isHidden, isHidden {
                make.bottom.equalTo(questionScrollView).offset(answerParseStatus ? -20 : -50)
            }
        }
        
        grayBackView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.baseRichTextView.snp.bottom).offset(10)
            make.left.right.equalTo(0)
            if let isHidden = answerParseContainerView?.isHidden, isHidden {
                make.bottom.equalTo(self)
            } else {
                make.bottom.equalTo(answerParseContainerView!.snp.top)
            }
            make.centerX.equalTo(questionScrollView)
        }
    }
    
    func emptyViewsLogic() {
        var index = 0
        for subOptions in self.options {
            for option in subOptions {
                if let emptyView = option.textContent.content as? ChooseEmptyView {
                    if index == 0 {
                        self.selectChooseEmptyContent = option
                    }
                    emptyView.chooseEmptyViewDelegate = self
                    index += 1
                }
            }
        }
    }
    
    //定位及选项填充操作
    func locatePackHandler(isRemove: Bool, content: TextAttachmentContent?, index: Int, topicOptionsModel: TopicOptionsModel?) {
        
        guard let content = content else {
            return
        }
        
        var formateAnswer: RichTextContent?
        //处理标准答案
        if let empty = content.textContent.content as? ChooseEmptyView {
            formateAnswer = empty.richTextContent
        }
        
        if let option = content.textContent.content as? ChooseOptionCloseView {
            formateAnswer = option.formateRichTextContent
        }
        
        
        var textContent: TextAttachmentContent!
        
        if !isRemove {
            textContent = AnswerSystemExerciseHelper.shared.produceChooseOptionClose(style: self.style, index: index, chooseOptionCloseDelegate: self, topicOptionsModel: topicOptionsModel, formateAnswer: formateAnswer)
        } else {
            textContent = AnswerSystemExerciseHelper.shared.produceEmptyOption(style: self.style, chooseEmptyIndex: index, chooseEmptyViewDelegate: self, formateAnswer: formateAnswer)
            
        }
        
        self.options[index].removeAll()
        self.options[index].append(textContent)
        self.baseRichTextView.mm_replaceTextAttachment(textContent, original: content)
        
        RichTextManager.shared().selectAttachment(self.options[index], label: self.baseRichTextView, isDelete: isRemove)
        self.remakeConstraints()
        
    }
    
    func findLocation(content: TextAttachmentContent?) -> Int {
        var index = 0
        for optionArray in options {
            for option in optionArray {
                if let optionView = content?.textContent.content as? UIView, let compareView = option.textContent.content as? UIView {
                    if optionView == compareView {
                        //如果是同一个content，表示为一组数据
                        return index
                    }
                }
            }
            index += 1
        }
        return index
    }
}
