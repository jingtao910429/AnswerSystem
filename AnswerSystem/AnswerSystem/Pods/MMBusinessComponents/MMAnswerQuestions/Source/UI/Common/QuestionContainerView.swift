//
//  QuestionContainerView.swift
//  MMRichText_Example
//
//  Created by Mac on 2018/4/9.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import MMToolHelper
import MMBaseComponents
import YYText

public typealias RichParameterType = [String: Any]

@objc public protocol QuestionContainerDelegate {
    @objc optional func uploadImage(image: UIImage)
    @objc optional func uploadResultCallBack() -> String?
    @objc optional func readResult(isRight: Bool)
    @objc optional func dragControl(isShow: Bool)
}

public struct QuestionResultStruct {
    public var result: RichParameterType = [:]
    //0: 错  1: 部分对 2: 全对
    public var answerStatus = 0
}

public class QuestionContainerView: UIView {
    
    fileprivate var baseSpace = CGFloat(40)
    fileprivate var limitTotalHeight = CGFloat(0)
    
    fileprivate var contentView: UIScrollView!
    fileprivate var imageDashLineView: UIImageView!
    fileprivate var dragButton: UIButton!
    fileprivate var questionBaseView: QuestionBaseView!
    fileprivate var desAttributeContentLabel: YYLabel!
    fileprivate var answerParseControlView: AnswerParseControlView!
    
    fileprivate var helper = AnswerSystemExerciseHelper()
    fileprivate var answers: [UserAnswerItemModel] = []
    fileprivate var startBaseFrame: CGRect?
    fileprivate var startContentFrame: CGRect?
    fileprivate var startY = CGFloat(0)
    fileprivate var isExistAnswer = false
    
    public weak var questionContainerDelegate: QuestionContainerDelegate?
    
    public var exerciseStyle: ExerciseStyle = .None
    
    public var questionId = ""
    public var type = 0
    //顶部标题上移至Nav
    public var isTopQuestionContainer = true
    
    public var storeTopic: TopicModel?
    public var topic: TopicModel? {
        didSet {
            if let topic = topic {
                
                limitTotalHeight = (self.height - DeviceInfo.bottomHeight()) * 2.0 / 3.0
                removeSubviews()
                
                isTopQuestionContainer = true
                
                self.storeTopic = topic
                loadDesInfoInterface(topic: topic, childShow: false)
                
                self.questionBaseView.exerciseQuestionsFeedBackBlock = exerciseQuestionsFeedBackBlock
                self.questionBaseView.answerParseKnowleadgeRelateBlock = answerParseKnowleadgeRelateBlock
            }
        }
    }
    
    public var convertFrame: CGRect? {
        get {
            return self.questionBaseView.inputConvertFrame
        }
    }
    
    public var answer: UserAnswersQuestionModel? {
        didSet {
            if let answer = answer {
                self.answers = answer.answers
            } else {
                self.answers = []
            }
            
            if questionBaseView != nil {
                questionBaseView.answers = answers
            }
        }
    }
    
    //(请求参数, 是否正确)
    public func fetchQuestionResults() -> QuestionResultStruct? {
        
        if questionBaseView != nil {
            
            var questionResultStruct = QuestionResultStruct()
            
            //获取用户答案
            let parameters = questionBaseView.fetchAnswers()
            var answerStatus = 2
            
            if parameters.count == 0 {
                answerStatus = 0
            } else {
                var rightNumber = 0
                for para in parameters {
                    if let right = para["is_right"] as? Bool, right {
                        rightNumber += 1
                    }
                }
                if rightNumber == parameters.count {
                    //全对
                    answerStatus = 2
                } else if rightNumber == 0 {
                    answerStatus = 0
                } else {
                    answerStatus = 1
                }
            }
            
            //对比答案统计score
            
            var parameterDatas: RichParameterType = [:]
            parameterDatas["score"] = caculateUserScore(answerStatus: answerStatus, parameters: parameters)
            parameterDatas["done"] = true
            parameterDatas["answerData"] = jsonString(array: parameters).replacingOccurrences(of: "\n", with: "")
            
            if self.exerciseStyle == .None
                || self.exerciseStyle == .PinyinWrite
                || self.exerciseStyle == .CircleChoose {
                answerStatus = 2
            }
            parameterDatas["answerStatus"] = answerStatus
            
            questionResultStruct.result = parameterDatas
            questionResultStruct.answerStatus = answerStatus
            
            return questionResultStruct
        }
        return nil
    }
    
    //0：正常编辑  1：批改  2：重考
    public var answerParseStatus = 1
    
    //是否编辑过
    public func fetchEditStatus() -> Bool {
        return self.questionBaseView.isEdit
    }
    
    fileprivate func caculateUserScore(answerStatus: Int, parameters: [RichParameterType]) -> CGFloat {
        if self.questionBaseView == nil {
            return CGFloat(0)
        }
        if answerStatus == 1 {
            //半对
            var score = CGFloat(0)
            let itemScore = (self.questionBaseView.topic?.score ?? CGFloat(0)) / CGFloat(parameters.count)
            for answer in parameters {
                if let isRight = answer["is_right"] as? Bool, isRight {
                    score += itemScore
                }
            }
            let strScore = String(format: "%.2f", score)
            return CGFloat(strScore.doubleValue() ?? 0)
        } else if answerStatus == 0 {
            return CGFloat(0)
        }
        return self.questionBaseView.topic?.score ?? CGFloat(0)
    }
    
    public func updateAnswerParseConstraints() {
        if self.questionBaseView == nil {
            return
        }
        if answerParseControlView.isHidden {
            questionBaseView.answerParseStatus = false
            answerParseControlView.isHidden = false
            answerParseControlView.initData()
            self.bringSubview(toFront: answerParseControlView)
            self.questionBaseView.updateAnswerParseConstraints()
        }
    }
    
    //是否禁止编辑
    public var isUserInteracted = true
    
    public var exerciseQuestionsFeedBackBlock: ExerciseQuestionsFeedBackBlock?
    public var answerParseKnowleadgeRelateBlock: AnswerParseKnowleadgeRelateBlock?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        if DeviceInfo.isPad() {
            NotificationCenter.default.addObserver(self, selector: #selector(receiverNotification), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        }
        
        self.backgroundColor = UIColor.white
        
        contentView = UIScrollView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 30))
        contentView.isHidden = true
        contentView.showsVerticalScrollIndicator = true
        addSubview(contentView)
        
        desAttributeContentLabel = YYLabel(frame: contentView.bounds)
        desAttributeContentLabel.numberOfLines = 0
        contentView.addSubview(desAttributeContentLabel)
        
        imageDashLineView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width - baseSpace, height: 0.5))
        imageDashLineView.isHidden = true
        imageDashLineView.backgroundColor = RTSeperateColor
        addSubview(imageDashLineView)
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(dragAction(_ :)))
        dragGesture.delegate = self
        
        dragButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        dragButton.setImage(bundleImage(name: "exercise_drag"), for: .normal)
        dragButton.setImage(bundleImage(name: "exercise_drag_hightLighted"), for: .highlighted)
        dragButton.addGestureRecognizer(dragGesture)
        dragButton.isHidden = true
        addSubview(dragButton)
        
        self.bringSubview(toFront: imageDashLineView)
        
        answerParseControlView = AnswerParseControlView(frame: CGRect(x: 0, y: 0, width: frame.width, height: AnswerParseBottomControlHeight))
        answerParseControlView.answerParseControlBlock = { [weak self] (status) in
            guard let `self` = self else {
                return
            }
            self.questionBaseView.answerParseContainerView?.isHidden = !status
            self.questionBaseView.updateAnswerParseConstraints()
        }
        addSubview(answerParseControlView)
        
        makeConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeConstraints() {
        
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(0)
        }
        
        desAttributeContentLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
        
        answerParseControlView.snp.makeConstraints { (make) in
            make.bottom.equalTo(0)
            make.left.right.equalTo(0)
            make.height.equalTo(AnswerParseBottomControlHeight)
        }
        
        remakeDragConstraints()
        
    }
    
    @objc public func dragAction(_ panGesture: UIPanGestureRecognizer) {
        

        switch panGesture.state {
        case .began:
            
            questionBaseView.clearConstraints()
            contentView.clearConstraints()
            imageDashLineView.clearConstraints()
            dragButton.clearConstraints()
            
            startBaseFrame = questionBaseView.frame
            startContentFrame = contentView.frame
            
        case .changed:
            
            if let startPoint = startBaseFrame?.origin, let startSize = startBaseFrame?.size, let contentStartPoint = startContentFrame?.origin, let contentStartSize = startContentFrame?.size {
                
                let translation  = panGesture.translation(in: self)
                
                if !canDrag(panGesture, state: panGesture.state, transition: translation.y) {
                    return
                }

                let space = translation.y
                
                questionBaseView.frame = CGRect(x: 0, y: startPoint.y + translation.y, width: startSize.width, height: startSize.height - space)
                contentView.frame = CGRect(x: contentStartPoint.x, y: contentStartPoint.y, width: contentStartSize.width, height: contentStartSize.height + space)
                
                questionBaseView.changeFeedBackView()
                
                imageDashLineView.center = CGPoint(x: startSize.width / 2.0, y: startPoint.y + translation.y - 1)
                dragButton.center = CGPoint(x: startSize.width / 2.0, y: startPoint.y + translation.y - 8.5)
            }
            
        case .ended:
            
            let translation  = panGesture.translation(in: self)
            
            if !canDrag(panGesture, state: panGesture.state, transition: translation.y) {
                return
            }
            
            //(startBaseFrame?.origin.y ?? 0)
            let height = questionBaseView.y - contentView.height
            self.resetContentSize(height: height)
            
            startBaseFrame = questionBaseView.frame
            startContentFrame = contentView.frame
        case .failed:
            break
        default:
            break
        }
    }
    
    public func loadDesInfoInterface(topic: TopicModel?, childShow: Bool) {
        var childShowStatus = childShow
        if let topic = topic {
            if topic.questions.count > 0 {
                if topic.name != "" && topic.index != "" {
                    
                    if topic.content != nil {
                        childShowStatus = true
                    } else {
                        childShowStatus = false
                    }
                    
                    addSubviews()
                    
                    let attribute = NSMutableAttributedString(string: "")
                    if let des = desAttributeContentLabel.attributedText {
                        attribute.append(des)
                    }
                    
                    let topicTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width - baseSpace + 10, height: 30))
                    topicTitleLabel.textColor = RTGrayColor
                    topicTitleLabel.numberOfLines = 0
                    if desAttributeContentLabel.text == "" {
                        topicTitleLabel.font = UIFont.systemFont(ofSize: 17)
                    } else {
                        topicTitleLabel.font = UIFont.systemFont(ofSize: 16)
                    }
                    
                    topicTitleLabel.text = "\(topic.index)\(topic.name)"
                    
                    if topic.score != 0 {
                        let intValue = Int(topic.score)
                        if CGFloat(intValue) == topic.score {
                           topicTitleLabel.text = "\(topic.index)\(topic.name) (\(intValue)分)"
                        } else {
                            topicTitleLabel.text = "\(topic.index)\(topic.name) (\(topic.score)分)"
                        }
                    }
                    
                    let attributes = [NSAttributedStringKey.font: topicTitleLabel.font!]
                    let topicHeight  = topicTitleLabel.text!.boundingRect(with: CGSize(width: frame.width - baseSpace + 10, height: CGFloat.greatestFiniteMagnitude), options:.usesLineFragmentOrigin, attributes: attributes, context:nil).size.height + 10
                    
                    topicTitleLabel.height = topicHeight
                    
                    let topicAttribute = NSMutableAttributedString.yy_attachmentString(withContent: topicTitleLabel, contentMode: .left, attachmentSize: topicTitleLabel.size, alignTo: topicTitleLabel.font, alignment: .center)
                    
                    if !isTopQuestionContainer && topicTitleLabel.text != "" && topicTitleLabel.text != "\n" {
                        attribute.append(topicAttribute)
                    }
                    isTopQuestionContainer = false
                    
                    let tempAttributeContainer = YYLabel()
                    let _ = AnswerSystemManager.shared.richText(richText: tempAttributeContainer, model: topic.content?.richtext)
                    
                    if !AnswerSystemManager.shared.isOnlyNewLine, let des = tempAttributeContainer.attributedText {
                        attribute.append(des)
                    }
                    
                    desAttributeContentLabel.attributedText = attribute
                    
                    desAttributeContentLabel.sizeToFit()
                    let bestSize = desAttributeContentLabel.sizeThatFits(CGSize(width: frame.width - 30, height: CGFloat.greatestFiniteMagnitude))
                    
                    if bestSize.height > limitTotalHeight {
                        startY = limitTotalHeight
                    } else {
                        if bestSize.height == 0 {
                            startY = 0
                        } else {
                            startY = bestSize.height
                        }
                    }
                    
                    contentView.snp.remakeConstraints { (make) in
                        make.top.equalTo(5)
                        make.left.equalTo(15)
                        make.right.equalTo(-15)
                        make.height.equalTo(startY)
                    }
                    
                    desAttributeContentLabel.snp.remakeConstraints({ (make) in
                        make.height.equalTo(bestSize.height)
                        make.width.equalTo(contentView)
                        make.top.equalTo(0)
                        make.left.right.equalTo(0)
                        make.bottom.equalTo(-20)
                    })
                    
                    remakeDragConstraints()
                    
                } else {
                    childShowStatus = childShow
                }
                loadDesInfoInterface(topic: topic.questions.first, childShow: childShowStatus)
            } else {
                loadItemInfoInterface(topic: topic)
            }
            
        }
    }
    
    public func loadItemInfoInterface(topic: TopicModel?) {
        if let topic = topic, topic.type != -1 {
            let type = ExerciseStyle(rawValue: topic.type)
            
            if type == nil
                || type == ExerciseStyle.PinyinWrite
                || type == ExerciseStyle.CircleChoose {
                return
            }
            
            self.exerciseStyle = type!
            
            if let type = type {
                
                self.contentView.contentOffset = CGPoint(x: 0, y: 0)
                
                questionBaseView = helper.addExerciseView(owner: self, style: type, topic: topic, answers: self.answers, isUserInteracted: self.isUserInteracted)
                questionBaseView.questionContainerDelegate = questionContainerDelegate
                
                isExistAnswer = questionBaseView.answerParseContainerView?.loadData(topic: topic) ?? false
                
                remakeBaseViewConstraints()
                
                controlContentView()
                
                startBaseFrame = questionBaseView.frame
                startContentFrame = contentView.frame
                
                layoutAnswerParseView()
            }
        }
        
    }
    
    public func layoutAnswerParseView() {
        //答案解析加载
        
        let deadlineTime = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            self.questionBaseView.changeFeedBackView()
        })
        
        var isShow = false
        if answerParseStatus == 1 && isExistAnswer {
            isShow = true
        } else {
            if let topic = questionBaseView.topic, topic.hasBeenDone && isExistAnswer {
                isShow = true
            }
        }
        
        if isShow {
            //该题目是否做过
            questionBaseView.answerParseStatus = false
            answerParseControlView.isHidden = false
            answerParseControlView.initData()
            self.bringSubview(toFront: answerParseControlView)
            if answerParseStatus == 1 {
                //批改，默认展开
                answerParseControlView.tipAction()
            }
        } else {
            questionBaseView.answerParseStatus = true
            questionBaseView.answerParseContainerView?.isHidden = true
            answerParseControlView.isHidden = true
        }
        
    }
    
    public func remakeBaseViewConstraints() {
        
        questionBaseView?.snp.remakeConstraints({ (make) in
            make.top.equalTo(contentView.snp.bottom)
            if contentView.subviews.contains(desAttributeContentLabel) {
                make.left.right.equalTo(self)
                make.bottom.equalTo(0)
            } else {
                make.left.right.bottom.equalTo(self)
            }
        })
        
    }
    
    @objc func receiverNotification() {
        if questionBaseView != nil {
            self.topic = self.storeTopic
            questionBaseView.answers = self.answers
            questionBaseView.exerciseQuestionsFeedBackBlock = exerciseQuestionsFeedBackBlock
            questionBaseView.answerParseKnowleadgeRelateBlock = answerParseKnowleadgeRelateBlock
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    deinit {
        print("QuestionContainerView 释放！")
        NotificationCenter.default.removeObserver(self)
    }
}

extension QuestionContainerView: UIGestureRecognizerDelegate {
    
}

extension QuestionContainerView {
    
    fileprivate func canDrag(_ panGesture: UIPanGestureRecognizer, state: UIGestureRecognizerState, transition: CGFloat) -> Bool {
        //direction 0向下 1向上
        let direction = (transition < 0 ? 1 : 0)
        
        if direction == 1 && questionBaseView.y > 0 && questionBaseView.y < 30 {
            //上拉最大高度
            
            if state == .ended {
                self.questionBaseView?.snp.remakeConstraints({ (make) in
                    make.top.equalTo(self.contentView.snp.bottom)
                    make.left.right.bottom.equalTo(self)
                })
                self.remakeDragConstraints(offset: CGFloat(0))
            }
        
            return false
        }
        
        if direction == 0 && questionBaseView.height < 50 {
            //下拉最大高度
            if state == .ended {
                let minHeight = limitTotalHeight * 3.0 / 2.0 - 50
                contentView.snp.remakeConstraints { (make) in
                    make.top.equalTo(10)
                    make.left.equalTo(15)
                    make.right.equalTo(-15)
                    make.height.equalTo(minHeight)
                }
                resetContentSize(height: 0)
            }
            return false
        }
        return true
    }
    
    fileprivate func resetContentSize(height: CGFloat) {
        
        let bestSize = desAttributeContentLabel.sizeThatFits(CGSize(width: frame.width - baseSpace, height: CGFloat.greatestFiniteMagnitude))
        
        let sizeHeight = (height < 0 ? (bestSize.height - height) : bestSize.height)
        
        desAttributeContentLabel.snp.remakeConstraints { (make) in
            make.top.left.right.equalTo(contentView)
            make.width.equalTo(frame.width - baseSpace)
            make.height.equalTo(bestSize.height)
            if height < 0 {
                make.bottom.equalTo(contentView.snp.bottom).offset(height - 20)
            } else {
                make.bottom.equalTo(contentView.snp.bottom).offset(-20)
            }
        }
        
        remakeBaseViewConstraints()
        
        self.contentView.contentSize = CGSize(width: frame.width - baseSpace, height: sizeHeight + 20)
        
        if DeviceInfo.isPhone() {
            self.remakeDragConstraints(offset: CGFloat(0))
        }
    }
    
    fileprivate func removeSubviews() {
        
        questionBaseView = nil
        
        for sub in contentView.subviews {
            sub.removeFromSuperview()
        }
        desAttributeContentLabel.attributedText = NSMutableAttributedString(string: "")
        imageDashLineView.removeFromSuperview()
        dragButton.removeFromSuperview()
        
        contentView.snp.remakeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(0)
        }
    }
    
    fileprivate func addSubviews() {
        if !contentView.subviews.contains(desAttributeContentLabel) {
            desAttributeContentLabel.attributedText = NSMutableAttributedString(string: "")
            contentView.addSubview(desAttributeContentLabel)
            addSubview(imageDashLineView)
            addSubview(dragButton)
        }
    }
    
    fileprivate func remakeDragConstraints(offset: CGFloat = CGFloat(0)) {
        
        imageDashLineView.snp.remakeConstraints { (make) in
            make.top.equalTo(contentView.snp.bottom).offset(-0.6 + offset).priority(999)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(0.6)
        }
        
        dragButton.snp.remakeConstraints { (make) in
            make.top.equalTo(contentView.snp.bottom).offset(-18 + offset).priority(999)
            make.centerX.equalTo(self)
            make.width.equalTo(60)
            make.height.equalTo(20)
        }
    }
    
    fileprivate func controlContentView() {
        
        self.contentView.isScrollEnabled = true
        
        if contentView.subviews.contains(desAttributeContentLabel) {
            
            contentView.isHidden = false
            imageDashLineView.isHidden = false
            dragButton.isHidden = false
            
            let bestSize = desAttributeContentLabel.sizeThatFits(CGSize(width: frame.width - baseSpace, height: CGFloat.greatestFiniteMagnitude))
            if bestSize.height < self.height / 3.0 {
                dragButton.isHidden = true
                contentView.isScrollEnabled = false
            }
            
            if bestSize.height == 0 {
                imageDashLineView.isHidden = true
            }
            
        } else {
            
            contentView.isHidden = true
            imageDashLineView.isHidden = true
            dragButton.isHidden = true
        }
        
        if dragButton.isHidden {
            self.questionContainerDelegate?.dragControl?(isShow: false)
        } else {
            self.questionContainerDelegate?.dragControl?(isShow: true)
        }
    }
}

extension QuestionContainerView {
    
    fileprivate func jsonString(array: [RichParameterType]) -> String {
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
            let jsonString = String.init(data: jsonData, encoding: .utf8)
            return jsonString!
        } catch {
            fatalError("jsonDataError")
        }
        return ""
    }
}
