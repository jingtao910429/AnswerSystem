//
//  FillBlankView.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/9.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import YYText
import MMBaseComponents
import MMToolHelper

class FillBlankView: QuestionBaseView {
    
    fileprivate var fillBlankTopic: TopicModel? {
        didSet {
            if let fillBlankTopic = fillBlankTopic {
                self.topic = fillBlankTopic
                for subOptions in self.options {
                    for option in subOptions {
                        if let chooseEmptyView = option.textContent.content as? ChooseEmptyView {
                            chooseEmptyView.isUserInteracted = self.isUserInteracted
                            chooseEmptyView.chooseEmptyViewDelegate = self
                        }
                    }
                }
                remakeConstraints(needBottom: true)
            }
        }
    }
    
    override var answers: [UserAnswerItemModel]? {
        didSet {
            //答案填充
            if let answers = answers {
                for (_, subOptions) in self.options.enumerated() {
                    if let option = subOptions.first, let chooseEmptyView = option.textContent.content as? ChooseEmptyView {
                        for (_, answer) in answers.enumerated() {
                            if chooseEmptyView.richTextContent?.inputBoxIdx == answer.index.intValue() {
                                chooseEmptyView.content = answer.answer
                                
                                bindText(text: chooseEmptyView.content ?? "", length: CGFloat(chooseEmptyView.richTextContent?.length.doubleValue() ?? 0.0), chooseEmptyView: chooseEmptyView, original: option)
                                remakeConstraints(needBottom: true)
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
            if let option = subOptions.first, let chooseEmptyView = option.textContent.content as? ChooseEmptyView {
                var parameters: RichParameterType = [:]
                if let _ = chooseEmptyView.richTextContent {
                    parameters = chooseEmptyView.answerParameters()
                    parameters["is_right"] = chooseEmptyView.fillIsRight()
                }
                userAnswers.append(parameters)
            }
        }
        judeEditStatus(userAnswers: userAnswers)
        return userAnswers
    }
    
    override func answerResult() -> Bool {
        for (_, subOptions) in self.options.enumerated() {
            if let option = subOptions.first, let chooseEmptyView = option.textContent.content as? ChooseEmptyView {
                if !chooseEmptyView.fillIsRight() {
                    return false
                }
            }
        }
        return true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData(fillBlankTopic: TopicModel?) {
        self.fillBlankTopic = fillBlankTopic
    }
    
    func bindText(text: String, length: CGFloat, chooseEmptyView: ChooseEmptyView, original: TextAttachmentContent) {
        let attributes = [NSAttributedStringKey.font: RTLessNormalFont]
        var width = text.boundingRect(with: CGSize(width: Int.max, height: 35), options:.usesLineFragmentOrigin, attributes: attributes, context:nil).size.width + 20
        if length < 60.0 {
            width = 60.0
        } else if width < length {
            if length > DeviceInfo.screenWidth() - 30 {
                width = DeviceInfo.screenWidth() - 30
            } else {
                width = length
            }
        }
        chooseEmptyView.frame = CGRect(x: 0, y: 0, width: width, height: 35)
        
        let tattachment = YYTextAttachment(content: chooseEmptyView)
        let textContent = TextAttachmentContent()
        textContent.range = NSRange(location: 0, length: 1)
        textContent.textContent = tattachment
        
        baseRichTextView.mm_replaceTextAttachment(textContent, original: original)
        RichTextManager.shared().selectAttachment(self.options[chooseEmptyView.chooseEmptyIndex], label: self.baseRichTextView, isDelete: text == "" ? true : false)
    }

}

extension FillBlankView: ChooseEmptyViewDelegate {
    
    func textFieldEditChanged(textField: UITextField, emptyView: ChooseEmptyView) {
        guard let text = textField.text, text != "", let fillView = self.options[emptyView.chooseEmptyIndex].first else {
            return
        }
        
//        bindText(text: text, chooseEmptyView: emptyView, original: fillView)
//
//        remakeConstraints()
//
//        let deadlineTime = DispatchTime.now() + 0.1
//        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
//            textField.becomeFirstResponder()
//        })
    }
    
    func focus(index: Int, emptyView: ChooseEmptyView) {
        let convertFrame = emptyView.superview?.convert(emptyView.frame, to: UIApplication.shared.keyWindow)
        //转换过后的坐标
        self.inputConvertFrame = convertFrame ?? CGRect.zero
    }
    
}
