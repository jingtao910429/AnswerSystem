//
//  QuestionBaseView.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/8.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import YYText
import MMBaseComponents

class QuestionBaseView: UIView {
    
    var baseSpace = CGFloat(16)
    
    public var inputConvertFrame: CGRect?
    
    var questionTitleLabel: UILabel!
    var questionScrollView: UIScrollView!
    var baseRichTextView: YYLabel!
    var exerciseQuestionsFeedBackView: ExerciseQuestionsFeedBackView!
    var answerParseContainerView: AnswerParseContainerView?
    
    var options: [[TextAttachmentContent]] = []
    
    //是否编辑过题目, false: 没有更改
    var isEdit = false
    //是否禁止编辑
    var isUserInteracted = true
    
    weak var questionContainerDelegate: QuestionContainerDelegate?
    
    var topic: TopicModel? {
        didSet {
            //添加描述
            if let topic = topic {
                if topic.name != "" && topic.index != "" {
                    questionTitleLabel.text = "\(topic.index)\(topic.name)"
                    if topic.score != 0 {
                        let intValue = Int(topic.score)
                        if CGFloat(intValue) == topic.score {
                            questionTitleLabel.text = "\(topic.index)\(topic.name) (\(intValue)分)"
                        } else {
                            questionTitleLabel.text = "\(topic.index)\(topic.name) (\(topic.score)分)"
                        }
                    }
                }
                options = AnswerSystemManager.shared.richText(richText: baseRichTextView, model: topic.content?.richtext, topicType: ExerciseStyle(rawValue: topic.type))
                remakeConstraints()
            }
        }
    }
    
    var answers: [UserAnswerItemModel]? {
        didSet {
            
        }
    }
    
    //解析显示状态
    public var answerParseStatus = false
    
    //获取用户答案，用于上传信息
    public func fetchAnswers() -> [RichParameterType] {
        return []
    }
    
    public func judeEditStatus(userAnswers: [RichParameterType]) {
        if let answers = self.answers {
            for (index, item) in answers.enumerated() {
                if userAnswers.count > index {
                    let paras = userAnswers[index]
                    if let result = paras["answer"] as? String {
                        if result != item.answer {
                            //编辑过
                            self.isEdit = true
                            break
                        }
                    } else if let result = paras["answer"] as? Bool {
                        let tRes = (item.optionAnswer == 1) ? true : false
                        if tRes != result {
                            //编辑过
                            self.isEdit = true
                            break
                        }
                    } else if let result = paras["answer"] as? Int {
                        if result != item.optionAnswer {
                            //编辑过
                            self.isEdit = true
                            break
                        }
                    }
                }
            }
            if answers.count != userAnswers.count {
                self.isEdit = true
            }
        } else {
            if userAnswers.count != 0 {
                for paras in userAnswers {
                    if let result = paras["answer"] as? String, result != "" {
                        self.isEdit = true
                    } else if let _ = paras["answer"] as? Bool {
                        self.isEdit = true
                    }  else if let _ = paras["answer"] as? Int {
                        self.isEdit = true
                    }
                }
            }
        }
    }
    
    //对比答题结果，用于本地判断答题情况
    public func answerResult() -> Bool {
        return true
    }
    
    //更新答案解析视图
    public func updateAnswerParseConstraints() {
        self.remakeConstraints(needBottom: self.needBottom)
        let deadlineTime = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            self.bottomStatus = -1
            self.changeFeedBackView()
        })
        
    }
    
    public var exerciseQuestionsFeedBackBlock: ExerciseQuestionsFeedBackBlock? {
        didSet {
            exerciseQuestionsFeedBackView.exerciseQuestionsFeedBackBlock = exerciseQuestionsFeedBackBlock
        }
    }
    
    public var answerParseKnowleadgeRelateBlock: AnswerParseKnowleadgeRelateBlock? {
        didSet {
            answerParseContainerView?.answerParseKnowleadgeRelateBlock = answerParseKnowleadgeRelateBlock
        }
    }
    
    fileprivate var bottomStatus = -1
    fileprivate var needBottom = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        questionTitleLabel = UILabel(frame: frame)
        questionTitleLabel.font = RTNormalFont
        questionTitleLabel.numberOfLines = 0
        questionTitleLabel.lineBreakMode = .byWordWrapping
        questionTitleLabel.textColor = RTGrayColor
        addSubview(questionTitleLabel)
        
        questionScrollView = UIScrollView(frame: frame)
        questionScrollView.bounces = false
        addSubview(questionScrollView)
        
        baseRichTextView = YYLabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 0))
        baseRichTextView.numberOfLines = 0
        questionScrollView.addSubview(baseRichTextView)
        
        answerParseContainerView = AnswerParseContainerView(frame: CGRect(x: 0, y: 0, width: frame.width - 20, height: 0))
        answerParseContainerView?.isHidden = true
        questionScrollView.addSubview(answerParseContainerView!)
        
        exerciseQuestionsFeedBackView = ExerciseQuestionsFeedBackView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 30))
        exerciseQuestionsFeedBackView.isHidden = true
        addSubview(exerciseQuestionsFeedBackView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeConstraints() {
        remakeConstraints()
    }
    
    func remakeConstraints(needBottom: Bool = false) {
        
        self.needBottom = needBottom
        
        let estemateWidth = self.width - 20
        let titleBestSize = self.questionTitleLabel.sizeThatFits(CGSize(width: estemateWidth, height: CGFloat.greatestFiniteMagnitude))
        
        questionTitleLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(5)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(titleBestSize.height)
        }
        
        questionScrollView.snp.remakeConstraints { (make) in
            make.top.equalTo(questionTitleLabel.snp.bottom)
            make.left.right.equalTo(0)
            make.bottom.equalTo(0)
        }
        
        exerciseQuestionsFeedBackView.snp.remakeConstraints { (make) in
            make.left.right.equalTo(self.questionScrollView)
            make.height.equalTo(16)
            make.bottom.equalTo(self.questionScrollView.snp.bottom).offset(-5)
        }
        
        self.baseRichTextView.sizeToFit()
        let bestSize = self.baseRichTextView.sizeThatFits(CGSize(width: estemateWidth, height: CGFloat.greatestFiniteMagnitude))
        
        self.baseRichTextView.layoutIfNeeded()
        print(self.baseRichTextView.height)
        
        var rightHeight = CGFloat(bestSize.height)
        if self.baseRichTextView.height > bestSize.height {
            rightHeight = self.baseRichTextView.height
        }
        
        if baseRichTextView.text == ""
            || baseRichTextView.text == "\n" {
            rightHeight = 0
        }
        
        let isHidden = self.answerParseContainerView!.isHidden
        
        if needBottom && !isHidden {
            answerParseContainerView?.snp.makeConstraints({ (make) in
                make.top.equalTo(self.baseRichTextView.snp.bottom).offset(5)
                make.centerX.equalTo(questionScrollView)
                make.left.right.equalTo(self)
                make.bottom.equalTo(questionScrollView).offset(-50)
            })
        }
        
        self.baseRichTextView.snp.remakeConstraints({ (make) in
            make.top.equalTo(questionScrollView).offset(5)
            make.width.equalTo(estemateWidth)
            make.height.equalTo(rightHeight)
            if needBottom {
                if isHidden {
                    make.bottom.equalTo(-50)
                }
                make.left.equalTo(10)
                make.right.equalTo(-10)
            } else {
                make.centerX.equalTo(questionScrollView)
            }
        })
    }
    
    func changeFeedBackView() {
        
        var tIsBottom = 0
        if height < questionScrollView.contentSize.height + 40 {
            //存在滑动
            tIsBottom = 1
        }
        
        if bottomStatus != -1 && bottomStatus == tIsBottom {
            return
        }
        
        bottomStatus = tIsBottom
        
        exerciseQuestionsFeedBackView.isHidden = false
        
        if tIsBottom == 0 {
            
            exerciseQuestionsFeedBackView.snp.remakeConstraints { (make) in
                make.left.right.equalTo(self.questionScrollView)
                make.height.equalTo(16)
                var space = -5
                if !answerParseStatus {
                    space = -35
                }
                make.bottom.equalTo(self.questionScrollView.snp.bottom).offset(space)
            }
            
        } else {
            
            if let isHidden = self.answerParseContainerView?.isHidden, isHidden {
                let subViews = self.questionScrollView.subviews
                let count = subViews.count - 1
                for (index, _) in self.questionScrollView.subviews.enumerated() {
                    let subView = subViews[count - index]
                    if (self.topic?.type == ExerciseStyle.Read.rawValue || self.topic?.type == ExerciseStyle.PinyinRead.rawValue)
                        && subView.tag == ReadLastViewTag {
                        exerciseQuestionsFeedBackView.snp.remakeConstraints { (make) in
                            make.left.right.equalTo(self.questionScrollView)
                            make.height.equalTo(16)
                            make.top.equalTo(subView.snp.bottom).offset(-25)
                        }
                        break
                    } else {
                        if subView is MatchLineView
                            || subView is WriteContentView
                            || subView is YYLabel {
                            var space = 0
                            if subView is MatchLineView {
                                space = 5
                            }
                            exerciseQuestionsFeedBackView.snp.remakeConstraints { (make) in
                                make.left.right.equalTo(self.questionScrollView)
                                make.height.equalTo(16)
                                make.top.equalTo(subView.snp.bottom).offset(space)
                            }
                            break
                        }
                    }
                }
            } else {
                if let answerParseContainerView = self.answerParseContainerView {
                    exerciseQuestionsFeedBackView.snp.remakeConstraints { (make) in
                        make.left.right.equalTo(self.questionScrollView)
                        make.height.equalTo(16)
                        make.top.equalTo(answerParseContainerView.snp.bottom)
                    }
                }
            }
        }
    }
    
}
