//
//  ChooseOptionContainerView.swift
//  MMBaseComponents
//
//  Created by Mac on 2018/4/25.
//

import UIKit
import YYText
import YYCategories
import MMBaseComponents

class ChooseOptionContainerView: QuestionBaseView {
    
    fileprivate var chooseOptionLabel: YYLabel!
    fileprivate var grayBackView: UIView!
    fileprivate var chooseOptions: [ChooseOptionView] = []
    fileprivate var selectIndex = 0
    fileprivate var selectChooseEmptyContent: TextAttachmentContent?
    fileprivate var attachment: TextAttachmentContent?
    
    fileprivate var style: ExerciseStyle = .ChooseFillShowCode
    
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
                        case .ChooseFillShowCode, .ChooseFillShowCodeOnePosition:
                            optionView.stopLongAction()
                        case .ChooseFillNoShowCodeOnePosition, .ChooseFillNoShowCode:
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
                        
                        let optionAttribute = NSMutableAttributedString.yy_attachmentString(withContent: optionView, contentMode: .center, attachmentSize: CGSize(width: optionView.size.width + 10, height: optionView.size.height + 10), alignTo: RTNormalFont, alignment: .center)
                        contentText.append(optionAttribute)
                    }
                }
                
                chooseOptionLabel.attributedText = contentText
                chooseOptionLabel.numberOfLines = 0
                
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
                    var isFindAnswer = false
                    for (_, answer) in answers.enumerated() {
                        
                        if let lastOption = subOptions.last, let chooseEmptyView = lastOption.textContent.content as? ChooseEmptyView {
                            chooseEmptyView.isUserInteracted = self.isUserInteracted
                            if chooseEmptyView.richTextContent?.inputBoxIdx == answer.index.intValue() {
                                
                                let subAnswers = AnswerSystemHelper.shared.substrings(string: answer.answer)
                                if subAnswers.count == 0 {
                                    continue
                                }
                                for subAnswer in subAnswers {
                                    for (_, optionView) in chooseOptions.enumerated() {
                                        
                                        if let optionIndex = optionView.topicOptionsModel?.index, optionIndex == subAnswer {
                                            
                                            fillOption(index: index, topicOptionsModel: optionView.topicOptionsModel, content: lastOption)
                                            
                                            isFindAnswer = true
                                            
                                        }
                                    }
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
    
    public override func fetchAnswers() -> [RichParameterType] {
        
        var userAnswers: [RichParameterType] = []
        for (_, subOptions) in self.options.enumerated() {
            
            var parameters: RichParameterType = [:]
            parameters["is_right"] = false
            if subOptions.count == 1 {
                //空视图
                if let option = subOptions.first , let chooseEmptyView = option.textContent.content as? ChooseEmptyView {
                    //如果视图为空
                    parameters = chooseEmptyView.answerParameters()
                    
                }
            } else {
                //标准答案
                var formateAnswers: [String] = []
                if let lastOption = subOptions.last, let chooseEmptyView = lastOption.textContent.content as? ChooseEmptyView {
                    formateAnswers = chooseEmptyView.richTextContent?.answers ?? []
                    parameters["index"] = "\(chooseEmptyView.richTextContent?.inputBoxIdx ?? 0)"
                }
                formateAnswers.sort()
                //用户答案
                var results: [String] = []
                for option in subOptions {
                    if let chooseOptionView = option.textContent.content as? ChooseOptionCloseView {
                        results.append(chooseOptionView.answer())
                    }
                }
                results.sort()
                parameters["answer"] = results.joined(separator: "")
                if formateAnswers == results {
                    //答案正确
                    parameters["is_right"] = true
                }
                parameters["scores"] = 0
                
            }
            userAnswers.append(parameters)
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
        
        chooseOptionLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self.baseRichTextView.snp.bottom).offset(25)
            make.left.right.equalTo(0)
            make.centerX.equalTo(questionScrollView)
            make.height.equalTo(0)
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
        
        answerParseContainerView?.snp.makeConstraints({ (make) in
            make.top.equalTo(chooseOptionLabel.snp.bottom).offset(5)
            make.centerX.equalTo(questionScrollView)
            make.left.right.equalTo(self)
            make.bottom.equalTo(questionScrollView).offset(AnswerParseBottomHeight)
        })
        
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
            
            fillOption(index: self.selectIndex, topicOptionsModel: optionView.topicOptionsModel, content: content)
            
        }
        
    }
    
    func fillOption(index: Int, topicOptionsModel: TopicOptionsModel?, content: TextAttachmentContent?) {
        
        let textContent = AnswerSystemExerciseHelper.shared.produceChooseOptionClose(style: self.style, index: index, chooseOptionCloseDelegate: self, topicOptionsModel: topicOptionsModel)
        
        if self.style == .ChooseFillNoShowCodeOnePosition {
            for attachments in self.options {
                for attachment in attachments {
                    if let optionView = attachment.textContent.content as? ChooseOptionCloseView, optionView.topicOptionsModel?.richtext?.objectId == topicOptionsModel?.richtext?.objectId {
                        //多选单个选项不可多选
                        return
                    }
                }
            }
        } else  {
            for attachment in self.options[index] {
                if let optionView = attachment.textContent.content as? ChooseOptionCloseView, optionView.topicOptionsModel?.richtext?.objectId == topicOptionsModel?.richtext?.objectId {
                    //多选单个选项不可多选
                    return
                }
            }
        }
        
        self.options[index].insert(textContent, at: self.options[index].count - 1)
        self.baseRichTextView.mm_insertTextAttachment(textContent, original: content)
        
        RichTextManager.shared().selectAttachment(self.options[index], label: self.baseRichTextView, isDelete: false)
        self.remakeConstraints()
    }
    
    func loadData(style: ExerciseStyle, chooseTopic: TopicModel?) {
        self.style = style
        self.chooseTopic = chooseTopic
    }
    
}

extension ChooseOptionContainerView: ChooseEmptyViewDelegate {
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

extension ChooseOptionContainerView: ChooseOptionCloseDelegate {
    
    func selectOptionAction(button: UIButton, owner: ChooseOptionView) {
        
        if !isUserInteracted {
            AnswerSystemHelper.modifyStatusNotificationPost()
            return
        }
        
        //选中视图点击
        
        button.isSelected = true
        for option in self.chooseOptions {
            if option == owner {
                option.refreshUI(style: self.style, isSelected: button.isSelected)
            } else {
                option.refreshUI(style: self.style, isSelected: false)
            }
        }
        
        //在当前选项中填充视图
        let content = self.options[self.selectIndex].last
        fillOption(index: self.selectIndex, topicOptionsModel: owner.topicOptionsModel, content: content)
    }
    
    func chooseOptionCloseClick(button: UIButton, owner: ChooseOptionCloseView) {
        //纠正当前选中index
        
        if !isUserInteracted {
            AnswerSystemHelper.modifyStatusNotificationPost()
            return
        }
        
        var optionIndex = 0
        var isSelectIndex = false
        for subOptions in self.options {
            optionIndex = 0
            for option in subOptions {
                if let closeView = option.textContent.content as? ChooseOptionCloseView, closeView == owner {
                    self.selectIndex = option.index
                    isSelectIndex = true
                    break
                }
                optionIndex += 1
            }
            if isSelectIndex {
                break
            }
        }
        
        //执行delete操作
        let deleteAttachment = self.options[self.selectIndex][optionIndex]
        self.baseRichTextView.mm_deleteTextAttachment(deleteAttachment)
        
        self.options[self.selectIndex].remove(at: optionIndex)
        
        RichTextManager.shared().selectAttachment(self.options[self.selectIndex], label: self.baseRichTextView, isDelete: true)
        self.remakeConstraints()
    }
}

extension ChooseOptionContainerView {
    
    func chooseOptionConstraints() {
        
        let bestSize = chooseOptionLabel.sizeThatFits(CGSize(width: questionScrollView.frame.width - baseSpace, height: CGFloat.greatestFiniteMagnitude))
        chooseOptionLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self.baseRichTextView.snp.bottom).offset(25)
            make.left.right.equalTo(0)
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
    
    func findLocation(content: TextAttachmentContent?) -> Int {
        var index = 0
        for optionArray in options {
            var isEqual = false
            for option in optionArray {
                if let optionView = content?.textContent.content as? UIView, let compareView = option.textContent.content as? UIView {
                    if optionView == compareView {
                        //如果是同一个content，表示为一组数据
                        isEqual = true
                        break
                    }
                }
            }
            if isEqual {
                break
            }
            index += 1
        }
        return index
    }
    
}
