//
//  ChooseEmptyView.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/9.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import YYText

@objc protocol ChooseEmptyViewDelegate: NSObjectProtocol {
    @objc optional func focus(index: Int, emptyView: ChooseEmptyView)
    @objc optional func textFieldEditChanged(textField: UITextField, emptyView: ChooseEmptyView)
}

//填空视图
class ChooseEmptyView: UIView {
    
    fileprivate var inputTextFiled: UITextField!
    
    var chooseEmptyIndex = 0
    
    weak var chooseEmptyViewDelegate: ChooseEmptyViewDelegate?
    
    var content: String? {
        didSet {
            inputTextFiled.textAlignment = .center
            inputTextFiled.text = content
        }
    }
    
    var style: ExerciseStyle? {
        didSet {
            
            if let style = style {
                if style == .ChooseFillShowCode
                    || style == .ChooseFillNoShowCode
                    || style == .ChooseFillShowCodeOnePosition
                    || style == .ChooseFillNoShowCodeOnePosition
                    || style == .ChooseShowCode
                    || style == .ChooseNoShowCode
                    || style == .ChooseShowCodeOnePosition
                    || style == .ChooseNoShowCodeOnePosition {
                    inputTextFiled.inputView = UIView(frame: CGRect.zero)
                }
            }
        }
    }
    
    var richTextContent: RichTextContent? {
        didSet {
            if let _ = richTextContent {
                
            }
        }
    }
    
    var isUserInteracted = true {
        didSet {
            //inputTextFiled.isUserInteractionEnabled = isUserInteracted
        }
    }
    
    func answerParameters() -> RichParameterType {
        var parameters: RichParameterType = [:]
        parameters["scores"] = 0
        parameters["answer"] = answer()
        parameters["index"] = "\(inputBoxIdx())"
        return parameters
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        inputTextFiled = UITextField()
        inputTextFiled.font = RTLessNormalFont
        inputTextFiled.delegate = self
        inputTextFiled.addTarget(self, action: #selector(textFieldEditChanged(textField:)), for: .editingChanged)
        addSubview(inputTextFiled)
        
        makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeConstraints() {
        inputTextFiled.snp.remakeConstraints { (make) in
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.top.equalTo(5)
            make.bottom.equalTo(-5)
        }
    }
    
    @objc func textFieldEditChanged(textField: UITextField) {
        if !isUserInteracted {
            return
        }
        self.chooseEmptyViewDelegate?.textFieldEditChanged?(textField: textField, emptyView: self)
    }
    
    func loadData(style: ExerciseStyle?, chooseEmptyIndex: Int, richTextContent: RichTextContent?) {
        self.style = style
        self.chooseEmptyIndex = chooseEmptyIndex
        self.richTextContent = richTextContent
    }
    
}

extension ChooseEmptyView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if !isUserInteracted {
            AnswerSystemHelper.modifyStatusNotificationPost()
            return false
        }
        self.chooseEmptyViewDelegate?.focus?(index: chooseEmptyIndex, emptyView: self)
        return true
    }
}

extension ChooseEmptyView {
    
    fileprivate func inputBoxIdx() -> Int {
        return self.richTextContent?.inputBoxIdx ?? 0
    }
    
    fileprivate func answer() -> String {
        return inputTextFiled.text ?? ""
    }
    
    func fillIsRight() -> Bool {
        if let richTextContent = richTextContent, let answer = richTextContent.answers.first {
            if answer == "" {
                //如果本题不需要答案，直接返回正确
                return true
            }
            return answer == inputTextFiled.text
        }
        return false
    }
}
