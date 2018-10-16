//
//  AnswerParseContainerView.swift
//  MMBusinessComponents
//
//  Created by Mac on 2018/8/28.
//

import UIKit

public typealias AnswerParseKnowleadgeRelateBlock = ((_ knowleadge: AnswerParseKnowleadgeContentModel) -> Void)
//答案解析汇总页
class AnswerParseContainerView: UIView {
    
    fileprivate var lineView: UIView!
    //正确答案
    fileprivate var realAnswerView: AnswerParseRealAnswerView!
    //答案解析
    fileprivate var answerParseView: AnswerParseView!
    //知识要点
    fileprivate var knowleadgeView: AnswerParseKeyKnowleadgeView!
    //信息记录
    fileprivate var recordInfoView: AnswerParseRecordInfoView!
    
    var answerParseKnowleadgeRelateBlock: AnswerParseKnowleadgeRelateBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        lineView = UIView()
        lineView.backgroundColor = RTThemeColor
        addSubview(lineView)
        
        realAnswerView = AnswerParseRealAnswerView(frame: frame)
        addSubview(realAnswerView)
        
        answerParseView = AnswerParseView(frame: frame)
        addSubview(answerParseView)
        
        knowleadgeView = AnswerParseKeyKnowleadgeView(frame: frame)
        addSubview(knowleadgeView)
        
        recordInfoView = AnswerParseRecordInfoView(frame: frame)
        addSubview(recordInfoView)
        
        makeConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func makeConstraints() {
        
        lineView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(0.5)
        }
        
        realAnswerView.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.left.right.equalTo(0)
        }
        
        answerParseView.snp.makeConstraints { (make) in
            make.top.equalTo(realAnswerView.snp.bottom).offset(2).priority(999)
            make.left.right.equalTo(0)
        }
        
        knowleadgeView.snp.makeConstraints { (make) in
            make.top.equalTo(answerParseView.snp.bottom).offset(2).priority(999)
            make.left.right.equalTo(0)
        }
        
        recordInfoView.snp.makeConstraints { (make) in
            make.top.equalTo(knowleadgeView.snp.bottom).offset(2).priority(999)
            make.left.right.equalTo(0)
            make.bottom.equalTo(0)
        }
    }
    
}

extension AnswerParseContainerView {
    
    func loadData(topic: TopicModel?) -> Bool {
        
        guard let topic = topic, let topicType = ExerciseStyle(rawValue: topic.type) else {
            return false
        }
        
        if topicType == .Read
            || topicType == .WriteCharacter
            || topicType == .PinyinRead
            || topicType == .PinyinWrite
            || topicType == .CircleChoose {
            //去除不支持题型
                return false
        }
        
        //正确答案
        let isExistAnswer = realAnswerView.loadData(topic: topic)
        
        if !isExistAnswer {
            //隐藏
            return false
        }
        
        //答案解析
        if topic.answersParsing == nil {
            answerParseView.isHidden = true
        } else {
            answerParseView.isHidden = false
            answerParseView.answersParsing = topic.answersParsing
        }
        
        if AnswerSystemManager.shared.isOnlyNewLine {
            answerParseView.isHidden = true
        }
        
        answerParseView.snp.remakeConstraints { (make) in
            make.top.equalTo(realAnswerView.snp.bottom).offset(2).priority(999)
            make.left.right.equalTo(0)
            if answerParseView.isHidden {
                make.height.equalTo(0)
            }
        }
    
        //知识要点
        if topic.topics.count == 0 {
            knowleadgeView.isHidden = true
        } else {
            knowleadgeView.isHidden = false
            knowleadgeView.loadData(topics: topic.topics) { [weak self] (index, tagView) in
                guard let `self` = self else {
                    return
                }
                let model = topic.topics[index]
                self.answerParseKnowleadgeRelateBlock?(model)
            }
        }
        
        knowleadgeView.snp.remakeConstraints { (make) in
            make.top.equalTo(answerParseView.snp.bottom).offset(2).priority(999)
            make.left.right.equalTo(0)
            if knowleadgeView.isHidden {
                make.height.equalTo(0)
            }
        }
        
        if topic.personsDone == 0 {
            recordInfoView.loadData(doNumber: topic.personsDone, rate: 0)
        } else {
            recordInfoView.loadData(doNumber: topic.personsDone, rate: CGFloat(topic.personsRight) / CGFloat(topic.personsDone))
        }
        return true
    }
}
